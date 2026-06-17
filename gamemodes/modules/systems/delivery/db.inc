

stock db_UpdateDeliveryStats(playerid, score, payout)
{
	Player[playerid][DeliveriesCompleted] += score;
    Player[playerid][Money] += payout; 

   
    new query[170];
    mysql_format(g_SQL, query, sizeof(query), 
        "UPDATE `players` SET `deliveries_completed` = %d, `money` = %d WHERE `id` = %d LIMIT 1", 
        Player[playerid][DeliveriesCompleted], Player[playerid][Money], Player[playerid][ID]
    );

    mysql_tquery(g_SQL, query,"OnQueryUpdateExecuted", "is", playerid, "Update delivery stats");
    return 1;
}