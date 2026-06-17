CMD:stats(playerid, params[]){

    new string[256];
    format(string, sizeof(string), "Deliveries completed: %d", Player[playerid][DeliveriesCompleted]);
    ShowPlayerDialog(playerid, DIALOG_UNUSED, DIALOG_STYLE_MSGBOX, "Player Stats", string, "Cerrar", "");
    
    return 1;
}