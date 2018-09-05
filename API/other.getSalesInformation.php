<?php

header('content-type: application/json');

$sales_in_progress = 0;
echo json_encode(array("response"=>$sales_in_progress));

?>