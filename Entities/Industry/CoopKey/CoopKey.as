#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.addCommandID("join");
	this.Tag("builder always hit");
	this.set_s32("gold building amount", 80);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() > 7)
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$rotate_butt$", Vec2f(0, 0), this, this.getCommandID("join"), "Join Team", params);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("join"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		CBlob@ b = getBlobByNetworkID(callerID);
		if(b !is null)
		{
			CPlayer@ p = b.getPlayer();
			if(p !is null)
			{
				p.server_setTeamNum(this.getTeamNum());
				b.server_setTeamNum(this.getTeamNum());
			}
		}
	}
}
