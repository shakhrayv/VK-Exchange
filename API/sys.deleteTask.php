<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "Gn5nyMiB71RjJsqbrvaL8B3aYaBG96WVX6ng19SlME0D6hNzxJeDKBDAuNtq0Q";

if (!check_params(array('order_id', 'key'))) {
    show_error();
}

$order_id = $_GET['order_id'];
$key_ = $_GET['key'];
if ($key!=$key_) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

/*
 * Updating tasks (suspending task if fully completed)
 */
if ($stmt = $db->prepare('DELETE FROM SUSPENDED_TASKS WHERE order_id=?')) {
    $stmt->bindValue(1, $order_id, SQLITE3_TEXT);
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
if ($stmt = $db->prepare('DELETE FROM ACTIVE_TASKS WHERE order_id=?')) {
    $stmt->bindValue(1, $order_id, SQLITE3_TEXT);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('ok', $db);