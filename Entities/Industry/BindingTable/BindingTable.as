



void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("can settle"); //for DieOnCollapse to prevent 2 second life :)
	
	this.addCommandID("binditem");
	
	AddIconToken("$bind_item$", "TechnologyIcons.png", Vec2f(16, 16), 3);

}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBlob@ held = caller.getCarriedBlob();
	CInventory@ inv = caller.getInventory();
	if(held !is null && inv !is null)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		CButton@ button = caller.CreateGenericButton("$bind_item$", Vec2f(0, 0), this, this.getCommandID("binditem"), "Bind the currently held item to yourself \nCosts 1 soul dust", params);
		if(inv.getItem("souldust") is null)
			button.SetEnabled(false);
		
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	bool isServer = getNet().isServer();

	if (cmd == this.getCommandID("binditem"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			CBlob@ held = caller.getCarriedBlob();
			CInventory@ inv = caller.getInventory();
			CPlayer@ player = caller.getPlayer();
			if(held !is null && inv !is null && inv.getItem("souldust") !is null && player !is null)
			{
				inv.getItem("souldust").server_Die();
				held.AddScript("SoulBound");
				held.set_string("boundtoplayer", player.getUsername());
			}
		}
	}
}

//sprite - planks layer

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 16, 16, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(6);
		planks.SetOffset(Vec2f(3.0f, -7.0f));
		planks.SetRelativeZ(-100);
	}
}
