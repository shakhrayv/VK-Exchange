<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "236c8912798067c4b24c72f6ac5f4f0be038cd60813cebaf042612d321191a55";

/*
 * Checking if all parameters are passed
 */
if (!check_params(array('token', 'user_id', 'pass'))) {
    show_error();
}

$token = $_GET['token'];
$user_id = $_GET['user_id'];
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array($token, $user_id), $key, $pass)) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

add_id($db, $token, 'token');

/*
 * Setting user money to default if user was not authorized before
 */
$default_money = 30;
$default_privileged = 1;
if ($stmt = $db->prepare('INSERT OR IGNORE INTO USERS (user_id, balance, date_registered, last_active_date,privileged, last_reward_date) VALUES(?,?,?,0,?,?)')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $stmt->bindValue(2, $default_money, SQLITE3_INTEGER);
    $stmt->bindValue(3, $date, SQLITE3_INTEGER);
    $stmt->bindValue(4, $default_privileged, SQLITE3_INTEGER);
    $stmt->bindValue(5, $date, SQLITE3_INTEGER);
    if(!$stmt->execute()) {
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
        commit_transaction(json_encode($row), $db);
    } else {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

?>