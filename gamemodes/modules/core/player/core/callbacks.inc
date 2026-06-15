public OnPlayerConnect(playerid)
{
	Auth_OnPlayerConnect(playerid);
    Delivery_OnPlayerConnect(playerid);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	ResetPlayerMoney(playerid);
	
	Auth_OnPlayerDisconnect(playerid, reason);
	Delivery_OnPlayerDisconnect(playerid, reason);
	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
    SetSpawnInfo(playerid, NO_TEAM, 95, 3191.943,385.393,22.547, 90.0, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);

    TogglePlayerSpectating(playerid, true);
    return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	if(!Player[playerid][IsLoggedIn]) return 1;

	new randSpawn = 0;
	
	SetPlayerInterior(playerid,0);
	SetPlayerSkin(playerid, 100);
	SetPlayerHealth(playerid, 50.0);

	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, Player[playerid][Money]);


	if(CITY_LOS_SANTOS == gPlayerCitySelection[playerid]) {
 	    randSpawn = random(sizeof(gRandomSpawns_LosSantos));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_LosSantos[randSpawn][0],
		 gRandomSpawns_LosSantos[randSpawn][1],
		 gRandomSpawns_LosSantos[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_LosSantos[randSpawn][3]);
	}
    
    GivePlayerWeapon(playerid,WEAPON_COLT45,100);
	GivePlayerWeapon(playerid,WEAPON_SNIPER,9000);
	GivePlayerWeapon(playerid,WEAPON_M4,9000);
	GivePlayerWeapon(playerid,WEAPON_MP5,10000);
	GivePlayerWeapon(playerid,WEAPON_SAWEDOFF,10000);
	SetPlayerArmour(playerid,100);
	
	TogglePlayerClock(playerid, 0);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	UpdatePlayerDeaths(playerid);
	UpdatePlayerKills(killerid);

	Delivery_OnPlayerDeath(playerid, killerid, reason);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate){ 
	Delivery_OnPlayerStateChange(playerid, newstate, oldstate);
	return 1;
}
public OnPlayerEnterDynamicCP(playerid, checkpointid){
	Delivery_OnPlayerEnterDynamicCP(playerid, checkpointid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	Delivery_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	return 1;
}
