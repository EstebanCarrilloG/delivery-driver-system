AssignPlayerData(playerid)
{
	cache_get_value_int(0, "id", Player[playerid][ID]);
	cache_get_value_int(0, "kills", Player[playerid][Kills]);
	cache_get_value_int(0, "deaths", Player[playerid][Deaths]);
	cache_get_value_int(0,"money", Player[playerid][Money]);
	cache_get_value_int(0,"score", Player[playerid][Score]);
	cache_get_value_int(0,"deliveries_completed ", Player[playerid][DeliveriesCompleted]);

	return 1;
}

DelayedKick(playerid, time = 500)
{
	SetTimerEx("_KickPlayerDelayed", time, false, "d", playerid);
	return 1;
}
