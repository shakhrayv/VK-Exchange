<?php


require 'common.php';

header('content-type: application/json');
ob_start();

$key = "I0PrKXY0uZp3NgeRi49fflgBGTW2CxC5GRLvZY1QiyKuNsCEp2daf94tXlk4Xp";

/*
 * Opening database
 */
$db = open_database();
begin_transaction($db);

/*
 * Clearing IDs
 */
$days = 1;
$deadline = time()-$days*24*60*60;
if ($stmt = $db->prepare('DELETE FROM IDS')) {
    $stmt->bindValue(1, $deadline, SQLITE3_INTEGER);
    $res = $stmt->execute();
    if (!$res) {
        rollback_transaction($db);
    }
} else {
    rollback_transaction($db);
}

commit_transaction('success', $db);

?>