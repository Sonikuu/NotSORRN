void onTick( CRules@ this){
	if(isClient()){
		client_AddToChat("Welcome to NotNSORRN. Did you know we have a discord server? Go to this link {discord.gg/MqkH8ss} or type !discord to join!", SColor(255,255,0,255));
		this.RemoveScript("TextOnJoin.as");
	}
}