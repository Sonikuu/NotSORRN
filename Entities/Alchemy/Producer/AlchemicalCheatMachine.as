#include "NodeCommon.as";

void onInit(CBlob@ this)
{	
	addTank(this, "Output, Nerd", false, Vec2f(0, 4));
	
	this.set_string("filter", "none");
	
	AddIconToken("$config_sorter$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	
	this.addCommandID("configmenu");
	this.addCommandID("config");
	
	this.set_u16("transferrate", 10);
}

void onTick(CBlob@ this)
{
	CAlchemyTank@ output = getTank(this, 0);
	
	for (int i = 0; i < elementlist.length; i++)
	{
		output.storage.elements[i] = 0;
	}
	if(elementIdFromName(this.get_string("filter")) >= 0)
	{
		output.storage.elements[elementIdFromName(this.get_string("filter"))] = 10;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton("$config_sorter$", Vec2f(0, -4), this, this.getCommandID("configmenu"), "Configure Sorter", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("configmenu") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller is getLocalPlayerBlob() && caller !is null)
		{
			int buttons = elementlist.length + 1;
			Vec2f screencenter(getScreenWidth() / 2, getScreenHeight() / 2);
			
			CGridMenu@ menu = CreateGridMenu(screencenter - Vec2f(0, 0), this, Vec2f(buttons, 1), "Set Produce");
			
			{
				CBitStream params;
				params.write_u8(255);
				menu.AddButton("$config_sorter$", "Produce None", this.getCommandID("config"), params);
			}
			
			
			for (int i = 0; i < elementlist.length; i++)
			{
				{
					CBitStream params;
					params.write_u8(i);
					menu.AddButton("$config_sorter$", "Produce " + elementlist[i].visiblename, this.getCommandID("config"), params);
				}
			}
		}
	}
	else if(this.getCommandID("config") == cmd)
	{
		u8 filter = params.read_u8();
		
		//Probs not gonna have 254 elements, so this is pretty safe
		string filtername = filter == 255 ? "none" :
							filter == 254 ? "any" :
							elementlist[filter].name;
		
		this.set_string("filter", filtername);
	}
}

