<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "9b84973dae9bfd3e1068330723fa06ce7119bfd704dca784a2375e4370258581";

$user_id = $_GET['user_id'];

if ($key!= $_GET['key']) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

$query="SELECT * FROM ACTIVE_TASKS WHERE type=?";
if ($stmt=$db->prepare($query)) {
    $stmt->bindValue(1, 'autosubscription', SQLITE3_TEXT);
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
    $row = $res->fetchArray(SQLITE3_ASSOC);
    if (!$row) {
        commit_transaction(json_encode(array('response'=>array('count'=>0))), $db);
    }
    commit_transaction(json_encode(array('response'=>array('count'=>1, 'task'=>$row))), $db);
} else {
    rollback_transaction($db);
}

?>