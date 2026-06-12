enum E_VAN_SPAWN_DATA{
    Float:vanSpawnX,
    Float:vanSpawnY,
    Float:vanSpawnZ,
    Float:vanSpawnRot
};

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

// Delivery coordinates points 
enum E_DELIVERY_POINT
{
    Float:dPosX,
    Float:dPosY,
    Float:dPosZ,
    bool:visited
};
new DeliveryPoints[MAX_DELIVERY_POINTS][E_DELIVERY_POINT] =
{
    {2503.55, -2410.45, 13.62, false},
    {2615.67, -2382.29, 13.62, false},
    {2731.65, -2487.61, 13.65, false},
    {2529.95, -2529.23, 13.65, false},
    {2219.37, -2666.35, 13.53, false},
    {2231.62, -2414.66, 13.54, false}
};

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