stock UpdateDeliveryStats(playerid)
{
    new query[145];
	mysql_format(g_SQL, query, sizeof query, "UPDATE `players` SET `deliveries_completed` = `deliveries_completed` + 1, `money` = `money` + %d WHERE `id` = %d LIMIT 1", DELIVERY_PAYOUT, Player[playerid][ID]);
	mysql_tquery(g_SQL, query);
}