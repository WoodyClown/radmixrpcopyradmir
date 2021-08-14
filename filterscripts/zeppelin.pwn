#include <a_samp>
main(){}

#define DIALOG_BET_ZEPPELIN 1340

forward OnPlayerCommandPerformed(playerid, cmdtext[], success);




new PlayerText:gameTextDraw_player[MAX_PLAYERS][2];
new Text:gameTextDraw_all[6];

new Float: score_game_zeppelin[MAX_PLAYERS] = {1.0, ...};
new Float: bet_zeppelin[MAX_PLAYERS],
	Float: bet_static_win[MAX_PLAYERS];

new bool:start_game[MAX_PLAYERS];
new player_timer[MAX_PLAYERS];





public OnFilterScriptInit()
{
	createTextDrawToAll();
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

public OnPlayerConnect(playerid)
{
    createTextDrawToPlayer(playerid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_BET_ZEPPELIN) {

		/*if (playerInfo[playerid][money] < bet_zeppelin[playerid]) 
								return SendClientMessage(playerid, -1, "У вас нет столько денег");*/
		bet_zeppelin[playerid] = strval(inputtext)*1.0;
		/*playerInfo[playerid][money] -= bet_zeppelin[playerid]*/
		score_game_zeppelin[playerid] = 1.0;
		new string_game_zeppelin[35]; //для большей суммы
		format(string_game_zeppelin, sizeof string_game_zeppelin, "%.2f~n~~b~%.0f$", score_game_zeppelin[playerid], bet_zeppelin[playerid]);
		PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][0], string_game_zeppelin);
	}
	return 1;
}


CMD:casino(playerid) {
	SetPVarInt(playerid, #game, 1);
	showBoxZeppelin(playerid, 1);
}


forward timerGameZeppelin(playerid);
public timerGameZeppelin(playerid)
{

	if (random(100) != 5) { // если выпадет '5' - игра проиграна

		if ( score_game_zeppelin[playerid] <= 5.0 ) score_game_zeppelin[playerid] += 0.01;//если кэф ниже 5 то прибавляем по 1/100 раз в 50 мс
		else score_game_zeppelin[playerid] += 0.10; //в ином случае по 1/10 в 50мс

		bet_static_win[playerid] = score_game_zeppelin[playerid]*bet_zeppelin[playerid];

		new string_game_zeppelin[35];
		format(string_game_zeppelin, sizeof string_game_zeppelin, "%.2f~n~~b~%.0f$", score_game_zeppelin[playerid], bet_static_win[playerid]);
		PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][0], string_game_zeppelin);

		player_timer[playerid] = SetTimerEx("timerGameZeppelin", 5_0, false, "i", playerid);//50ms
	}
	else {
		bet_zeppelin[playerid] = 0.0;
	    PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][0], "~r~FAIL");
	    setGame(playerid, 1);
	}
	
}
stock gameZeppelinStart(playerid) 
{

	score_game_zeppelin[playerid] = 1.0;
	player_timer[playerid] = SetTimerEx("timerGameZeppelin", 5_0, false, "i", playerid);//50ms

    return 1;
}

stock showBoxZeppelin(playerid, int) {

	if ( int ) {
		for(new i; i<6; i++) {
			TextDrawShowForPlayer(playerid,gameTextDraw_all[i]);
		}
	    PlayerTextDrawShow(playerid, gameTextDraw_player[playerid][0]);
	    PlayerTextDrawShow(playerid, gameTextDraw_player[playerid][1]);
	    SelectTextDraw ( playerid, 0xFFFFFF80 ) ;
	}
	else {
	    for(new i; i<6; i++) {
	    	TextDrawHideForPlayer(playerid,gameTextDraw_all[i]);
	    }
				
			//скрываем тд
        
	    PlayerTextDrawHide(playerid,gameTextDraw_player[playerid][0]);
		PlayerTextDrawHide(playerid,gameTextDraw_player[playerid][1]);

		CancelSelectTextDraw(playerid);
		//
		start_game[playerid] = false;//статус игры
		KillTimer(player_timer[playerid]);//убираем таймер
		bet_zeppelin[playerid] = 0;
		
		PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][1], "BET________START");
		PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][0], "1.00");
	}
}

