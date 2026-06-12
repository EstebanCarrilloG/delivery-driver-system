SetVehicleAsDeliveryVehicle(vehicleid)
{
    if(vehicleid != INVALID_VEHICLE_ID)
    {
        DeliveryVehicle[vehicleid][dvDoorsOpen] = false;
        DeliveryVehicle[vehicleid][dvPlayerid] = INVALID_PLAYER_ID;
        DeliveryVehicle[vehicleid][dvCreated] = true;
        DeliveryVehicle[vehicleid][dvInUse] = false;
        DeliveryVehicle[vehicleid][dvPackages] = 0; 
    }
}

CleanupDeliverySystem(){

    // Destroy delivery vans
    for(new i = 1; i < MAX_VEHICLES; i++)
    {
        if(DeliveryVehicle[i][dvCreated])
        {
            DestroyVehicle(i);
            DeliveryVehicle[i][dvDoorsOpen] = false;
        	DeliveryVehicle[i][dvPlayerid] = INVALID_PLAYER_ID;
        	DeliveryVehicle[i][dvCreated] = true;
        	DeliveryVehicle[i][dvInUse] = false;
        	DeliveryVehicle[i][dvPackages] = 0; 
        }
    }

    // Finish all delivery jobs
    for(new i = 1; i < MAX_PLAYERS; i++)
    {
		if(PlayerDelivery[i][pDeliveryWorking])
        {
            DestroyDynamicMapIcon(PlayerDelivery[i][pDeliveryCurrentIcon]);
            DestroyDynamicCP(PlayerDelivery[i][pDeliveryCurrentCheckpoint]);
            PlayerTextDrawDestroy(i, DeliveryTD[i]);
            DeletePlayer3DTextLabel(i, deliveryVan3DTextId[i]);
            RemovePlayerAttachedObject(i, INDEX_ATTACHED_PACKAGE);
            SetPlayerSpecialAction(i, SPECIAL_ACTION_NONE);
            ResetPlayerDeliveryProps(i);
		}		
	}


}

ResetPlayerDeliveryProps(playerid)
{
    PlayerDelivery[playerid][pDeliveryWorking] = false;
	PlayerDelivery[playerid][pDeliveryInProgress] = false;
    PlayerDelivery[playerid][pDeliveryCurrentCheckpoint] = INVALID_CHECKPOINT_ID;
	PlayerDelivery[playerid][pDeliveryCurrentIcon] = INVALID_MAPICON_ID;
    PlayerDelivery[playerid][pDeliveryDestination] = -1;
    PlayerDelivery[playerid][pDeliveryHasPackageInHand] = false;
}

EndDeliveryDriver(playerid)
{
    new vehicleid = PlayerDelivery[playerid][pDeliveryVehicle];

    DestroyIconAndCP(playerid);
    ResetDeliveryVehicleProps(vehicleid);
	ResetPlayerDeliveryProps(playerid);
    PlayerTextDrawDestroy(playerid, DeliveryTD[playerid]);
    DeletePlayer3DTextLabel(playerid, deliveryVan3DTextId[playerid]);
	SendDeliveryMessage(playerid, "You are no longer working as a delivery driver.", DELIVERY_ERROR);
    RemovePlayerAttachedObject(playerid, INDEX_ATTACHED_PACKAGE);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
}

LoadDeliveryPackages(playerid)
{
    new vehicleid = PlayerDelivery[playerid][pDeliveryVehicle];

    DeliveryVehicle[vehicleid][dvPackages] = MAX_DELIVERY_PACKAGES;

    SendDeliveryMessage(playerid, "Packages loaded into the van.", DELIVERY_SUCCESS);

    return 1;
}

// --------- Text Draw init -----------------
CreateDeliveryTextdraw(playerid)
{
    DeliveryTD[playerid] = CreatePlayerTextDraw(playerid,500.0, 400.0,"Packages in the van: 0");

    PlayerTextDrawLetterSize(playerid, DeliveryTD[playerid], 0.23, 0.95); // Escala ligeramente reducida para mayor nitidez
    PlayerTextDrawColor(playerid, DeliveryTD[playerid], 0x2ECC71FF);     // Verde esmeralda moderno (menos chillón)
    PlayerTextDrawBackgroundColor(playerid, DeliveryTD[playerid], 0x000000FF); // Fondo negro puro para el contorno
    PlayerTextDrawFont(playerid, DeliveryTD[playerid], 2);               // Fuente delgada / estilizada (Tipo 2)
    PlayerTextDrawSetOutline(playerid, DeliveryTD[playerid], 1);         // Contorno de 1 píxel para legibilidad absoluta
    PlayerTextDrawSetProportional(playerid, DeliveryTD[playerid], 1);    // Proporciones de espaciado activadas
    PlayerTextDrawShow(playerid, DeliveryTD[playerid]);                  // Muestra el textdraw

    return 1;
}

