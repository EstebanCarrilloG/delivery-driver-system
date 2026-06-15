main() {}

public OnGameModeInit()
{
	ConnectToDatabase();
	UsePlayerPedAnims();
	Delivery_OnGamemodeInit();
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	Auth_OnDialogResponse(playerid, dialogid, response, listitem, inputtext);
	return 1;
}