<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "9d4e64b569963328731bc91c99f8a147a9a65fc23ff8ac4099a887e8dc657dfb";

/*
 * Checking if all parameters are passed
 */
if (!check_params(array('token', 'user_id', 'amount', 'pass'))) {
    show_error();
}

$token = $_GET['token'];
$user_id = $_GET['user_id'];
$amount = $_GET['amount'];
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array($token, $user_id, $amount), $key, $pass)) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

check_ban($user_id, $db);
add_id($db, $token, 'token');

change_last_active_date($db, $user_id);

mail('support@codelovin.co', 'Purchase', 'User '.$user_id.' purchased '.$amount.' coins.');

/*
 * Adding amount to user
 */
if ($stmt = $db->prepare('UPDATE USERS SET balance=balance+? WHERE user_id=?')) {
    $stmt->bindValue(1, ceil($amount*1.25), SQLITE3_INTEGER);
    $stmt->bindValue(2, $user_id, SQLITE3_INTEGER);
    if(!$stmt->execute()) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Logging into PURCHASED table
 */
if ($stmt = $db->prepare('INSERT INTO PURCHASED VALUES (?, ?, ?)')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $stmt->bindValue(2, $amount, SQLITE3_INTEGER);
    $stmt->bindValue(3, $date, SQLITE3_INTEGER);
    if(!$stmt->execute()) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Echo-ing user info
 */
if ($stmt = $db->prepare('SELECT * FROM USERS WHERE user_id=?')) {
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