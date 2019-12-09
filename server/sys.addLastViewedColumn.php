<?php

require 'common.php';

header('content-type: application/json');
ob_start();

$key = "zzcFHsK1coNSenI6zFni2bCAlyBso7GtO6CevY21ook86rfeRNHGrexnLDSq5j";

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
if ($stmt = $db->prepare('ALTER TABLE VIEWED ADD COLUMN date integer DEFAULT(1460888658)')) {
    $res = $stmt->execute();
    if(!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('success', $db);

?>