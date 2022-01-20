<?php

//SQL request για αρχικοποίηση του πίκανα board
function reset_board() {
	global $mysqli;
	$sql = 'call clean_board()';
	$mysqli->query($sql);
}

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

	if ($player_number=='p1') {
		$sql = "UPDATE `board` SET p1_choice=? WHERE match_id=(SELECT MAX(match_id) FROM board);";
		$opponent = 'p2';
	} else {
		$sql = "UPDATE `board` SET p2_choice=? WHERE match_id=(SELECT MAX(match_id) FROM board);";
		$opponent = 'p1';
	}
	$st = $mysqli->prepare($sql);
	$st->bind_param('i',$choice);
	$st->execute();


	$sql = 'UPDATE `game_status` set player_turn=?;';
	$st = $mysqli->prepare($sql);
	$st->bind_param('s',$opponent);
	$st->execute();

	check_winner();

}

function check_winner() {
	global $mysqli;
	$st3=$mysqli->prepare('select count(*) as choices from board WHERE p1_choice is not null and p2_choice is not null');
	$st3->execute();
	$res3 = $st3->get_result();
	$choices = $res3->fetch_assoc()['choices'];
	if($choices>0) {
		$sql = 'select * from board';
		$st = $mysqli->prepare($sql);
		$st->execute();
		$res = $st->get_result();
		$board = $res->fetch_assoc();


		$winner=null; 
		$winner_text=null;

		if ($board['p1_choice'] != $board['p2_choice']) {

			if ($board['p1_choice']==1) {
				if ($board['p2_choice']==3){
					$winner='p1'; $winner_text='Rock crushes Scissors';
				} else if ($board['p2_choice']==4){
					$winner='p1'; $winner_text='';
				} else if ($board['p2_choice']==2){
					$winner='p2'; $winner_text='Paper covers Rock';
				} else if($board['p2_choice']==5){
					$winner='p2'; $winner_text='Spock vaporizes Rock';
				}
			}

			if ($board['p1_choice']==2) {
				if ($board['p2_choice']==3){
					$winner='p2'; $winner_text='Scissors cuts Paper';
				} else if ($board['p2_choice']==4){
					$winner='p2'; $winner_text='Lizard eats Paper';
				} else if ($board['p2_choice']==1){
					$winner='p1'; $winner_text='Paper covers Rock';
			}
			}

			if ($board['p1_choice']==3) {
				if ($board['p2_choice']==2){
					$winner='p1'; $winner_text='Scissors cuts Paper';
				} else if ($board['p2_choice']==4){
					$winner='p1'; $winner_text='Scissors decapitates Lizard';
				} else if ($board['p2_choice']==1){
					$winner='p2'; $winner_text='Rock crushes Scissors';
				} else if($board['p2_choice']==5){
					$winner='p2'; $winner_text='Spock smashes Scissors';
				}
			}

			if ($board['p1_choice']==4) {
				if ($board['p2_choice']==1){
					$winner='p2'; $winner_text='Rock crushes Lizard';
				} else if ($board['p2_choice']==3){
					$winner='p2'; $winner_text='Scissors decapitates Lizard';
				} else if ($board['p2_choice']==2){
					$winner='p1'; $winner_text='Lizard eats Paper';
				} else if($board['p2_choice']==5){
					$winner='p1'; $winner_text='Lizard poisons Spock';
				}
			}

			if ($board['p1_choice']==5) {
				if ($board['p2_choice']==1){
					$winner='p1'; $winner_text='Spock vaporizes Rock';
				} else if ($board['p2_choice']==3){
					$winner='p1'; $winner_text='Spock smashes Scissors';
				} else if ($board['p2_choice']==2){
					$winner='p2'; $winner_text='Paper disproves Spock';
				} else if($board['p2_choice']==4){
					$winner='p2'; $winner_text='Lizard poisons Spock';
				}
			}

		} else {
			$winner='D'; $winner_text='';
		}

		$sql = "UPDATE game_status SET result=?, result_text=?, status='ended'";
		$st = $mysqli->prepare($sql);
		$st->bind_param('ss',$winner,$winner_text);
		$st->execute();

	}
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