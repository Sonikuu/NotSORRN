//Simple script for turning fireplace into a furnace

void onInit(CBlob@ this)
{
	AddIconToken("$upgrade_fireplace$", "TechnologyIcons.png", Vec2f(16, 16), 18);
	
	this.addCommandID("upgrade");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ held = caller.getCarriedBlob();
	if(held !is null && held.getConfig() == "mat_stone")
	{
		CMap@ map = getMap();
		Vec2f urpos = this.getPosition() + Vec2f(4, -12);
		Vec2f ulpos = this.getPosition() + Vec2f(-4, -12);
		bool isblocked = map.isTileSolid(urpos) || map.isTileSolid(ulpos);
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$upgrade_fireplace$", Vec2f(0, 0), this, this.getCommandID("upgrade"), isblocked ? "Cannot build: Blocked" : "Build into furnace", params);
		if(held.getQuantity() < 200 || isblocked)
		{
			button.SetEnabled(false);
		}
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
			if(held !is null && held.getConfig() == "mat_stone" && held.getQuantity() >= 200)
			{
				server_CreateBlob("furnace", caller.getTeamNum(), this.getPosition() - Vec2f(0, 4));
				this.server_Die();
				held.server_SetQuantity(held.getQuantity() - 200);
				if(held.getQuantity() <= 0)
					held.server_Die();
			}
		}
	}
}