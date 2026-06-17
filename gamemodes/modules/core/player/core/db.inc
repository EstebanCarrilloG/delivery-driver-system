stock db_UpdatePlayerScore(playerid, amount)
{
	if (!Player[playerid][IsLoggedIn]) return 1;

	Player[playerid][Score] += amount;
	SetPlayerScore(playerid, Player[playerid][Score]);

	new query[70];
	mysql_format(g_SQL, query, sizeof(query), "UPDATE `players` SET `score` = %d WHERE `id` = %d LIMIT 1", Player[playerid][Score], Player[playerid][ID]);
	mysql_tquery(g_SQL, query,"OnQueryUpdateExecuted", "is", playerid, "Update player score.");

	return 1;
}