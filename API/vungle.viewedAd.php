<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "yrcgUz03HOASEkql8o3ejnQ9By8o9/Ig6oU01W46cGc=";

$reward = $_GET['amount'];
$txid = $_GET['txid'];
$digest = $_GET['digest'];
$user_id = $_GET['uid'];

/*
 * Verifying hash

$test_string = $key.":".$txid;
$test_result = hash('sha256', $test_string);
$test_result = hash('sha256', $test_result);
if($test_result != $digest) {
    show_error();
}
*/

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

add_id($db, $txid, 'transaction');

/*
 * Adding money to user
 */
if ($stmt = $db->prepare('UPDATE OR FAIL USERS SET balance=balance+? WHERE user_id=?')) {
    $stmt->bindValue(1, 5, SQLITE3_INTEGER);
    $stmt->bindValue(2, $user_id, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

mylog("money_added");

commit_transaction('', $db);

?>