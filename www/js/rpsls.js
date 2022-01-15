var me={ nickname: null, token: null, player_number: null };
var score={ me: 0, opponent: 0}
var game_status={};
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


//Ajax request για κίνηση
function do_move(choice) {
	//
}

function reset_board() {
	
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