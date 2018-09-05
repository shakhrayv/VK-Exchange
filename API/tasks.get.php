<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "8fbe9a250d6b8181bab353db21769c4a6f0497dd0fd67ae02af849d3894a03f1";

/*
 * Checking if all parameters are passed
*/
if (!check_params(array('token', 'user_id', 'types', 'pass'))) {
    show_error();
}

$token = $_GET['token'];
$user_id = $_GET['user_id'];
$types = explode(',', $_GET['types']);
$pass = $_GET['pass'];

/*
 * Checking SHA
 */
if (!check_sha512(array_merge(array($token, $user_id), $types), $key, $pass)) {
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
 * Deleting photos (suspending if not completed)
 */
//25
$t = time();
$qstring = "DELETE FROM ACTIVE_TASKS WHERE type='photo' AND date_added <= $t-86400 AND 25*$t>completed*86400+25*date_added;";
if ($stmt = $db->prepare($qstring)) {
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Deleting subscribers (suspending if not completed)
 */
//15
$t = time();
$qstring = "DELETE FROM ACTIVE_TASKS WHERE type='subscriber' AND date_added <= $t-86400 AND 15*$t>completed*86400+15*date_added;";
if ($stmt = $db->prepare($qstring)) {
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Deleting reposts (suspending if not completed)
 */
//10
$t = time();
$qstring = "DELETE FROM ACTIVE_TASKS WHERE type='repost' AND date_added <= $t-86400 AND 10*$t>completed*86400+10*date_added;";
if ($stmt = $db->prepare($qstring)) {
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

/*
 * Getting tasks (depending on types)
 */
$conditions = array();
if (in_array('photo', $types)) {
    array_push($conditions, "(type='photo')");
}
if (in_array('subscriber', $types)) {
    array_push($conditions, "(type='subscriber')");
}
if (in_array('repost', $types)) {
    array_push($conditions, "(type='repost')");
}
$query="SELECT * FROM ACTIVE_TASKS WHERE ((".(implode(' OR ', $conditions)).") AND NOT EXISTS (SELECT * FROM COMPLETED_ACTIVE WHERE ACTIVE_TASKS.owner_id=COMPLETED_ACTIVE.owner_id AND ACTIVE_TASKS.type=COMPLETED_ACTIVE.type AND ACTIVE_TASKS.id=COMPLETED_ACTIVE.id AND COMPLETED_ACTIVE.user_id=?) AND owner_id<>?) ORDER BY date_last_viewed ASC";

if ($stmt=$db->prepare($query)) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $stmt->bindValue(2, $user_id, SQLITE3_INTEGER);
    $stmt->bindValue(3, $user_id, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
    $row = $res->fetchArray(SQLITE3_ASSOC);
    if (!$row) {
        commit_transaction(json_encode(array('response'=>array('count'=>0))), $db);
    }
    $id = $row['id'];
    $type = $row['type'];
    if ($stmt=$db->prepare('UPDATE ACTIVE_TASKS SET date_last_viewed=? WHERE type=? AND id=?')) {
        $stmt->bindValue(1, time(), SQLITE3_INTEGER);
        $stmt->bindValue(2, $row['type'], SQLITE3_TEXT);
        $stmt->bindValue(3, $row['id'], SQLITE3_INTEGER);
        if (!$stmt->execute()) {
            rollback_transaction($db);
        } else {
            commit_transaction(json_encode(array('response'=>array('count'=>1, 'task'=>$row))), $db);
        }
    } else {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

?>