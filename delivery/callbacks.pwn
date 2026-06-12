public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Delivery driver system ");
	print("--------------------------------------\n");

	new DeliveryVans[MAX_DELIVERY_VANS][E_VAN_SPAWN_DATA] =
	{
	    {2771.935, -2510.776, 13.740, 0.0},
	    {2768.417, -2510.776, 14.214, 0.0},
	    {2764.599, -2510.776, 14.214, 0.0}
	};

	//Create checkpoint and map icon for loading packages
	CreateDynamicMapIcon(CP_CARGA_X, CP_CARGA_Y, CP_CARGA_Z, 11, 0, -1, -1, -1, 500.0, MAPICON_LOCAL);
	WarehouseLoadingCP =  CreateDynamicCP(CP_CARGA_X, CP_CARGA_Y, CP_CARGA_Z, CP_CARGA_RADIO, -1, -1, -1, 50.0);

	//Create the delivery vans
	for(new i = 0; i < MAX_DELIVERY_VANS; i++)
	{
		new car_id;
		car_id = CreateVehicle(DELIVERY_VAN_ID, DeliveryVans[i][vanSpawnX], DeliveryVans[i][vanSpawnY], DeliveryVans[i][vanSpawnZ], DeliveryVans[i][vanSpawnRot], DELIVERY_VAN_COLOR, DELIVERY_VAN_COLOR, DELIVERY_VAN_SPAWN_TIME);
		SetVehicleAsDeliveryVehicle(car_id);
		printf("Van %d created with the ID: %d", i + 1, car_id);
	}

	return 1;

}

