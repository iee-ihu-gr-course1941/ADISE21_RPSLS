var me={ nickname: null, token: null, player_number: null };
var score={ me: 0, opponent: 0}
var game_status={};
var timer=null;
var notify_modal = new bootstrap.Modal(document.getElementById("notify_modal"), {});

$(function() {

    $('#login').click(login_to_game);
    $('#reset_game').hide();
    $('#playerControls').hide();
    $('#gameInstructions').hide();


    $('#Rock').on('click', function(){ do_move(1); });
    $('#Paper').on('click', function(){ do_move(2); });
    $('#Scissors').on('click', function(){ do_move(3); });
    $('#Lizard').on('click', function(){ do_move(4); });
    $('#Spock').on('click', function(){ do_move(5); });


	$('#reset_game').on('click', function(){ reset_board(); });
});

function login_to_game() {
	if($('#username').val()=='') {
		notify("You have to set a username!");
		return;
	} 

	
	$.ajax({url: "rpsls.php/players/", 
			method: 'POST',
			dataType: 'json',
			headers: {"X-Token": me.token},
			contentType: 'application/json',
			data: JSON.stringify( {
				username: $('#username').val(), 
				player_number: $('#player_select').val()
			}),
			success: login_result,
			error: show_error});
	
}


//Ενημέρωση παιχτών για τα στοιχεία τους
function update_info(){
	if (me.player_number == game_status.player_turn){
		document.getElementById("Rock").classList.remove("disabled");
		document.getElementById("Paper").classList.remove("disabled");
		document.getElementById("Scissors").classList.remove("disabled");
		document.getElementById("Lizard").classList.remove("disabled");
		document.getElementById("Spock").classList.remove("disabled");
	}else {
		document.getElementById("Rock").classList.add("disabled");
		document.getElementById("Paper").classList.add("disabled");
		document.getElementById("Scissors").classList.add("disabled");
		document.getElementById("Lizard").classList.add("disabled");
		document.getElementById("Spock").classList.add("disabled");
	}


	if (me.player_number =='p1'){
		player='Player 1';
	}else {player='Player 2';}


	if (game_status.player_turn=='p1'){
		player_turn='Player 1';
	}else { player_turn='Player 2';}
	

	if(game_status.status=='started' && me.token!=null){
		$('#game_info').html("<h4><b> Score:</h4></b>" + me.username + ": " + score.me + "</br>Opponent: " + score.opponent + '<br/> <br/> <h4>Game Status:</h4>Game state: '
        + game_status.status + '<b>');


		$('#player_turn').html("<h6> It's " + player_turn +'</b> turn to play now.</h6>');
	}else{
		$('#game_info').html("<h4><b> Score:</h4></b>"  + me.username + ": " + score.me + "</br>Opponent: " + score.opponent + '<br/> <br/> <h4>Game Status:</h4>Game state: '+ game_status.status);
        $('#player_turn').html("<h6>Playing as " + player + "</h6>");
    }
}

//Εισαγωγή των στοιχείων του παίχτη και ενημέρωση του games_status
function login_result(data) {
	me = data[0];
	$('#loginCol').hide();
    $('#reset_game').show();
    $('#playerControls').show();
    $('#gameInstructions').show();

	//Ξεκινάμε listener που κάνει reset το παιχνίδι όταν ο χρήστης κάνει refresh ή κλήση την σελίδα
	window.addEventListener("beforeunload", function(e){
		reset_board();
	 }, false);

	update_info();
	game_status_update();
}

//Ajax request για game_status
function game_status_update() {
	clearTimeout(timer);

	$.ajax({url: "rpsls.php/status/", 
	success: update_status, 
	headers: {"X-Token": me.token}});
}


//Ajax request για κίνηση
function do_move(choice) {
	//
}

function reset_board() {
	clearTimeout(timer);
	if (game_status.status!='not active') {
		$.ajax({url: "rpsls.php/board/",
		headers: {"X-Token": me.token},
		method: 'POST'});
	}
	me = { nickname: null, token: null, color_picked: null };

    $('#reset_game').hide(150);
    $('#playerControls').hide(150);
    $('#gameInstructions').hide(150);
    $('#loginCol').show(500);
}

function show_error(data) {
	var x = data.responseJSON;
	alert(x.errormesg);
}

function notify(text) {
	alert(text);
}