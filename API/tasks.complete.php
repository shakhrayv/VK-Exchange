<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "cc1e29d80ca6b39c0498c7afb0dbd122f0f941a42a0f0720451fd5b48bf3f0cc";

/*
 * Checking if all parameters are passed
*/
if (!check_params(array('token', 'user_id', 'order_id', 'type', 'should_reward', 'automatic', 'pass'))) {
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
 * Checking if the record exists, and adding to completed_active
 */
if ($stmt = $db->prepare('INSERT OR FAIL INTO COMPLETED_ACTIVE VALUES (?,?,?,?,(SELECT owner_id FROM ACTIVE_TASKS WHERE order_id=?),(SELECT id FROM ACTIVE_TASKS WHERE order_id=?),?)')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $stmt->bindValue(2, $order_id, SQLITE3_TEXT);
    $stmt->bindValue(3, $automatic, SQLITE3_INTEGER);
    $stmt->bindValue(4, $type, SQLITE3_TEXT);
    $stmt->bindValue(5, $order_id, SQLITE3_TEXT);
    $stmt->bindValue(6, $order_id, SQLITE3_TEXT);
    $stmt->bindValue(7, time(), SQLITE3_INTEGER);
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

/*
 * Rewarding user if needed
 */
if ($should_reward) {
    $reward = 0;
    if ($type=='photo') {
        $reward = 1;
    } elseif ($type=='subscriber') {
        $reward = 3;
    } elseif ($type=='repost') {
        $reward = 7;
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
 * Adding tasks to completed_inactive if no tasks are present
 */
if ($stmt = $db->prepare('INSERT INTO COMPLETED_INACTIVE (user_id, order_id, automatic, type, owner_id, id, date_completed) SELECT user_id, order_id, automatic, type, owner_id, id, date_completed FROM COMPLETED_ACTIVE WHERE NOT EXISTS (SELECT * FROM ACTIVE_TASKS WHERE ACTIVE_TASKS.type=COMPLETED_ACTIVE.type AND ACTIVE_TASKS.owner_id=COMPLETED_ACTIVE.owner_id AND ACTIVE_TASKS.id=COMPLETED_ACTIVE.id)')) {
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Deleting from completed_active if no tasks are present
 */
if ($stmt = $db->prepare('DELETE FROM COMPLETED_ACTIVE WHERE NOT EXISTS (SELECT * FROM ACTIVE_TASKS WHERE ACTIVE_TASKS.type=COMPLETED_ACTIVE.type AND ACTIVE_TASKS.owner_id=COMPLETED_ACTIVE.owner_id AND ACTIVE_TASKS.id=COMPLETED_ACTIVE.id)')) {
    $res = $stmt->execute();
    if (!$res) {
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