public OnFilterScriptExit()
{
	CleanupDeliverySystem();
    return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
	ResetPlayerDeliveryProps(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerDelivery[playerid][pDeliveryWorking])
	{
		EndDeliveryDriver(playerid);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(PlayerDelivery[playerid][pDeliveryWorking])
	{
		EndDeliveryDriver(playerid);
	}
	
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	new playerid = DeliveryVehicle[vehicleid][dvPlayerid];

	if(!PlayerDelivery[playerid][pDeliveryWorking])
	{
		return 1;
	}

	if(vehicleid == PlayerDelivery[playerid][pDeliveryVehicle])
	{
		EndDeliveryDriver(playerid);
	}

	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	new playerid = DeliveryVehicle[vehicleid][dvPlayerid];

	if(!PlayerDelivery[playerid][pDeliveryWorking])
	{
		return 1;
	}

	if(vehicleid == PlayerDelivery[playerid][pDeliveryVehicle])
	{
		EndDeliveryDriver(playerid);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	PlayerTextDrawHide(playerid, DeliveryTD[playerid]); 
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	
	if (oldstate == PLAYER_STATE_ONFOOT && newstate == PLAYER_STATE_DRIVER) // Player entered a vehicle as a driver
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		//Player not working as a delivery inside delivery van
		if(!PlayerDelivery[playerid][pDeliveryWorking] && DeliveryVehicle[vehicleid][dvCreated])
		{
			return SendDeliveryMessage(playerid, "You have entered a delivery van. Type /startdelivery to begin.", DELIVERY_INFO);
		}
		else
		{	
			// Van doesn't belong to the player
			if(DeliveryVehicle[vehicleid][dvPlayerid] != playerid)
			{
				return SendDeliveryMessage(playerid, "This is not your delivery van.", DELIVERY_ERROR);
			}

			// Van back doors open
			if(DeliveryVehicle[vehicleid][dvDoorsOpen])
			{
				ToggleVanDoors(playerid, vehicleid, 0); // Close doors
			}
			
			PlayerTextDrawShow(playerid, DeliveryTD[playerid]);
		} 
		
	}

	
	
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
	if(!PlayerDelivery[playerid][pDeliveryWorking])
	{
        return 1;
	}

    new vehicleid = GetPlayerVehicleID(playerid);

	if(checkpointid == WarehouseLoadingCP){

    	if(vehicleid != PlayerDelivery[playerid][pDeliveryVehicle])
		{
    		return SendDeliveryMessage(playerid, "You are not in your delivery van.", DELIVERY_ERROR);
		}

		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		{
			return SendDeliveryMessage(playerid, "You must be driving to load packages.", DELIVERY_ERROR);
		}	

		if(DeliveryVehicle[vehicleid][dvPackages] >= MAX_DELIVERY_PACKAGES)
		{
			return SendDeliveryMessage(playerid, "Your van is full. Request a delivery to assign you a delivery location.", DELIVERY_ERROR);
		}

		if(VehicleHasPackages(vehicleid))
		{
			return SendDeliveryMessage(playerid, "Delivery all the packages before Loading more.", DELIVERY_ERROR);
		}

    	LoadDeliveryPackages(playerid);
		UpdateDeliveryTextdraw(playerid);

		SendDeliveryMessage(playerid, "You can now request a delivery using /nextdelivery.", DELIVERY_INFO);
		return 1;
	}

	// Player enter to a delivery checkpoint
	if(checkpointid == PlayerDelivery[playerid][pDeliveryCurrentCheckpoint])
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT)
        {
            return SendDeliveryMessage(playerid, "You must be on foot to deliver.", DELIVERY_ERROR);
        }

		if(!PlayerDelivery[playerid][pDeliveryHasPackageInHand])
        {
            return SendDeliveryMessage(playerid, "Error: You must be carrying a package to deliver it. Get one from the van.", DELIVERY_ERROR);
        }

		SendDeliveryMessage(playerid, "Stay inside the marker for 10 seconds to deliver...", DELIVERY_INFO);

		CompleteDelivery(playerid);

		return 1;
	}

    return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!PlayerDelivery[playerid][pDeliveryWorking])
	{
		return 1;
	}

	new vehicleid = PlayerDelivery[playerid][pDeliveryVehicle];
	
    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
    {
		if(!IsPlayerNearVan(playerid, DELIVERY_VAN_INTERACT_DISTANCE)) return 1;

    	if((newkeys & KEY_YES))
		{
				if(DeliveryVehicle[vehicleid][dvDoorsOpen] == false)
				{
					return SendDeliveryMessage(playerid, "The back doors of the van are closed. Open them first to pick up a package.", DELIVERY_ERROR);
				}

        		if(PlayerDelivery[playerid][pDeliveryHasPackageInHand])
				{	
					return SendDeliveryMessage(playerid, "You are already carrying a package on your hands.", DELIVERY_ERROR);
				}
				
				if(PlayerDelivery[playerid][pDeliveryDestination] == INVALID_CHECKPOINT_ID )
				{
					return SendDeliveryMessage(playerid, "Request a delivery before picking up a package.", DELIVERY_ERROR);
				}

				if(!IsPlayerNearDeliveryPoint(playerid, ALLOWED_PICKUP_PACKAGE_LIMIT)) 
				{
					return SendDeliveryMessage(playerid, "You must be near a delivery point to pick up a package from the van.", DELIVERY_ERROR);
				}

				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				SetPlayerAttachedObject(playerid, INDEX_ATTACHED_PACKAGE, MODEL_PACKAGE_BOX, 5,0.209000,0.35,0.11,-87.30,0.0,14.60,BOX_SCALE,BOX_SCALE,BOX_SCALE);
				
				PlayerDelivery[playerid][pDeliveryHasPackageInHand] = true;
				
				SendDeliveryMessage(playerid, "You have picked up a package from the van. Carry it to the checkpoint.", DELIVERY_INFO);

				ToggleVanDoors(playerid, vehicleid, 0);

				return 1;

			

	   	}
	    if((newkeys & KEY_CTRL_BACK))
		{
			new doorsStatus = DeliveryVehicle[vehicleid][dvDoorsOpen];
    		ToggleVanDoors(playerid, vehicleid, !doorsStatus);
	    }
    }
	
    return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}