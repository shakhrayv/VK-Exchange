<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "r8tbrGcMc0Wv0JcKEmSOvHePN1ZYW5RHYvRtgKqsLvE3iEJjSz7FnV2I1tOgmR";

if (!check_params(array('user_id', 'key'))) {
    show_error();
}

$user_id = $_GET['user_id'];
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
if ($stmt = $db->prepare('DELETE FROM SUSPENDED_TASKS WHERE owner_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_TEXT);
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
if ($stmt = $db->prepare('DELETE FROM ACTIVE_TASKS WHERE owner_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_TEXT);
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
if ($stmt = $db->prepare('DELETE FROM COMPLETED_ACTIVE WHERE owner_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_TEXT);
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
if ($stmt = $db->prepare('DELETE FROM COMPLETED_INACTIVE WHERE owner_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_TEXT);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}
commit_transaction('ok', $db);