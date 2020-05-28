

void onInit(CBlob@ this)
{
	this.set_u8("wiringmode", 0);
	this.addCommandID("setwiringmode");
	AddIconToken("$no_wire$", "WiringIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$alchemy_wire$", "WiringIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$item_wire$", "WiringIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$logic_wire$", "WiringIcons.png", Vec2f(16, 16), 3);
}

void onTick(CBlob@ this)
{
	if(this.isKeyJustPressed(key_pickup))
	{
		this.set_u8("wiringmode", 0);
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	Vec2f ul = gridmenu.getUpperLeftPosition();
    Vec2f lr = gridmenu.getLowerRightPosition();

    Vec2f pos = Vec2f(ul.x, (ul.y + lr.y) / 2) + Vec2f(-84, -216);
    CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(1, 4), "Wiring Mode");
    
    if (menu !is null)
    {
        menu.deleteAfterClick = true;
		menu.SetCaptionEnabled(true);
        {
			CBitStream params;
			params.write_u8(0);
            CGridButton@ button = menu.AddButton("$no_wire$", "Stop Wiring", this.getCommandID("setwiringmode"), params);
			if(this.get_u8("wiringmode") == 0)
				button.SetSelected(1);
        }
		{
			CBitStream params;
			params.write_u8(1);
            CGridButton@ button = menu.AddButton("$alchemy_wire$", "Alchemy Wiring", this.getCommandID("setwiringmode"), params);
			if(this.get_u8("wiringmode") == 1)
				button.SetSelected(1);
        }
		{
			CBitStream params;
			params.write_u8(2);
            CGridButton@ button = menu.AddButton("$item_wire$", "Coming Soon :tm:", this.getCommandID("setwiringmode"), params);
			if(this.get_u8("wiringmode") == 2)
				button.SetSelected(1);
        }
		{
			CBitStream params;
			params.write_u8(3);
            CGridButton@ button = menu.AddButton("$logic_wire$", "Coming Soon :tm:", this.getCommandID("setwiringmode"), params);
			if(this.get_u8("wiringmode") == 3)
				button.SetSelected(1);
        }
        
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("setwiringmode") == cmd)
	{
		this.set_u8("wiringmode", params.read_u8());
		if(this.get_u8("wiringmode") != 0)
		{
			this.DropCarried();
			this.set_TileType("buildtile", 0);
		}
	}
}




















