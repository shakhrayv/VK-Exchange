<?php

require 'common.php';

header('content-type: application/json');
ob_start();


/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

/*
 * Adding columns
 */
if ($stmt = $db->prepare("CREATE TABLE 'COMPLETED_INACTIVE' ('user_id'	INTEGER NOT NULL,'order_id'	TEXT NOT NULL,'automatic'	INTEGER DEFAULT 0,'type'	TEXT NOT NULL,'owner_id'	INTEGER NOT NULL,'id'	INTEGER NOT NULL,'date_completed'	INTEGER DEFAULT 0);")) {
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('success', $db);

?>