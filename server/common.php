<?php

$date = time();

class MyDB extends SQLite3
{
    function __construct($mode = SQLITE3_OPEN_READWRITE) {
        $this->open('MyDB.db', $mode);
        $this->busyTimeout(5000);
        $this->exec('pragma journal_mode=WAL;');
    }
}

function check_ban($user_id, $db) {
    if ($stmt = $db->prepare('SELECT * FROM USERS WHERE user_id = ? AND banned=1')) {
        $stmt->bindValue(1, $user_id, SQLITE3_INTEGER);
        $res = $stmt->execute();
        if(!$res) {
            rollback_transaction($db);
        }
        $row = $res->fetchArray(SQLITE3_ASSOC);
        if ($row) {
            die;
        }
    } else {
        rollback_transaction($db);
    }
}

function begin_transaction(MyDB $db) {
    $db->exec('BEGIN TRANSACTION');
}

function rollback_transaction(MyDB $db, $code = NULL) {
    $db->exec('ROLLBACK');
    $db = null;
    show_error($code);
}

function rollback_with_message(MyDB $db, $msg) {
    $db->exec('ROLLBACK');
    $db = null;
    ob_end_clean();
    echo $msg;
    die;
}

function commit_transaction($s, MyDB $db, $d=true) {
    $db->exec('COMMIT');
    $db = null;
    ob_end_clean();
    echo $s;
    if (!$d) {
        return;
    }
    die;
}

function add_id (MyDB $db, $token, $identifier) {
    if ($stmt = $db->prepare('INSERT OR FAIL INTO IDS VALUES (?,?,?)')) {
        $stmt->bindValue(1, $token, SQLITE3_TEXT);
        $stmt->bindValue(2, $identifier, SQLITE3_TEXT);
        $stmt->bindValue(3, time(), SQLITE3_INTEGER);
        if(!$stmt->execute()) {
            rollback_transaction($db);
        }
    } else {
        rollback_transaction($db);
    }
}

function change_last_active_date(MyDB $db, $user_id) {
    if ($stmt = $db->prepare('UPDATE USERS SET last_active_date=? WHERE user_id=?')) {
        $stmt->bindValue(1, time(), SQLITE3_INTEGER);
        $stmt->bindValue(2, $user_id, SQLITE3_INTEGER);
        if(!$stmt->execute()) {
            rollback_transaction($db);
        }
    } else {
        rollback_transaction($db);
    }
}

function open_database($mode = NULL) {
    $db = NULL;
    if ($mode) {
        $db = new MyDB($mode);
    } else {
        $db = new MyDB();
    }
    if ($db)
        return $db;
    show_error();
}

function show_error($code = 1) {
    ob_end_clean();
    if ($code==null) {
        $code = 1;
    }
    echo json_encode(array('error'=>$code));
    die;
}


function mylog ($s) {
    file_put_contents('error_log.txt', file_get_contents('error_log.txt').$s);
}


function check_params ($names) {
    for ($i = 0; $i < count($names); $i++) {
        if (!isset($_GET[$names[$i]])) {
            return false;
        }
    }
    return true;
}

function check_sha512($params, $key, $pass) {
    return $pass==hash('sha512', implode($params).$key);
}

function generate_order_id ($length = 8) {
    $characters = '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ';
    $characters_length = strlen($characters);
    $random_string = '';
    for ($i = 0; $i < $length; $i++) {
        $random_string .= $characters[rand(0, $characters_length - 1)];
    }
    return $random_string;
}

function generate_personal_code ($postfix=4) {
    $letters = 'ABCDEFGHIJKLMNPQRSTUVWXYZ';
    $numbers = '123456789';
    $letters_length = strlen($letters);
    $numbers_length = strlen($numbers);
    $random_string = $letters[rand(0, $letters_length-1)];
    for ($i = 0; $i < $postfix; $i++) {
        $random_string .= $numbers[rand(0, $numbers_length - 1)];
    }
    return $random_string;
}


?>