// how many seconds until it kicks the player for taking too long to login
#define		SECONDS_TO_LOGIN 	30

// player data
enum E_PLAYERS
{
	ID,
	Name[MAX_PLAYER_NAME],
	Password[65], // the output of SHA256_PassHash function (which was added in 0.3.7 R1 version) is always 256 bytes in length, or the equivalent of 64 Pawn cells
	Money,
	Salt[17],
	Kills,
	Deaths,
	DeliveriesCompleted,
	Cache: Cache_ID,
	bool: IsLoggedIn,
	LoginAttempts,
	LoginTimer
};
new Player[MAX_PLAYERS][E_PLAYERS];

new gPlayerCitySelection[MAX_PLAYERS];

#define CITY_LOS_SANTOS 	0