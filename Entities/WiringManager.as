
#include "WheelMenuCommon.as";

void onInit(CBlob@ this)
{
	this.set_u8("wiringmode", 0);
	this.addCommandID("setwiringmode");
	AddIconToken("$no_wire$", "WiringIcons.png", Vec2f(16, 16), 0);
	AddIconToken("$alchemy_wire$", "WiringIcons.png", Vec2f(16, 16), 1);
	AddIconToken("$item_wire$", "WiringIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$logic_wire$", "WiringIcons.png", Vec2f(16, 16), 3);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CControls@ con = getControls();
	if(blob !is null && con !is null && blob is getLocalPlayerBlob())
	{
		u8 wm = blob.get_u8("wiringmode");
		if(wm != 0)
		{
			GUI::DrawIcon("WiringIcons.png", wm, Vec2f(16, 16), con.getInterpMouseScreenPos() + Vec2f(32, -8));
		}
	}
}

void onTick(CBlob@ this)
{
	if(this.isKeyJustPressed(key_pickup))
	{
		this.set_u8("wiringmode", 0);
	}

	if(isClient() && this is getLocalPlayerBlob())
	{
		
		WheelMenu@ menu = get_wheel_menu("wiring");
		

		if(getControls().isKeyJustPressed(KEY_LCONTROL))
		{
			menu.entries.clear();
			menu.option_notice = "Select Wiring";
			//CInventory@ inv = this.getInventory();
			for (uint i = 0; i < 4; i++)
			{
				{
					IconWheelMenuEntry entry("wiring" + i);
					if(i == 0)
						entry.visible_name = "Cancel Wiring";
					else if(i == 1)
						entry.visible_name = "Alchemic Wiring";
					else if(i == 2)
						entry.visible_name = "Item Wiring";
					else
						entry.visible_name = "Logic Wiring";
					entry.frame = i;
					entry.texture_name = "WiringIcons.png";
					entry.frame_size = Vec2f(16, 16);
					entry.scale = 1.0f;
					entry.offset = Vec2f(0.0f, -3.0f);
					menu.entries.push_back(@entry);
				}
			}
			
			set_active_wheel_menu(menu);
		}
		
		if(menu is get_active_wheel_menu())
		{
			if(getControls().isKeyJustReleased(KEY_LCONTROL) || this.isKeyJustPressed(key_action1))
			{
				WheelMenuEntry@ entry = menu.get_selected();
				
				for(int i = 0; i < menu.entries.length; i++)
				{
					if(menu.entries[i] is entry)
					{		
						CBitStream params;
						params.write_u8(i);
						this.SendCommand(this.getCommandID("setwiringmode"), params);
						break;
					}
				}
				set_active_wheel_menu(null);
			}
		}
	}
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	Vec2f ul = gridmenu.getUpperLeftPosition();
    Vec2f lr = gridmenu.getLowerRightPosition();

    Vec2f pos = Vec2f(ul.x, (ul.y + lr.y) / 2) + Vec2f(-132, -216);
    CGridMenu@ menu = CreateGridMenu(pos, this, Vec2f(1, 4), "Wiring Mode\nTry ctrl to quick change!");
    
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
            CGridButton@ button = menu.AddButton("$item_wire$", "Item Pipe", this.getCommandID("setwiringmode"), params);
			if(this.get_u8("wiringmode") == 2)
				button.SetSelected(1);
        }
		{
			CBitStream params;
			params.write_u8(3);
            CGridButton@ button = menu.AddButton("$logic_wire$", "Logic Wiring", this.getCommandID("setwiringmode"), params);
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




