stock setGame(playerid, status) { // запуск / остановка игры

	if ( !status ) {

		if (bet_zeppelin[playerid] <= 0) return SendClientMessage(playerid, -1, "Сделайте ставку, прежде чем начать игру!");

		PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][1], "BET_________STOP");

		start_game[playerid] = true;

		gameZeppelinStart(playerid);//запускаем игру

	} else {

		if(bet_zeppelin[playerid])	{//проверяем сдлали ставку

			new string_game_zeppelin[35];
		
			format(string_game_zeppelin, sizeof string_game_zeppelin, "~g~WIN!!!~n~%d$", floatround(bet_static_win[playerid]));
			PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][0], string_game_zeppelin);

			GivePlayerMoney(playerid, floatround(bet_static_win[playerid]));//Изменить на свою выдачу денег
			/*playerInfo[playerid][money] += floatround(bet_static_win[playerid]);*/
			bet_static_win[playerid] = 0.0;
			bet_zeppelin[playerid] = 0.0;
		}

		PlayerTextDrawSetString(playerid, gameTextDraw_player[playerid][1], "BET________START");

		start_game[playerid] = false;//статус игры
		
		KillTimer(player_timer[playerid]);//убираем таймер
	}
	return 1;
}


public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if (clickedid == gameTextDraw_all[3]) {
		if(start_game[playerid]) return 1; //запрещаем нажимать 'BET'
		ShowPlayerDialog(playerid, DIALOG_BET_ZEPPELIN, DIALOG_STYLE_INPUT, "Сделайте вашу ставку", " ", "Принять", "Закрыть");
	}
	if (clickedid == gameTextDraw_all[4]) {
		setGame(playerid, start_game[playerid]);
	}
	if(GetPVarInt(playerid, #game)) {

		if(clickedid == Text:INVALID_TEXT_DRAW) {
			showBoxZeppelin(playerid, 0);
			DeletePVar(playerid, #game);
		}
		return 1;
	}
					
	return 1;
}

stock createTextDrawToPlayer(playerid)
{
	gameTextDraw_player[playerid][0] = CreatePlayerTextDraw(playerid, 291.2500, 201.9259, "1.00"); //кэф
	PlayerTextDrawLetterSize(playerid, gameTextDraw_player[playerid][0], 0.3908, 3.0577);
	PlayerTextDrawTextSize(playerid, gameTextDraw_player[playerid][0], 348.0000, 0.0000);
	PlayerTextDrawAlignment(playerid, gameTextDraw_player[playerid][0], 1);
	PlayerTextDrawColor(playerid, gameTextDraw_player[playerid][0], -1);
	PlayerTextDrawBackgroundColor(playerid, gameTextDraw_player[playerid][0], 255);
	PlayerTextDrawFont(playerid, gameTextDraw_player[playerid][0], 2);
	PlayerTextDrawSetProportional(playerid, gameTextDraw_player[playerid][0], 1);
	PlayerTextDrawSetShadow(playerid, gameTextDraw_player[playerid][0], 257);


	gameTextDraw_player[playerid][1] = CreatePlayerTextDraw(playerid, 299.1665, 299.9259, "BET________START"); // название для кнопок
	PlayerTextDrawLetterSize(playerid, gameTextDraw_player[playerid][1], 0.3033, 1.3407);
	PlayerTextDrawAlignment(playerid, gameTextDraw_player[playerid][1], 1);
	PlayerTextDrawColor(playerid, gameTextDraw_player[playerid][1],  -2139062017);
	PlayerTextDrawBackgroundColor(playerid, gameTextDraw_player[playerid][1], 255);
	PlayerTextDrawFont(playerid, gameTextDraw_player[playerid][1], 1);
	PlayerTextDrawSetProportional(playerid, gameTextDraw_player[playerid][1], 1);
	PlayerTextDrawSetShadow(playerid, gameTextDraw_player[playerid][1], 0);
}


stock createTextDrawToAll()
{
	gameTextDraw_all[0] = TextDrawCreate(257.9165, 149.5553, "Box"); // основа
	TextDrawLetterSize(gameTextDraw_all[0], 0.0000, 19.2499);
	TextDrawTextSize(gameTextDraw_all[0], 380.0000, 0.0000);
	TextDrawAlignment(gameTextDraw_all[0], 1);
	TextDrawColor(gameTextDraw_all[0], -1);
	TextDrawUseBox(gameTextDraw_all[0], 1);
	TextDrawBoxColor(gameTextDraw_all[0], 80);
	TextDrawBackgroundColor(gameTextDraw_all[0], 1768516090);
	TextDrawFont(gameTextDraw_all[0], 1);
	TextDrawSetProportional(gameTextDraw_all[0], 1);
	TextDrawSetShadow(gameTextDraw_all[0], 0);

	gameTextDraw_all[1] = TextDrawCreate(257.9167, 158.8886, "Box"); // шапка для названия
	TextDrawLetterSize(gameTextDraw_all[1], 0.0000, 1.1666);
	TextDrawTextSize(gameTextDraw_all[1], 303.0000, 0.0000);
	TextDrawAlignment(gameTextDraw_all[1], 1);
	TextDrawColor(gameTextDraw_all[1], -1);
	TextDrawUseBox(gameTextDraw_all[1], 1);
	TextDrawBoxColor(gameTextDraw_all[1], 96);
	TextDrawBackgroundColor(gameTextDraw_all[1], 255);
	TextDrawFont(gameTextDraw_all[1], 1);
	TextDrawSetProportional(gameTextDraw_all[1], 1);
	TextDrawSetShadow(gameTextDraw_all[1], 0);

	gameTextDraw_all[2] = TextDrawCreate(260.4165, 158.3701, "ZEPPELIN"); // название
	TextDrawLetterSize(gameTextDraw_all[2], 0.2865, 1.1124);
	TextDrawTextSize(gameTextDraw_all[2], -4.0000, 0.0000);
	TextDrawAlignment(gameTextDraw_all[2], 1);
	TextDrawColor(gameTextDraw_all[2], -1);
	TextDrawBackgroundColor(gameTextDraw_all[2], 255);
	TextDrawFont(gameTextDraw_all[2], 1);
	TextDrawSetProportional(gameTextDraw_all[2], 1);
	TextDrawSetShadow(gameTextDraw_all[2], 0);

	gameTextDraw_all[3] = TextDrawCreate(285.4162, 293.9630, "LD_SPAC:white"); // бокс для кнопки start/stop
	TextDrawTextSize(gameTextDraw_all[3], 44.0000, 24.0000);
	TextDrawAlignment(gameTextDraw_all[3], 1);
	TextDrawColor(gameTextDraw_all[3], -1378294017);
	TextDrawBackgroundColor(gameTextDraw_all[4], 255);
	TextDrawFont(gameTextDraw_all[3], 4);
	TextDrawSetProportional(gameTextDraw_all[4], 0);
	TextDrawSetShadow(gameTextDraw_all[3], 0);
	TextDrawSetSelectable(gameTextDraw_all[3], true);

	gameTextDraw_all[4] = TextDrawCreate(331.6663, 293.9630, "LD_SPAC:white"); // бокс для bet
	TextDrawTextSize(gameTextDraw_all[4], 44.0000, 24.0000);
	TextDrawAlignment(gameTextDraw_all[4], 1);
	TextDrawColor(gameTextDraw_all[4], -5963521);
	TextDrawBackgroundColor(gameTextDraw_all[4], 255);
	TextDrawFont(gameTextDraw_all[4], 4);
	TextDrawSetProportional(gameTextDraw_all[4], 0);
	TextDrawSetShadow(gameTextDraw_all[4], 0);
	TextDrawSetSelectable(gameTextDraw_all[4], true);

	gameTextDraw_all[5] = TextDrawCreate(257.9165, 184.8147, "Box"); // белый фонт для надписи с кэфом
	TextDrawLetterSize(gameTextDraw_all[5], 0.0000, 8.0416);
	TextDrawTextSize(gameTextDraw_all[5], 380.0000, 0.0000);
	TextDrawAlignment(gameTextDraw_all[5], 1);
	TextDrawColor(gameTextDraw_all[5], -1);
	TextDrawUseBox(gameTextDraw_all[5], 1);
	TextDrawBoxColor(gameTextDraw_all[5], -1431655872);
	TextDrawBackgroundColor(gameTextDraw_all[5], 255);
	TextDrawFont(gameTextDraw_all[5], 1);
	TextDrawSetProportional(gameTextDraw_all[5], 1);
	TextDrawSetShadow(gameTextDraw_all[5], 0);
}


public OnPlayerCommandPerformed(playerid, cmdtext[], success) return 1;