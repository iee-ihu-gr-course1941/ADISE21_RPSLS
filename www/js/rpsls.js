var me={ nickname: null, token: null, player_number: null };
var players;
var score={ me: 0, opponent: 0}
var game_status={};
var timer=null;
var last_update=new Date().getTime();
var notify_modal = new bootstrap.Modal(document.getElementById("notify_modal"), {});
var end_modal = new bootstrap.Modal(document.getElementById("end_modal"), {});
var surrendered=false;
var sounds=true;

const audioYouWin = document.querySelector("[data-sound=you-win]");
const audioYouLose = document.querySelector("[data-sound=you-lose]");

$(function() {

    $('#login').click(login_to_game);
    $('#reset_game').hide();
    $('#playerControls').hide();
    $('#gameInstructions').hide();

	//Sound Switch
	document.querySelector("#sound_switch").addEventListener("click", (e) => {
		sounds = !sounds;
	  });

    $('#Rock').on('click', function(){ do_move(1); });
    $('#Paper').on('click', function(){ do_move(2); });
    $('#Scissors').on('click', function(){ do_move(3); });
    $('#Lizard').on('click', function(){ do_move(4); });
    $('#Spock').on('click', function(){ do_move(5); });

	$('#reset_game').on('click', function(){ 
		surrendered=true;
		reset_board(); 
	});
});

//Ajax request για κίνηση
function do_move(choice) {
	player_number = me.player_number;

	$.ajax({url: "rpsls.php/board/make_move/", 
			method: 'POST',
			dataType: "json",
			headers: { "X-Token": me.token },
			contentType: 'application/json',
			data: JSON.stringify( {choice, player_number}),
			success: game_status_update});
}

function notify(title,body) {
	$("#notify_modal .modal-title").text(title);
	$("#notify_modal .modal-body").text(body);
	notify_modal.show();
}

//delay function για μέθοδο play_again (χρειάζεται μερικά ms για να διαβάσει το ανανεωμένο status)
function delay(time) {
	return new Promise(resolve => setTimeout(resolve, time));
  }

//Όταν πατήσει ο χρήστης Play Again
function play_again(title, won) {

	$("#end_modal .modal-title").text(title);
	
	// $("#end_modal .modal-header").classList.ädd("modal-header-success");

	$('#modal_quit').on('click', function(){ surrendered=true; update_info(); reset_board(); });

	$('#modal_play').on('click', function(){ 
		$.ajax({url: "rpsls.php/board/play_again/", 
		method: 'POST',
		dataType: "json",
		headers: { "X-Token": me.token },
		contentType: 'application/json',
		success: delay(500).then(() => game_status_update())});

		end_modal.hide();
	});

	if (won=="won") {
		document.getElementById('end_modal').querySelector(".modal-header").classList.remove("modal-header-danger", "modal-header-primary");
		document.getElementById('end_modal').querySelector(".modal-header").classList.add("modal-header-success");
	} else if (won=="lost") {
		document.getElementById('end_modal').querySelector(".modal-header").classList.remove("modal-header-success", "modal-header-primary");
		document.getElementById('end_modal').querySelector(".modal-header").classList.add("modal-header-danger");
	} else {
		document.getElementById('end_modal').querySelector(".modal-header").classList.remove("modal-header-success", "modal-header-danger");
		document.getElementById('end_modal').querySelector(".modal-header").classList.add("modal-header-primary");
	}

	end_modal.show();
}


//Ajax request για αρχικοποίηση του board
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

	game_status_update();
}

