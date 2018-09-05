<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "P6aKeySN3XkSPIt2GqXYa36W8b59rRHazvq3iuo1ZAvRDdaNbemtUMmqgDkNCS";

/*
 * Checking if key is correct
 */
if ($_GET['key']!= $key) {
    show_error();
}

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

/*
 * Adding columns
 */
if ($stmt = $db->prepare('ALTER TABLE ACTIVE_TASKS ADD COLUMN reports integer DEFAULT(0)')) {
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}
if ($stmt = $db->prepare('ALTER TABLE ACTIVE_TASKS ADD COLUMN last_report_date integer DEFAULT(0)')) {
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('success', $db);

?>