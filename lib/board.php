<?php

//SQL request για αρχικοποίηση του πίκανα board
function reset_board() {
	global $mysqli;
	$sql = 'call clean_board()';
	$mysqli->query($sql);
}

//Έλεγχοι πρωτού κάνει την κίνηση
function make_move($choice,$player_number,$token) {
	
	if($token==null || $token=='') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Token is not set."]);
		exit;
	}
	
	$player = current_player($token);
	if($player==null ) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"You are not a player of this game."]);
		exit;
	}
	
	$status = read_status();
	if($status['status']!='started') {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"Game is not in action."]);
		exit;
	}
	
	if($status['player_turn']!=$player) {
		header("HTTP/1.1 400 Bad Request");
		print json_encode(['errormesg'=>"It is not your turn."]);
		exit;
	}
	
	do_move($choice,$player_number);
}

//Καλεί την stored precedure που κάνει την κίνηση του παίχτη
function do_move($choice,$player_number) {
	global $mysqli;
	$sql = 'call `make_move`(?,?);';
	$st = $mysqli->prepare($sql);
	$st->bind_param('is',$choice,$player_number);
	$st->execute();
}

//Καλεί την stored precedure που ετοιμάζει την βάση για δεύτερο παιχνίδι με τους ίδιους παίχτες
function play_again() {
	global $mysqli;
	$sql = 'call `play_again`();';
	$st = $mysqli->prepare($sql);
	$st->execute();
}

//Request για επιστροφή του board
function read_board() {
	global $mysqli;
	$sql = 'select * from board';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	return($res->fetch_all(MYSQLI_ASSOC));
}

?>