/* ---------------------------------
	Охота на оленей

- Author: Виски.
---------------------------------*/

#define FILTERSCRIPT

#include <a_samp>
#include <FCNPC>

new Float:spawn_deer[][4] = // Кол-во оленей
{
	{806.8853,317.7979,12.4206,167.5862}
};

new Float:Movement[][8] = // куда они бегут
{
	{-1173.1147,2418.3118,113.8704},
	{-1260.1194,2393.2351,99.1603},
	{-1311.4369,2446.5022,87.7836},
	{-1296.5278,2499.5815,86.9498},
	{-1157.3190,2505.4756,112.4002},
	{-1186.0594,2501.7334,113.0903},
	{-1158.6748,2374.9146,108.1565},
	{-1221.4376,2479.6360,95.8251}
};
new interior_car, object_deer;
new npc_id;
public OnFilterScriptInit()
{
    FCNPC_SetUpdateRate(1);
	printf("");
	printf("-------------------------------------------------");
	printf("  Система охоты на оленей by WH1SKEY");
	printf("-------------------------------------------------");
	printf("");
	interior_car = CreateObject(19315, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0);
	object_deer = 594;
	// Create NPCs
	npc_id = FCNPC_Create("BotEx");
	FCNPC_Spawn(npc_id, random(299), spawn_deer[0][0], spawn_deer[0][1], spawn_deer[0][2]);
	FCNPC_SetAngle(npc_id, spawn_deer[0][3]);
	FCNPC_SetInterior(npc_id, 0);
	FCNPC_SetWeapon(npc_id, random(11) + 22);
	FCNPC_SetAmmo(npc_id, 500);
	object_deer = CreateVehicle(594,806.8853,317.7979,12.4206,167.5862,-1,-1,60);
	AttachObjectToVehicle(interior_car, object_deer,0.0,0.0,0.4,0.0,0.0,90.0);
	LinkVehicleToInterior(object_deer,6);
	FCNPC_PutInVehicle(npc_id, object_deer, 0);
    return 1;
}

public FCNPC_OnDeath(npcid, killerid, reason)
{
    DestroyVehicle(object_deer);
    FCNPC_Respawn(npcid);
    object_deer = CreateVehicle(594,806.8853,317.7979,12.4206,167.5862,-1,-1,60);
	AttachObjectToVehicle(interior_car, object_deer,0.0,0.0,0.4,0.0,0.0,90.0);
	LinkVehicleToInterior(object_deer,6);
	FCNPC_PutInVehicle(npcid, object_deer, 0);
 	return 1;
}

public FCNPC_OnCreate(npcid)
{
	return 1;
}

new number_hits[MAX_PLAYERS char], notification[MAX_PLAYERS char];
public OnPlayerUpdate(playerid)
{
    if(notification{playerid} == 1)
    {
    	if (!IsPlayerInRangeOfPoint(playerid, 40.0, 806.8853,317.7979,12.4206)) notification{playerid} = 0;
	}
	return true;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if (IsPlayerInRangeOfPoint(playerid, 40.0, 806.8853,317.7979,12.4206))
    {
        if(notification{playerid} == 0)
        {
	        new rand = random(sizeof(Movement));
	    	FCNPC_GoTo(npc_id, Movement[rand][0], Movement[rand][1], Movement[rand][2], FCNPC_MOVE_TYPE_DRIVE, 0.6, false), FCNPC_IsMoving(npc_id);
	    	SendClientMessage(playerid, 0x0092F7FF, !"Вы распугали всех оленей!");
	    	notification{playerid} = 1;
		}
    }
	if(hittype == 3 && object_deer)
 	{
 	    new rand = random(sizeof(Movement));
		number_hits{playerid}++;
		if(number_hits{playerid} == 1) FCNPC_GoTo(npc_id, Movement[rand][0], Movement[rand][1], Movement[rand][2], FCNPC_MOVE_TYPE_DRIVE, 0.6, false), FCNPC_IsMoving(npc_id);
 	    if(number_hits{playerid} == 2)
 	    {
       		FCNPC_SetHealth(npc_id, 0);
       		SendClientMessage(playerid, 0x0092F7FF, !"Вы убили оленя!");
       		number_hits{playerid} = 0;
		}
        return 1;
    }
    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if(!strcmp(cmdtext, "/tpol", true))
    {
        SetPlayerPos(playerid, 806.8853,317.7979,12.4206);
        return 1;
    }
	return false;
}