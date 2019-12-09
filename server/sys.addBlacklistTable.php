<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "5JniXUaITKNBWIuRn0OCKn9ZBLXTAIhpbqEw3q5EbJPTxoCBMKrGgADGTBz0ZQ";

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
if ($stmt = $db->prepare('CREATE TABLE IF NOT EXISTS "BLACKLIST" ( "user_id" integer NOT NULL,"type" text NOT NULL,"id" integer NOT NULL);')) {
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('success', $db);

?>