UpdateDeliveryTextdraw(playerid)
{
    new string[64];
    new vehicleid = PlayerDelivery[playerid][pDeliveryVehicle];

    format(string, sizeof(string),"Packages in the van: %d",DeliveryVehicle[vehicleid][dvPackages]);
    PlayerTextDrawSetString(playerid, DeliveryTD[playerid],string);

    return 1;
}

// --------- Text Draw end -----------------

AssignDelivery(playerid){

    //Handle available delivery locvations
    new availablePlaces = 0;

    for(new i = 0; i < sizeof(DeliveryPoints); i++)
    {
        if(!DeliveryPoints[i][visited]) availablePlaces++;
    }

    if(availablePlaces == 0)
    {
        for(new i = 0; i < sizeof(DeliveryPoints); i++)
        {
            DeliveryPoints[i][visited] = false;
        }
    }

    new rand = -1;

    do{
        rand = random(sizeof(DeliveryPoints));
    }
    while(DeliveryPoints[rand][visited] == true);

    PlayerDelivery[playerid][pDeliveryDestination] = rand;

    SendDeliveryMessage(playerid, "You have been assigned a new delivery. Drive to the location shown on map.");

    PlayerDelivery[playerid][pDeliveryCurrentIcon] = CreateDynamicMapIcon(DeliveryPoints[rand][dPosX], DeliveryPoints[rand][dPosY], DeliveryPoints[rand][dPosZ], 51, 0, -1, -1, playerid, 10000.0, MAPICON_GLOBAL);
    PlayerDelivery[playerid][pDeliveryCurrentCheckpoint] = CreateDynamicCP(DeliveryPoints[rand][dPosX], DeliveryPoints[rand][dPosY], DeliveryPoints[rand][dPosZ], 1.0, -1, -1, playerid, 100.0);

    return 1;

}

bool:VehicleHasPackages(vehicleid)
{
    return DeliveryVehicle[vehicleid][dvPackages] > 0;
}

CompleteDelivery(playerid){

    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);

    if(!IsPlayerNearVan(playerid, DELIVERY_SUCCESS_DISTANCE))
    {
        PlayerDelivery[playerid][pDeliveryHasPackageInHand] = false;
        RemovePlayerAttachedObject(playerid, INDEX_ATTACHED_PACKAGE);
        return SendDeliveryMessage(playerid, "You van must be nearby to complete the delivery.", DELIVERY_ERROR);
    }

    ApplyDeliveryAnimation(playerid);
    
    PlayerDelivery[playerid][pDeliveryHasPackageInHand] = false;

    new vehicleid = PlayerDelivery[playerid][pDeliveryVehicle];

    DeliveryVehicle[vehicleid][dvPackages]--;

    UpdateDeliveryTextdraw(playerid);
    GivePlayerMoney(playerid, DELIVERY_PAYOUT);        
    DestroyIconAndCP(playerid);

    PlayerDelivery[playerid][pDeliveryCurrentCheckpoint] = INVALID_CHECKPOINT_ID;

    new deliveryPoint = PlayerDelivery[playerid][pDeliveryDestination];

    DeliveryPoints[deliveryPoint][visited] = true;
    PlayerDelivery[playerid][pDeliveryDestination] = -1;

    new msg[128];

    format(msg, sizeof(msg), "Success: Delivery processed successfully. Package delivered. Payment received: $%d", DELIVERY_PAYOUT);
    SendDeliveryMessage(playerid, msg, DELIVERY_SUCCESS);

    PlayerDelivery[playerid][pDeliveryInProgress] = false;

    if(VehicleHasPackages(vehicleid)) 
    {
        SendDeliveryMessage(playerid, "You can request another delivery using /nextdelivery.");
    }

    return 1;
}


