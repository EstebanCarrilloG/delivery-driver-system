main() {}

public OnGameModeInit()
{
	ConnectToDatabase();
	UsePlayerPedAnims();
	return 1;
}

public OnGameModeExit()
{
	print("Game mode exited.");
	return 1;
}