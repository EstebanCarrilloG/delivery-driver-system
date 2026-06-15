public OnVehicleSpawn(vehicleid)
{
	Delivery_OnVehicleSpawn(vehicleid);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	Delivery_OnVehicleDeath(vehicleid, killerid);
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid){
	Delivery_OnPlayerExitVehicle(playerid, vehicleid);
	return 1;
}