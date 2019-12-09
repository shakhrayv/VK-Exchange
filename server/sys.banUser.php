<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "rDUPOqXiy0Mu1axra8NunOoFdbcRbVv9PhVvF9ceR1IjPAEB0IoXvF0JTVb9Kx";
//NSUserDefaults

/*
 * Checking if all parameters are passed
 */
if (!check_params(array('user_id', 'key'))) {
    show_error();
}

$user_id = $_GET['user_id'];
$pass = $_GET['key'];

/*
 * Checking SHA
 */
if ($key!= $pass) {
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
if ($stmt = $db->prepare('UPDATE USERS SET banned=1 WHERE user_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('ok', $db);
?>