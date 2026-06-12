CMD:startdelivery(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);

    if(!IsPlayerInAnyVehicle(playerid) || !DeliveryVehicle[vehicleid][dvCreated])
        return SendDeliveryMessage(playerid, "You must be inside a delivery van to use this command.", DELIVERY_ERROR);

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendDeliveryMessage(playerid, "You must be driving.", DELIVERY_ERROR);

    if(PlayerDelivery[playerid][pDeliveryWorking])
        return SendDeliveryMessage(playerid, "You are already working as a delivery driver.", DELIVERY_ERROR);

    if(DeliveryVehicle[vehicleid][dvInUse])
        return SendDeliveryMessage(playerid, "This vehicle is already in use by other player.", DELIVERY_ERROR);

    PlayerDelivery[playerid][pDeliveryWorking] = true;
    DeliveryVehicle[vehicleid][dvPlayerid] = playerid;
    DeliveryVehicle[vehicleid][dvInUse] = true;
    PlayerDelivery[playerid][pDeliveryVehicle] = vehicleid;

    CreateDeliveryTextdraw(playerid);
	
	deliveryVan3DTextId[playerid] = CreatePlayer3DTextLabel(playerid, DeliveryVan3DText, 0xFFFFFFFF, 0.0, -2.5, 0.0, 10.0, INVALID_PLAYER_ID, vehicleid, 0);
       
    SendDeliveryMessage(playerid, "You started working as a delivery driver.");
    SendDeliveryMessage(playerid, "Drive to the checkpoint located inside the warehouse to pick up packages."); 
    
    return 1;
}

CMD:nextdelivery(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);

    if(!PlayerDelivery[playerid][pDeliveryWorking])
        return SendDeliveryMessage(playerid, "You are not working as a delivery driver.", DELIVERY_ERROR);
    
    if(PlayerDelivery[playerid][pDeliveryInProgress])
        return SendDeliveryMessage(playerid, "You are already delivering a package.", DELIVERY_ERROR);

    if(!IsPlayerInAnyVehicle(playerid))
        return SendDeliveryMessage(playerid, "You must be inside your delivery van to request the next delivery.", DELIVERY_ERROR);

    if(playerid != DeliveryVehicle[vehicleid][dvPlayerid] && IsPlayerInAnyVehicle(playerid))
        return SendDeliveryMessage(playerid, "You are not the driver of this delivery van.", DELIVERY_ERROR);

    if(!VehicleHasPackages(vehicleid))
        return SendDeliveryMessage(playerid, "The van is empty. Go to the warehouse to pick up packages.", DELIVERY_ERROR);

    if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
        return SendDeliveryMessage(playerid, "You must be driving.", DELIVERY_ERROR);

    if(!DeliveryVehicle[vehicleid][dvCreated])
        return SendDeliveryMessage(playerid, "This is not a delivery van.", DELIVERY_ERROR);
        
    PlayerDelivery[playerid][pDeliveryInProgress] = true;

    AssignDelivery(playerid);
    
    return 1;

}

CMD:stopdelivery(playerid, params[])
{
    if(!PlayerDelivery[playerid][pDeliveryWorking])
        return SendDeliveryMessage(playerid, "You are not working as a delivery driver.", DELIVERY_ERROR);

    EndDeliveryDriver(playerid);

    return 1;

}