//Simple script for turning fireplace into a furnace

void onInit(CBlob@ this)
{
	AddIconToken("$upgrade_fireplace$", "TechnologyIcons.png", Vec2f(16, 16), 18);
	
	this.addCommandID("upgrade");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ held = caller.getCarriedBlob();
	if(held !is null && held.getConfig() == "souldust")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$upgrade_fireplace$", Vec2f(0, -6), this, this.getCommandID("upgrade"), "Turn into binding table", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("upgrade") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null && getNet().isServer())
		{
			CBlob@ held = caller.getCarriedBlob();
			if(held !is null && held.getConfig() == "souldust")
			{
				server_CreateBlob("bindingtable", caller.getTeamNum(), this.getPosition());
				this.server_Die();
				held.server_SetQuantity(held.getQuantity() - 1);
				if(held.getQuantity() <= 0)
					held.server_Die();
			}
		}
	}
}