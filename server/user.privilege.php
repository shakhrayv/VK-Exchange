<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "18a68fdc888ccd200e17b11d9d38ed587547afe074f56724bc063fdc4dda7fbd";
//NSUserDefaults

/*
 * Checking if all parameters are passed
 */
if (!check_params(array('user_id', 'pass'))) {
    show_error();
}

$user_id = $_GET['user_id'];
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array($user_id), $key, $pass)) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

/*
 * Setting privileged status
 */
if ($stmt = $db->prepare('UPDATE USERS SET privileged=1 WHERE user_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

change_last_active_date($db, $user_id);

/*
 * Echo-ing user info
 */
if ($stmt = $db->prepare('SELECT * FROM USERS WHERE user_id=? LIMIT 1')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if(!$res){
        rollback_transaction($db);
    }
    $row = $res->fetchArray(SQLITE3_ASSOC);
    if ($row) {
        commit_transaction(json_encode(array('response'=>$row)), $db);
    } else {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

?>