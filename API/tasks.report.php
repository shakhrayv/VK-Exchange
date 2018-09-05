<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "2ddad0338703e8a702d20152e70fa91c0e74e0fd75d44aedda82a499bedee562";
//NSMutableURLRequest

/*
 * Checking if all parameters are passed
*/
if (!check_params(array('token', 'user_id', 'owner_id', 'type', 'pass'))) {
    show_error();
}

$token = $_GET['token'];
$user_id = $_GET['user_id'];
$order_id = $_GET['order_id'];
$type = $_GET['type'];
$should_reward = $_GET['should_reward'];
$automatic = $_GET['automatic'];
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array($token, $user_id, $order_id, $type, $should_reward, $automatic), $key, $pass)) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

add_id($db, $token, 'token');
change_last_active_date($db, $user_id);

/*
 * Checking if the record exists, and adding to completed
 */
if ($stmt = $db->prepare('INSERT OR FAIL INTO COMPLETED VALUES (?, ?, ?)')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $stmt->bindValue(2, $order_id, SQLITE3_TEXT);
    $stmt->bindValue(3, $automatic, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

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
if ($stmt = $db->prepare('INSERT INTO SUSPENDED_TASKS SELECT * FROM ACTIVE_TASKS WHERE completed=quantity')) {
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
if ($stmt = $db->prepare('DELETE FROM ACTIVE_TASKS WHERE completed=quantity')) {
    $stmt->bindValue(1, $order_id, SQLITE3_TEXT);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Rewarding user if needed
 */
if ($should_reward) {
    $reward = 0;
    if ($type=='photo') {
        $reward = 1;
    } elseif ($type=='subscriber') {
        $reward = 3;
    }
    if ($stmt = $db->prepare('UPDATE OR FAIL USERS SET balance=balance+? WHERE user_id=?')) {
        $stmt->bindValue(1, $reward, SQLITE3_INTEGER);
        $stmt->bindValue(2, $user_id, SQLITE3_INTEGER);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);}
    } else {
        rollback_transaction($db);
    }
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