SendDeliveryMessage(playerid, const message[], type = DELIVERY_INFO)
{
    new msg[144];
    
    switch(type)
    {
        case DELIVERY_SUCCESS: {
            format(msg, sizeof(msg), "{00FF00}[DELIVERY] %s", message);
        }
        case DELIVERY_ERROR: {
            format(msg, sizeof(msg), "{FF0000}[DELIVERY] %s", message);
        }
        default: {
            format(msg, sizeof(msg), "{00FF00}[DELIVERY] {FFFF00}%s", message);
        }
    }
    
    SendClientMessage(playerid, 0xFFFFFFFF, msg);

    return 1;
}

DestroyIconAndCP(playerid)
{
    DestroyDynamicMapIcon(PlayerDelivery[playerid][pDeliveryCurrentIcon]);
    DestroyDynamicCP(PlayerDelivery[playerid][pDeliveryCurrentCheckpoint]);
}

ResetDeliveryVehicleProps(vehicleid)
{
    DeliveryVehicle[vehicleid][dvInUse] = false;
    DeliveryVehicle[vehicleid][dvPackages] = -1;
    DeliveryVehicle[vehicleid][dvPlayerid] = -1;
    DeliveryVehicle[vehicleid][dvDoorsOpen] = false;
}

stock Float:GetPlayerDistanceToPoint(playerid, Float:x, Float:y, Float:z)
{
    new Float:px, Float:py, Float:pz;
    GetPlayerPos(playerid, px, py, pz);
    return VectorSize(px-x, py-y, pz-z);
}

IsPlayerNearDeliveryPoint(playerid, const Float:distance){

    new currentCP = PlayerDelivery[playerid][pDeliveryDestination];

    new Float:dpX = DeliveryPoints[currentCP][dPosX];
    new Float:dpY = DeliveryPoints[currentCP][dPosY];
    new Float:dpZ = DeliveryPoints[currentCP][dPosZ];

    if(GetPlayerDistanceToPoint(playerid, dpX, dpY, dpZ) < distance)
    {
        return true;
    }
    return false;
}

IsPlayerNearVan(playerid, Float:distance)
{
    new vehicleid = PlayerDelivery[playerid][pDeliveryVehicle];

    new Float:vX, Float:vY, Float:vZ, Float:angle;
    GetVehiclePos(vehicleid, vX, vY, vZ);
    GetVehicleZAngle(vehicleid, angle);

    // Van middle back doors point
    new Float:backX = vX - (floatsin(-angle, degrees) * 3.0);
    new Float:backY = vY - (floatcos(-angle, degrees) * 3.0);
    new Float:backZ = vZ;

    return (GetPlayerDistanceToPoint(playerid, backX, backY, backZ) <= distance
    );
}

ApplyDeliveryAnimation(playerid)
{
    ApplyAnimation(playerid, "BOMBER", "BOM_Plant_2Idle", 3.2, 0, 0, 0, 1, 0, 1);

    if(IsPlayerAttachedObjectSlotUsed(playerid, INDEX_ATTACHED_PACKAGE)) 
    {
        RemovePlayerAttachedObject(playerid, INDEX_ATTACHED_PACKAGE); 
    }

    defer ClearDeliveryAnimation(playerid);
    
    return 1;
}

timer ClearDeliveryAnimation[1500](playerid)
{
    ClearAnimations(playerid);
    return 1;
}

ToggleVanDoors(playerid, vehicleid, estado)
{
    new driver, passenger, backdoor, hood;
    
    GetVehicleParamsCarDoors(vehicleid, driver, passenger, backdoor, hood);
    
    if(estado == 1)
    {
        SetVehicleParamsCarDoors(vehicleid, driver, passenger, 1, 1);
        SendDeliveryMessage(playerid, "Back doors of the van are now open.", DELIVERY_INFO);
    }
    else
    {
        SetVehicleParamsCarDoors(vehicleid, driver, passenger, 0, 0);
        SendDeliveryMessage(playerid, "Back doors of the van are now closed.", DELIVERY_INFO);
    }

    DeliveryVehicle[vehicleid][dvDoorsOpen] = !DeliveryVehicle[vehicleid][dvDoorsOpen];

    return 1;
}