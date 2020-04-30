#include "ElementalCore.as";

//Extremely complicated code below, read at your own risk
void onInit(CBlob@ this)
{
	addCore(this);
	
	this.addCommandID("sync");
	this.addCommandID("recsync");
	this.Tag("hassynccmd");
	
	//Move to a script called something like "haslife", and also have the no ecto/life kill stuff be handled there
	setElement(this, "life", 80);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob !is getLocalPlayerBlob())
		return;
	GUI::SetFont("snes");
	/*
	for (int i = 0; i < elementlist.length; i++)
	{
		GUI::DrawText(elementlist[i].visiblename, Vec2f(getScreenWidth() - 80, i * 50 + 20), elementlist[i].color);
		GUI::DrawText(formatInt(getElement(blob, i), ""), Vec2f(getScreenWidth() - 80, i * 50 + 40), SColor(255, 255, 255, 255));
	}*/
	
	renderElementsRight(getCore(blob).elements, Vec2f(getScreenWidth() - 20, 20), false);
}

void onTick(CBlob@ this)
{
	if(getNet().isServer())
	{
		if(this.get_u32("syncat") <= getGameTime() && this.get_u32("syncat") != 0)
		{
			this.set_u32("syncat", 0);
			CBitStream params;
			params.write_u16(this.get_u16("syncid"));
			this.SendCommandOnlyServer(this.getCommandID("sync"), params);
		}
	}
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("sync") == cmd)
	{
		if(getNet().isServer())
		{
			CPlayer@ player = getPlayerByNetworkId(params.read_u16());
			if(player !is null)
			{
				CElementalCore@ core = getCore(this);
				
				if(core is null)
					return;
				CBitStream elementparams;
				for (uint j = 0; j < core.elements.length; j++)
				{
					elementparams.write_s32(core.elements[j]);
				}
				this.server_SendCommandToPlayer(this.getCommandID("recsync"), elementparams, player);
			}
		}
	}
	else if(this.getCommandID("recsync") == cmd)
	{
		if(getNet().isClient())
		{
			CElementalCore@ core = getCore(this);
			if(core is null)
				return;
			for (uint j = 0; j < core.elements.length; j++)
			{
				core.elements[j] = params.read_s32();
			}
		}
	}
}