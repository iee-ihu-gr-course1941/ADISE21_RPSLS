<?php


//Έλεγχος για aborted και SQL request για επιστροφή του πίνακα game_status
function show_status() {
	
	global $mysqli;
	
	check_initialized();
	
	check_abort();

	$sql = 'select * from game_status';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();

	header('Content-type: application/json');
	print json_encode($res->fetch_all(MYSQLI_ASSOC), JSON_PRETTY_PRINT);

}

//SQL request για έλεγχο εάν ο αντίπαλος έχει ώρα να παίξει
function check_abort() {
	global $mysqli;

	$sql = "update game_status set status='aborded', result=if(player_turn='p1','p2','p1'), player_turn=null where player_turn is not null and last_change<(now()-INTERVAL 90 SECOND) and status='started'";
	$st = $mysqli->prepare($sql);
	$r = $st->execute();
}

//SQL request για έλεγχο εάν δεν βρήκε αντίπαλο μετα απο το deadline.
function check_initialized() {
	global $mysqli;
	$sql = "select count(*) as npf from game_status WHERE last_change<(now()-INTERVAL 60 SECOND) and status='initialized'";
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	$npf = $res->fetch_assoc()['npf'];
	if ($npf==1){

		$sql2 ="update game_status set status='not active'";
		$st2 = $mysqli->prepare($sql2);
		$st2->execute();
		$res2 = $st2->get_result();
		remove_user();
	}
	
}
//SQL request για επιστροφή του πίνακα game_status
function read_status() {
	global $mysqli;
	
	$sql = 'select * from game_status';
	$st = $mysqli->prepare($sql);

	$st->execute();
	$res = $st->get_result();
	$status = $res->fetch_assoc();
	return($status);
}


//Ενημερώνη το games_status ανάλογα το status.
function update_game_status() {
	global $mysqli;
	
	$status=read_status();
	$new_status=null;
	$new_turn=null;
	
	$st3=$mysqli->prepare('select count(*) as aborted from players WHERE last_action< (NOW() - INTERVAL 2 MINUTE)');
	$st3->execute();
	$res3 = $st3->get_result();
	$aborted = $res3->fetch_assoc()['aborted'];
	if($aborted>0) {
		if ($status['status']=='started' || $status['status']=='ended'){
			$sql = "UPDATE players SET username=NULL, token=NULL, last_action =NULL";
			$st2 = $mysqli->prepare($sql);
			$st2->execute();
		}
		if($status['status']=='started') {
			$new_status='aborted';
		}
	}
	
	
	$sql = 'select count(*) as c from players where username is not null';
	$st = $mysqli->prepare($sql);
	$st->execute();
	$res = $st->get_result();
	$active_players = $res->fetch_assoc()['c'];
	
	
	switch($active_players) {
		case 0:
			$new_status='not active'; 
			break;
		case 1:
			$new_status='initialized'; 
			break;
		case 2: 
			$new_status='started'; 
			if($status['player_turn']==null) {
				$random_turn=rand(1,2);
				if ($random_turn==1){	
					$new_turn='p1';
				}else{
					$new_turn='p2';
				}
				$sql = 'update players set last_action=(NOW());';
				$st = $mysqli->prepare($sql);
				$st->execute();
			}
			break;
			
	}

	$sql = 'update game_status set status=?, player_turn=?';
	$st = $mysqli->prepare($sql);
	$st->bind_param('ss',$new_status,$new_turn);
	$st->execute();
	
}


//SQL request για ενημέρωση του result του παιχνιδιού
function end_game($winner){
	global $mysqli;
	
	$sql = "update game_status set status='ended', result=?  where player_turn is not null and status='started'";
    $st = $mysqli->prepare($sql);
	$st->bind_param('s',$winner);
	$st->execute();
	show_status();
	
}