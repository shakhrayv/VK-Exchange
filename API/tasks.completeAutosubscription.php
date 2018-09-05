<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "611e74550a687535a61174a7c7cbd7a36b3560f6f85ce711a969df139af007a1";
//NSTimer

/*
 * Checking if all parameters are passed
*/
if (!check_params(array('order_id', 'key'))) {
    show_error();
}

$key_ = $_GET['key'];
$order_id = $_GET['order_id'];

/*
 * Checking SHA
 */
if ($key!=$key_) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

/*
 * Updating tasks (adding 1 to completed if needed)
 */
if ($stmt = $db->prepare('UPDATE ACTIVE_TASKS SET completed=completed+1 WHERE order_id=? AND completed<quantity')) {
    $stmt->bindValue(1, $order_id, SQLITE3_TEXT);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Updating tasks (suspending task if fully completed)
 */
if ($stmt = $db->prepare('INSERT INTO SUSPENDED_TASKS SELECT order_id,priority,type,id,owner_id,?,quantity,completed FROM ACTIVE_TASKS WHERE completed=quantity')) {
    $stmt->bindValue(1, time(), SQLITE3_INTEGER);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Deleting suspended tasks from active tasks
 */
if ($stmt = $db->prepare('DELETE FROM ACTIVE_TASKS WHERE completed=quantity')) {
    $stmt->bindValue(1, $order_id, SQLITE3_TEXT);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

?>