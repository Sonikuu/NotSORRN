

void onRestart( CRules@ this )
{
	if(getNet().isServer())
	{
		CBitStream params;
		this.SendCommand(this.getCommandID("credits"), params);
	}
}

void onInit( CRules@ this )
{
	this.addCommandID("credits");
}

void onCommand( CRules@ this, u8 cmd, CBitStream @params )
{
	if(cmd == this.getCommandID("credits"))
	{
		CMap@ map = getMap();
		if(map !is null && map.getMapName().find("Rob") >= 0)
		{
			client_AddToChat("Many thanks to pirate-rob for allowing us to use his maps!", SColor(255, 50, 50, 200));
		}
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if(getNet().isServer())
	{
		CBitStream params;
		this.SendCommand(this.getCommandID("credits"), params, player);
	}
}