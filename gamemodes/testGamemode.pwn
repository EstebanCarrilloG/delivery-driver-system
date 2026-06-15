#include 	<a_samp>
#include 	<a_mysql>
#include "../include/gl_spawns.inc"
#include "../include/core/mysql.inc"
#include "../include/core/data.inc"
#include "./modules/core/MySQL/functions"

// change MAX_PLAYERS to the amount of players (slots) you want
// It is by default 1000 (as of 0.3.7 version)
#undef	  	MAX_PLAYERS
#define	 	MAX_PLAYERS			50

// how many seconds until it kicks the player for taking too long to login
#define		SECONDS_TO_LOGIN 	30

new g_MysqlRaceCheck[MAX_PLAYERS];

// dialog data
enum
{
	DIALOG_UNUSED,
	DIALOG_LOGIN,
	DIALOG_REGISTER
};

#define CITY_LOS_SANTOS 	0

new gPlayerCitySelection[MAX_PLAYERS];

main() {}

public OnGameModeInit()
{
	ConnectToDatabase();
	UsePlayerPedAnims();
	return 1;
}

public OnGameModeExit()
{
	// save all player data before closing connection
	for (new i = 0, j = GetPlayerPoolSize(); i <= j; i++) // GetPlayerPoolSize function was added in 0.3.7 version and gets the highest playerid currently in use on the server
	{
		if (IsPlayerConnected(i))
		{
			// reason is set to 1 for normal 'Quit'
			OnPlayerDisconnect(i, 1);
		}
	}

	mysql_close(g_SQL);
	return 1;
}

