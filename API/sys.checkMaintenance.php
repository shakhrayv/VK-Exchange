<?php

$maintenance = 1;
header('content-type: application/json');
echo json_encode(array("response"=>$maintenance));

?>