public OnPlayerConnect(playerid)
{
	Player[playerid][IsLoggedIn] = false;

	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(!Player[playerid][IsLoggedIn]) 
	{
    	SetSpawnInfo(playerid, NO_TEAM, 95, 3191.943,385.393,22.547, 90.0, 0, 0, 0, 0, 0, 0);
    	TogglePlayerSpectating(playerid, true);
	
		return 1;
	}

    return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	if(!Player[playerid][IsLoggedIn]) return 1;
	
	SetPlayerInterior(playerid,0);
	SetPlayerSkin(playerid, 100);



	if(CITY_LOS_SANTOS == gPlayerCitySelection[playerid]) {
 	    new randSpawn = random(sizeof(gRandomSpawns_LosSantos));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_LosSantos[randSpawn][0],
		 gRandomSpawns_LosSantos[randSpawn][1],
		 gRandomSpawns_LosSantos[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_LosSantos[randSpawn][3]);
	}

	SetPlayerData(playerid);

	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	UpdatePlayerDeaths(playerid);
	UpdatePlayerKills(killerid);


	return 1;
}