public OnPlayerConnect(playerid)
{
	g_MysqlRaceCheck[playerid]++;

	// reset player data
	static const empty_player[E_PLAYERS];
	Player[playerid] = empty_player;

	GetPlayerName(playerid, Player[playerid][Name], MAX_PLAYER_NAME);

	// send a query to recieve all the stored player data from the table
	new query[103];
	mysql_format(g_SQL, query, sizeof query, "SELECT * FROM `players` WHERE `username` = '%e' LIMIT 1", Player[playerid][Name]);
	mysql_tquery(g_SQL, query, "OnPlayerDataLoaded", "dd", playerid, g_MysqlRaceCheck[playerid]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	g_MysqlRaceCheck[playerid]++;

	// if the player was kicked (either wrong password or taking too long) during the login part, remove the data from the memory
	if (cache_is_valid(Player[playerid][Cache_ID]))
	{
		cache_delete(Player[playerid][Cache_ID]);
		Player[playerid][Cache_ID] = MYSQL_INVALID_CACHE;
	}

	// if the player was kicked before the time expires (30 seconds), kill the timer
	if (Player[playerid][LoginTimer])
	{
		KillTimer(Player[playerid][LoginTimer]);
		Player[playerid][LoginTimer] = 0;
	}

	// sets "IsLoggedIn" to false when the player disconnects, it prevents from saving the player data twice when "gmx" is used
	Player[playerid][IsLoggedIn] = false;
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
	
	new randSpawn = 0;
	
	SetPlayerInterior(playerid,0);
	SetPlayerSkin(playerid, 100);
	SetPlayerHealth(playerid, 50.0);
	GivePlayerMoney(playerid, Player[playerid][Money]);
	

	if(CITY_LOS_SANTOS == gPlayerCitySelection[playerid]) {
 	    randSpawn = random(sizeof(gRandomSpawns_LosSantos));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_LosSantos[randSpawn][0],
		 gRandomSpawns_LosSantos[randSpawn][1],
		 gRandomSpawns_LosSantos[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_LosSantos[randSpawn][3]);
	}

	//SetPlayerColor(playerid,COLOR_NORMAL_PLAYER);
	
	/*
	SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL_SILENCED,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SPAS12_SHOTGUN,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_MICRO_UZI,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_MP5,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_AK47,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_M4,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,200);*/
    
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
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch (dialogid)
	{
		case DIALOG_UNUSED: return 1; // Useful for dialogs that contain only information and we do nothing depending on whether they responded or not

		case DIALOG_LOGIN:
		{
			if (!response) return Kick(playerid);

			new hashed_pass[65];
			SHA256_PassHash(inputtext, Player[playerid][Salt], hashed_pass, 65);

			if (strcmp(hashed_pass, Player[playerid][Password]) == 0)
			{
				//correct password, spawn the player
				//ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have been successfully logged in.", "Okay", "");

				// sets the specified cache as the active cache so we can retrieve the rest player data
				cache_set_active(Player[playerid][Cache_ID]);

				AssignPlayerData(playerid);

				// remove the active cache from memory and unsets the active cache as well
				cache_delete(Player[playerid][Cache_ID]);
				Player[playerid][Cache_ID] = MYSQL_INVALID_CACHE;

				KillTimer(Player[playerid][LoginTimer]);
				Player[playerid][LoginTimer] = 0;
				Player[playerid][IsLoggedIn] = true;

				// spawn the player to their last saved position after login
				//SetSpawnInfo(playerid, NO_TEAM, 0, Player[playerid][X_Pos], Player[playerid][Y_Pos], Player[playerid][Z_Pos], Player[playerid][A_Pos], 0, 0, 0, 0, 0, 0);
				gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
				TogglePlayerSpectating(playerid, false);

				SpawnPlayer(playerid);
			}
			else
			{
				Player[playerid][LoginAttempts]++;

				if (Player[playerid][LoginAttempts] >= 3)
				{
					ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have mistyped your password too often (3 times).", "Okay", "");
					DelayedKick(playerid);
				}
				else ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", "Wrong password!\nPlease enter your password in the field below:", "Login", "Abort");
			}
		}
		case DIALOG_REGISTER:
		{
			if (!response) return Kick(playerid);

			if (strlen(inputtext) <= 5) return ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", "Your password must be longer than 5 characters!\nPlease enter your password in the field below:", "Register", "Abort");

			// 16 random characters from 33 to 126 (in ASCII) for the salt
			for (new i = 0; i < 16; i++) Player[playerid][Salt][i] = random(94) + 33;
			SHA256_PassHash(inputtext, Player[playerid][Salt], Player[playerid][Password], 65);

			new query[221];
			mysql_format(g_SQL, query, sizeof query, "INSERT INTO `players` (`username`, `password`, `salt`) VALUES ('%e', '%s', '%e')", Player[playerid][Name], Player[playerid][Password], Player[playerid][Salt]);
			mysql_tquery(g_SQL, query, "OnPlayerRegister", "d", playerid);
		}

		default: return 0; // dialog ID was not found, search in other scripts
	}
	return 1;
}

//-----------------------------------------------------

forward OnPlayerDataLoaded(playerid, race_check);
public OnPlayerDataLoaded(playerid, race_check)
{
	/*	race condition check:
		player A connects -> SELECT query is fired -> this query takes very long
		while the query is still processing, player A with playerid 2 disconnects
		player B joins now with playerid 2 -> our laggy SELECT query is finally finished, but for the wrong player

		what do we do against it?
		we create a connection count for each playerid and increase it everytime the playerid connects or disconnects
		we also pass the current value of the connection count to our OnPlayerDataLoaded callback
		then we check if current connection count is the same as connection count we passed to the callback
		if yes, everything is okay, if not, we just kick the player
	*/
	if (race_check != g_MysqlRaceCheck[playerid]) return Kick(playerid);

	new string[115];
	if(cache_num_rows() > 0)
	{
		// we store the password and the salt so we can compare the password the player inputs
		// and save the rest so we won't have to execute another query later
		cache_get_value(0, "password", Player[playerid][Password], 65);
		cache_get_value(0, "salt", Player[playerid][Salt], 17);

		// saves the active cache in the memory and returns an cache-id to access it for later use
		Player[playerid][Cache_ID] = cache_save();

		format(string, sizeof string, "This account (%s) is registered. Please login by entering your password in the field below:", Player[playerid][Name]);
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Login", string, "Login", "Abort");

		// from now on, the player has 30 seconds to login
		Player[playerid][LoginTimer] = SetTimerEx("OnLoginTimeout", SECONDS_TO_LOGIN * 1000, false, "d", playerid);
	}
	else
	{
		format(string, sizeof string, "Welcome %s, you can register by entering your password in the field below:", Player[playerid][Name]);
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Registration", string, "Register", "Abort");
	}
	return 1;
}

forward OnLoginTimeout(playerid);
public OnLoginTimeout(playerid)
{
	// reset the variable that stores the timerid
	Player[playerid][LoginTimer] = 0;

	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Login", "You have been kicked for taking too long to login successfully to your account.", "Okay", "");
	DelayedKick(playerid);
	return 1;
}

forward OnPlayerRegister(playerid);
public OnPlayerRegister(playerid)
{
	// retrieves the ID generated for an AUTO_INCREMENT column by the sent query
	Player[playerid][ID] = cache_insert_id();

	ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Registration", "Account successfully registered, you have been automatically logged in.", "Okay", "");

	Player[playerid][IsLoggedIn] = true;

	gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
	TogglePlayerSpectating(playerid, false);
	SpawnPlayer(playerid);
	return 1;
}

forward _KickPlayerDelayed(playerid);
public _KickPlayerDelayed(playerid)
{
	Kick(playerid);
	return 1;
}


//-----------------------------------------------------

AssignPlayerData(playerid)
{
	cache_get_value_int(0, "id", Player[playerid][ID]);

	cache_get_value_int(0, "kills", Player[playerid][Kills]);
	cache_get_value_int(0, "deaths", Player[playerid][Deaths]);
	cache_get_value_int(0,"money", Player[playerid][Money]);

	return 1;
}

DelayedKick(playerid, time = 500)
{
	SetTimerEx("_KickPlayerDelayed", time, false, "d", playerid);
	return 1;
}

UpdatePlayerDeaths(playerid)
{
	if (Player[playerid][IsLoggedIn] == false) return 0;

	Player[playerid][Deaths]++;

	new query[70];
	mysql_format(g_SQL, query, sizeof query, "UPDATE `players` SET `deaths` = %d WHERE `id` = %d LIMIT 1", Player[playerid][Deaths], Player[playerid][ID]);
	mysql_tquery(g_SQL, query);
	return 1;
}

UpdatePlayerKills(killerid)
{
	// we must check before if the killer wasn't valid (connected) player to avoid run time error 4
	if (killerid == INVALID_PLAYER_ID) return 0;
	if (Player[killerid][IsLoggedIn] == false) return 0;

	Player[killerid][Kills]++;

	new query[70];
	mysql_format(g_SQL, query, sizeof query, "UPDATE `players` SET `kills` = %d WHERE `id` = %d LIMIT 1", Player[killerid][Kills], Player[killerid][ID]);
	mysql_tquery(g_SQL, query);
	return 1;
}