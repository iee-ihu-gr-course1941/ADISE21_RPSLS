<?php

require_once "../lib/dbconnect.php";
require_once "../lib/board.php";
require_once "../lib/game.php";
require_once "../lib/user.php";

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/',trim($_SERVER['PATH_INFO'],'/'));
$input = json_decode(file_get_contents('php://input'),true);
if(isset($_SERVER['HTTP_X_TOKEN'])) {
	$input['token']=$_SERVER['HTTP_X_TOKEN'];
}

switch ($r=array_shift($request)){
	case 'board':
		switch($b=array_shift($request)){
			case '':
			case null: 
				break;
			default:
				header("HTTP/1.1 404 Not Found");
				break;
		}
		break;
	case 'players':
			handle_player($method,$request,$input);
			break;
	case 'status':
		
		break;

	default:
		header("HTTP/1.1 404 Not Found");
		exit;
}

function handle_player($method, $request,$input) {
	switch ($b=array_shift($request)) {
		case '':
		case null:
			if($method=='GET'){
				//show
			}else if($method=='POST'){
				handle_user($method, $b,$input);
			}else{
				print json_encode(['errormesg'=>"Method $method not allowed here."]);
			}
            break;
		default: 
			header("HTTP/1.1 404 Not Found");
			print json_encode(['errormesg'=>"Player $b not found."]);
            break;
	}
}
?>