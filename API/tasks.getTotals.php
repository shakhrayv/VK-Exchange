<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = '63136610e8e28220131d4635af06fd2f13bc8242efe47a7eff9faf27b074e019';

/*
 * Checking if all parameters are passed
*/
if (!check_params(array('user_id', 'type', 'pass'))) {
    show_error();
}
$user_id = $_GET['user_id'];
$type = $_GET['type'];
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array($user_id, $type), $key, $pass)) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

change_last_active_date($db, $user_id);

/*
 * Searching for tasks totals if type is 'photo'
 */
if ($type == 'photo') {
    $totals = array();
    if ($stmt = $db->prepare('SELECT * FROM SUSPENDED_TASKS WHERE owner_id=? and type=?')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, 'photo', SQLITE3_TEXT);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);
        }
        $row = $res->fetchArray(SQLITE3_ASSOC);
        while ($row) {
            $item_id = $row['id'];
            $ordered = $row['quantity'];
            $completed = $row['completed'];
            if (array_key_exists($item_id, $totals)) {
                $totals[$item_id]['ordered']+=$ordered;
                $totals[$item_id]['completed']+=$completed;
            } else {
                $totals[$item_id] = array('ordered' => $ordered, 'completed' => $completed);
            }
            $row = $res->fetchArray(SQLITE3_ASSOC);
        }
    } else {
        rollback_transaction($db);
    }
    if ($stmt = $db->prepare('SELECT * FROM ACTIVE_TASKS WHERE owner_id=? and type=?')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, 'photo', SQLITE3_TEXT);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);
        }
        $row = $res->fetchArray(SQLITE3_ASSOC);
        while ($row) {
            $item_id = $row['id'];
            $ordered = $row['quantity'];
            $completed = $row['completed'];
            if (array_key_exists($item_id, $totals)) {
                $totals[$item_id]['ordered']+=$ordered;
                $totals[$item_id]['completed']+=$completed;
            } else {
                $totals[$item_id] = array('ordered' => $ordered, 'completed' => $completed);
            }
            $row = $res->fetchArray(SQLITE3_ASSOC);
        }
    } else {
        rollback_transaction($db);
    }
    commit_transaction(json_encode(array('response'=>array('count'=>count($totals), 'tasks'=>$totals))), $db);
}

/*
 * Searching for tasks totals if type is 'subscriber'
 */
if ($type == 'subscriber') {
    $totals = array('ordered'=>0, 'completed'=>0);
    if ($stmt = $db->prepare('SELECT * FROM SUSPENDED_TASKS WHERE owner_id=? AND type=?')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, 'subscriber', SQLITE3_TEXT);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);
        }
        while ($row = $res->fetchArray(SQLITE3_ASSOC)) {
            $ordered = $row['quantity'];
            $completed = $row['completed'];
            $totals['ordered']+=$ordered;
            $totals['completed']+=$completed;
        }
    } else {
        rollback_transaction($db);
    }
    if ($stmt = $db->prepare('SELECT * FROM ACTIVE_TASKS WHERE owner_id=? AND type=?')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, 'subscriber', SQLITE3_TEXT);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);
        }
        while ($row = $res->fetchArray(SQLITE3_ASSOC)) {
            $ordered = $row['quantity'];
            $completed = $row['completed'];
            $totals['ordered'] += $ordered;
            $totals['completed'] += $completed;
        }
    } else {
        rollback_transaction($db);
    }
    commit_transaction(json_encode(array('response'=>array($totals))), $db);
}

/*
 * Searching for tasks totals if type is 'repost'
 */
if ($type == 'repost') {
    $totals = array();
    if ($stmt = $db->prepare('SELECT * FROM SUSPENDED_TASKS WHERE owner_id=? and type=?')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, 'repost', SQLITE3_TEXT);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);
        }
        $row = $res->fetchArray(SQLITE3_ASSOC);
        while ($row) {
            $item_id = $row['id'];
            $ordered = $row['quantity'];
            $completed = $row['completed'];
            if (array_key_exists($item_id, $totals)) {
                $totals[$item_id]['ordered']+=$ordered;
                $totals[$item_id]['completed']+=$completed;
            } else {
                $totals[$item_id] = array('ordered' => $ordered, 'completed' => $completed);
            }
            $row = $res->fetchArray(SQLITE3_ASSOC);
        }
    } else {
        rollback_transaction($db);
    }
    if ($stmt = $db->prepare('SELECT * FROM ACTIVE_TASKS WHERE owner_id=? and type=?')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $stmt->bindValue(2, 'repost', SQLITE3_TEXT);
        $res = $stmt->execute();
        if (!$res) {
            rollback_transaction($db);
        }
        $row = $res->fetchArray(SQLITE3_ASSOC);
        while ($row) {
            $item_id = $row['id'];
            $ordered = $row['quantity'];
            $completed = $row['completed'];
            if (array_key_exists($item_id, $totals)) {
                $totals[$item_id]['ordered']+=$ordered;
                $totals[$item_id]['completed']+=$completed;
            } else {
                $totals[$item_id] = array('ordered' => $ordered, 'completed' => $completed);
            }
            $row = $res->fetchArray(SQLITE3_ASSOC);
        }
    } else {
        rollback_transaction($db);
    }
    commit_transaction(json_encode(array('response'=>array('count'=>count($totals), 'tasks'=>$totals))), $db);
}

rollback_transaction($db);



?>
