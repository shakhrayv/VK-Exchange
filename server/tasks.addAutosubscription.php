<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "22dd9763b2860644e1085b14837f831e112bbd9fa90312cfb4981d439cac50ea";
// UITabBarController

/*
 * Checking if all parameters are passed
 */
if (!check_params(array('token', 'owner_id', 'quantity', 'pass'))) {
    show_error();
}

$token = $_GET['token'];
$owner_id = $_GET['owner_id'];
$quantity = $_GET['quantity'];
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array($token, $owner_id, $quantity), $key, $pass)) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

add_id($db, $token, 'autosubscription');

/*
 * Checking if user has enough money, adding the task
 */
$required = $prices[array_search($quantity, $amounts)];
if ($stmt = $db->prepare('INSERT OR FAIL INTO ACTIVE_TASKS (order_id, type, id, owner_id, date_added, quantity, priority) VALUES (?, ?, ?, ?, ?, ?, ?)')) {
    $stmt->bindValue(1, generate_order_id(), SQLITE3_TEXT);
    $stmt->bindValue(2, 'autosubscription', SQLITE3_TEXT);
    $stmt->bindValue(3, $owner_id, SQLITE3_INTEGER);
    $stmt->bindValue(4, $owner_id, SQLITE3_INTEGER);
    $stmt->bindValue(5, time(), SQLITE3_INTEGER);
    $stmt->bindValue(6, $quantity, SQLITE3_INTEGER);
    $stmt->bindValue(7, 0, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

?>