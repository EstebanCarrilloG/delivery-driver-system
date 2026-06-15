enum E_PLAYER_DELIVERY
{
    bool:pDeliveryWorking,
    bool:pDeliveryInProgress,
    pDeliveryVehicle,
    pDeliveryCurrentCheckpoint,
    pDeliveryCurrentIcon,
    pDeliveryDestination,
    bool:pDeliveryHasPackageInHand
};

new PlayerDelivery[MAX_PLAYERS][E_PLAYER_DELIVERY];

enum E_DELIVERY_VEHICLE
{
    bool:dvCreated,
    bool:dvInUse,
    bool:dvDoorsOpen,
    dvPlayerid,
    dvPackages
};

new DeliveryVehicle[MAX_VEHICLES][E_DELIVERY_VEHICLE];

new WarehouseLoadingCP = INVALID_CHECKPOINT_ID;

new PlayerText:DeliveryTD[MAX_PLAYERS];
new PlayerText3D:deliveryVan3DTextId[MAX_PLAYERS];

//Delivery messages types 
enum {
    DELIVERY_INFO,
    DELIVERY_SUCCESS, 
    DELIVERY_ERROR
};

//3D Text showed on van
new DeliveryVan3DText[128] = "{FFFFFF}Press {FFFF00}[H] {FFFFFF}to open/close doors\n\
                              {FFFFFF}Press {FFFF00}[Y] {FFFFFF}to pick up package";