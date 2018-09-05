<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "31bef8e13c3b84b46f1e520c80ee542b12fdfd47298d64e1fd09aa9e93b9233b";
//NSSet

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
 * Checking if user should be rewarded
 */
if ($stmt = $db->prepare('SELECT * FROM USERS WHERE user_id=?')) {
    $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if(!$res){
        rollback_transaction($db);
    }
    $row = $res->fetchArray(SQLITE3_ASSOC);
    if ($row) {
        $dt = $row['last_reward_date'];
        $est = time()-$dt;
        $should_reward = true;
        if ($est < 60*60*24) {
            $should_reward = false;
        }
        if ($should_reward) {
            if ($stmt3 = $db->prepare('UPDATE USERS SET balance=balance+15 WHERE user_id=?')) {
                $stmt3->bindValue(1, $user_id, SQLITE3_INTEGER);
                if (!$stmt3->execute()) {
                    rollback_transaction($db);
                } else {
                    if ($stmt2 = $db->prepare('UPDATE USERS SET last_reward_date=? WHERE user_id=?')) {
                        $stmt2->bindValue(1, time(), SQLITE3_INTEGER);
                        $stmt2->bindValue(2, $user_id, SQLITE3_INTEGER);
                        if (!$stmt2->execute()) {
                            rollback_transaction($db);
                        } else {
                            commit_transaction(json_encode(array('response' => 1)), $db);
                        }
                    } else {
                        rollback_transaction($db);
                    }
                }
            } else {
                rollback_transaction($db);
            }
        } else {
            commit_transaction(json_encode(array('response'=>0)), $db);
        }
    } else {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

?>