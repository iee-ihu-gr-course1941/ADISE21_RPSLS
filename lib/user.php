<?php


//Έλεγχος εάν η method είναι POST/GET
function handle_user($method, $b,$input) {
	if($method=='GET') {
		header("HTTP/1.1 400 Bad Request");
	} else if($method=='POST') {
        set_user($input);
    }
}

//η μέθοδος απο loginuser με διάφορους ελέγχους
function set_user($input) {
	if(!isset($input['username'])) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"No username given."]);
		exit;
	}

	$username=$input['username'];
	$player_number=$input['player_number'];
	
	global $mysqli;
	
	//Έλεγχος εάν υπάρχουν ήδη παίχτες που παίζουν.
	$sql = 'select count(*) as c from players where username is not null';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	$r = $res->fetch_all(MYSQLI_ASSOC);
	if ($r[0]['c']==2){
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Other players have started the game already."]);
		exit;
	}

	//Έλεγχος εάν υπάρχει ήδη ο παίχτης με το player_number.
	$player_number1 = substr($player_number, -1);
	global $mysqli;
	$sql = 'select count(*) as c from players where player_number=? and username is not null';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$player_number);
	$st->execute();
	$res = $st->get_result();
	$r = $res->fetch_all(MYSQLI_ASSOC);
	if($r[0]['c']>0) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Player $player_number1 is already set. Please select another player number."]);
		exit;
	}

	$sql = 'update players set username=?, token=md5(CONCAT( ?, NOW()))  where player_number=?';
	$st2 = $mysqli->prepare($sql);
	$st2->bind_param('sss',$username,$username,$player_number);
	$st2->execute();

	
	update_game_status();
	$sql = 'select * from players where player_number=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$player_number);
	$st->execute();
	$res = $st->get_result();
	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);
	
	
}