//Ajax request για το login
function login_to_game() {
	if($('#username').val()=='') {
		notify("Oh no!", "You have to set a username!");
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

function show_error(data) {
	var x = data.responseJSON;
	notify("Oh no",x.errormesg);
}

//Ajax request για game_status
function game_status_update() {
	clearTimeout(timer);

	$.ajax({url: "rpsls.php/status/", 
	success: update_status, 
	headers: {"X-Token": me.token}});
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

	if (players==null) {
		opponent="Opponent";
	} else {
		if (me.player_number=='p1') {
			opponent=players[1].username;
		} else if (me.player_number=='p2') {
			opponent=players[0].username;
		} 
	}

	if(game_status.status=='started' && me.token!=null){
		
		if (players==null) {
			$('#game_info').html("<h4><b> Score:</h4></b>" + me.username + ": " + score.me + "</br>Opponent: " + score.opponent + '<br/> <br/> <h4>Game Status:</h4>Game state: '
			+ game_status.status + '<b>');
		} else {
			$('#game_info').html("<h4><b> Score:</h4></b>" + me.username + ": " + score.me + "</br>"+ opponent + ": " + score.opponent + '<br/> <br/> <h4>Game Status:</h4>Game state: '
			+ game_status.status + '<b>');
		}
		
		


		if (game_status.player_turn==me.player_number) {
			$('#player_turn').html("<h6> It's </b> your turn to play now.</h6>");
		} else {  
			$('#player_turn').html("<h6> It's " + opponent +'</b> turn to play now.</h6>');
		}
	}else{
		$('#game_info').html("<h4><b> Score:</h4></b>"  + me.username + ": " + score.me + "</br>Opponent: " + score.opponent + '<br/> <br/> <h4>Game Status:</h4>Game state: '+ game_status.status);
        $('#player_turn').html("<h6>Playing as " + player + "</h6>");
    }
}


function update_status(data) {
	if (data==null) {
		return;
	}
	last_update=new Date().getTime();
	var game_status_old = game_status;
	game_status=data[0];
	winner = game_status.result;
	update_info();
	clearTimeout(timer);
	
	if (me.token!=null){
		$('#reset_game').show();
	}else{
		$('#reset_game').hide();
	}

	
	if (game_status_old.status=='initialized' && game_status.status=='not active' && me.token!=null){
		notify("Oh no!", "No player found. Game reset.");
		reset_board();
	}


	// Getting opponent's username
	if (game_status_old.status==null && game_status.status=='started' && me.token!=null){
		$.ajax({url: "rpsls.php/players/", 
			success: function (data) {
				players = data;
			}, 
			headers: {"X-Token": me.token}});
	} else if (game_status_old.status=='initialized' && game_status.status=='started'){
		$.ajax({url: "rpsls.php/players/", 
			success: function (data) {
				players = data;
			}, 
			headers: {"X-Token": me.token}});
	}

	if (game_status_old.status=='ended' && game_status.status=='not active'){
		if (surrendered==false) { notify("Oh no!", "Opponent left."); }
		score.me=0; score.opponent=0;
		reset_board();
	}
	
	if(game_status_old.status=='started' && game_status.status=='not active'){
		if (!surrendered) { notify("HAHA!", "Enemy player surrendered. Game restarted"); } else { surrendered=false; };
		score.me=0; score.opponent=0;
		reset_board();
		document.querySelector('#reset_game').setAttribute('value','Reset');
		update_info();
	}
		
	if (game_status.status=='started' && me.token!=null){
		document.querySelector('#reset_game').setAttribute('value','Surrender');
	}
	
	if (game_status.status == 'aborded' && game_status_old.status != 'aborded') {
		update_info();
		opponent_aborded(game_status);
		update_info();
        reset_board();
		return;
	}
	
	if (game_status.status == 'ended' && game_status_old.status != 'started') {
		alert_winner();

		update_status();
		update_info();
		return;

    } else { 
		timer= setTimeout(function() { game_status_update();}, 500); 
	}


//Ενημέρωση των παιχτών για aborded
function opponent_aborded(data){
	who_left= data.result;
	if (me.token!=null){
		if (who_left==me.player_number){
			notify("Goodbye!", 'You aborded the game.');
		}else{
			notify("HAHA!", 'Your opponent has aborded the game.');
		}
	
	}
}

//Ενημέρωση του χρήστη αν έχασε ή νίκησε, και ενημέρωση του score 
function alert_winner() {
	winner = game_status.result;
	if (me.token!=null){
		
		if (winner=='D'){
			play_again('The game was a tie..', "tie");
		}else if (winner==me.player_number){
			score.me++;
			play_again('You won because ' + game_status.result_text, "won");
			if (sounds) { audioYouWin.play(); }
			
		}else{
			score.opponent++;
			play_again('You lost because ' + game_status.result_text, "lost");
			if (sounds) { audioYouLose.play(); }
		}
	}
}
 	
}