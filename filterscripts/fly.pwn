#include <a_samp>

#undef KEY_UP
#undef KEY_DOWN
#undef KEY_LEFT
#undef KEY_RIGHT
#define KEY_UP -128
#define KEY_DOWN 128
#define KEY_LEFT -128
#define KEY_RIGHT 128

#define green 0x0AFF0AAA
#define red 0xFF0000FF

new fly[MAX_PLAYERS] = {};
new Float:x, Float:y, Float:z, Float:angle;

forward Float:GetXYInFrontOfPlayer(playerid, &Float:q, &Float:w, Float:distance);
forward Float:GetXYBehindPlayer(playerid, &Float:q, &Float:w, Float:distance);
forward FlyTimer();

public OnFilterScriptInit()
{
	SetTimer("FlyTimer", 100, 1);
	return 1;
}

public OnPlayerConnect(playerid)
{
    fly[playerid] = 0;
    return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	fly[playerid] = 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    new cmd[256];
    new idx;
    cmd = strtok(cmdtext, idx);
    
    if(strcmp(cmd, "/fly", true) == 0 /* && IsPlayerAdmin(playerid)*/) {
        new tmp[256];
        tmp = strtok(cmdtext, idx);
        if(!strlen(tmp)) { if(fly[playerid] == 1) { fly[playerid] = 0; SendClientMessage(playerid,red,"Fly mode off."); TogglePlayerControllable(playerid,true); return 1; } else if(fly[playerid] == 0) { fly[playerid] = 1; SendClientMessage(playerid,green,"Fly mode online."); TogglePlayerControllable(playerid,false); return 1; } }
		if(strcmp(tmp, "on", true) == 0) { fly[playerid] = 1; SendClientMessage(playerid,green,"Fly mode online."); TogglePlayerControllable(playerid,false); return 1; }
		else if(strcmp(tmp, "off", true) == 0) { fly[playerid] = 0; SendClientMessage(playerid,red,"Fly mode off."); TogglePlayerControllable(playerid,true); return 1; }
	}
	return 0;
}

Float:GetXYInFrontOfPlayer(playerid, &Float:q, &Float:w, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, q, w, a);
    if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	else GetPlayerFacingAngle(playerid, a);
	q += (distance * floatsin(-a, degrees));
	w += (distance * floatcos(-a, degrees));
	return a;
}

Float:GetXYBehindPlayer(playerid, &Float:q, &Float:w, Float:distance)
{
	new Float:a;
	GetPlayerPos(playerid, q, w, a);
	if (GetPlayerState(playerid) == PLAYER_STATE_DRIVER) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	else GetPlayerFacingAngle(playerid, a);
	q += (distance * -floatsin(-a, degrees));
	w += (distance * -floatcos(-a, degrees));
	return a;
}

strtok(const string[], &index)
{
	new length = strlen(string);
	while ((index < length) && (string[index] <= ' '))
	{
		index++;
	}

	new offset = index;
	new result[20];
	while ((index < length) && (string[index] > ' ') && ((index - offset) < (sizeof(result) - 1)))
	{
		result[index - offset] = string[index];
		index++;
	}
	result[index - offset] = EOS;
	return result;
}

public FlyTimer()
{
    new keys, updown, leftright;
	for (new playerid = 0, max_players = GetMaxPlayers(); playerid < max_players; ++playerid) {
	    if (IsPlayerConnected(playerid) && !IsPlayerNPC(playerid)) {
	        if (fly[playerid]) {
	        	GetPlayerKeys(playerid, keys, updown, leftright);
	            if(updown == KEY_UP) {
	                if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
						GetPlayerPos(playerid, x, y, z);
						GetXYInFrontOfPlayer(playerid, x, y, 5.0);
						SetPlayerPos(playerid, x, y, z);
						SetCameraBehindPlayer(playerid);
					}
					else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
						new playercar = GetPlayerVehicleID(playerid);
						GetVehiclePos(playercar, x, y, z);
						GetXYInFrontOfPlayer(playerid, x, y, 5.0);
						SetVehiclePos(playercar, x, y, z);
					}
				}
				else if(updown == KEY_DOWN) {
				    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
						GetPlayerPos(playerid, x, y, z);
						GetXYBehindPlayer(playerid, x, y, 5.0);
						SetPlayerPos(playerid, x, y, z);
						SetCameraBehindPlayer(playerid);
					}
					else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
					    new playercar = GetPlayerVehicleID(playerid);
					    GetVehiclePos(playercar, x, y, z);
					    GetXYBehindPlayer(playerid, x, y, 5.0);
					    SetVehiclePos(playercar, x, y, z);
					}
				}
				if(leftright == KEY_LEFT) {
					if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
						GetPlayerFacingAngle(playerid, angle);
						SetPlayerFacingAngle(playerid, angle+10);
						SetCameraBehindPlayer(playerid);
					}
					else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
					    new playercar = GetPlayerVehicleID(playerid);
					    GetVehicleZAngle(playercar, angle);
					    SetVehicleZAngle(playercar, angle+10);
					}
				}
				else if(leftright == KEY_RIGHT) {
					if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
						GetPlayerFacingAngle(playerid, angle);
						SetPlayerFacingAngle(playerid, angle-10);
						SetCameraBehindPlayer(playerid);
					}
					else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
					    new playercar = GetPlayerVehicleID(playerid);
					    GetVehicleZAngle(playercar, angle);
						SetVehicleZAngle(playercar, angle-10);
					}
				}
				if(keys == KEY_JUMP) {
				    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
						GetPlayerPos(playerid, x, y, z);
						SetPlayerPos(playerid, x, y, z+5);
						SetCameraBehindPlayer(playerid);
					}
					else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
						new playercar = GetPlayerVehicleID(playerid);
						GetVehiclePos(playercar, x, y, z);
						SetVehiclePos(playercar, x, y, z+5);
					}
				}
				else if(keys == KEY_SPRINT) {
				    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
						GetPlayerPos(playerid, x, y, z);
						SetPlayerPos(playerid, x, y, z-5);
						SetCameraBehindPlayer(playerid);
					}
					else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
						new playercar = GetPlayerVehicleID(playerid);
						GetVehiclePos(playercar, x, y, z);
						SetVehiclePos(playercar, x, y, z-5);
					}
				}
			}
		}
	}
}

