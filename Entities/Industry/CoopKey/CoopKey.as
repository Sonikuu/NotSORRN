#include "AlchemyCommon.as";

void onInit(CBlob@ this)
{	
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.addCommandID("join");
	this.addCommandID("manage");
	this.addCommandID("kick");
	this.addCommandID("resign");
	this.addCommandID("claim");
	this.addCommandID("sync");
	this.Tag("builder always hit");
	this.set_s32("gold building amount", 80);

	AddIconToken("$claim_team$", "ManagementIcons.png", Vec2f(16, 16), 2);
	AddIconToken("$manage_team$", "ManagementIcons.png", Vec2f(16, 16), 3);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(caller.getTeamNum() > 7 && this.isOverlapping(caller))
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$rotate_butt$", Vec2f(0, 0), this, this.getCommandID("join"), "Join Team", params);
	}
	if(caller.getTeamNum() == this.getTeamNum())
	{
		CPlayer@ p = caller.getPlayer();
		if(p !is null)
		{
			CBitStream params;
			params.write_u16(p.getNetworkID());

			CMap@ map = getMap();
			CPlayer@ leader = getPlayerByUsername(map.get_string("team" + this.getTeamNum() + "leader"));
			bool hasleader = hasValidLeader(this, leader);
			if(!hasleader)
			{
				caller.CreateGenericButton("$claim_team$", Vec2f(0, 0), this, this.getCommandID("claim"), "Claim Team", params);
			}
			else
			{
				CButton@ butt = caller.CreateGenericButton("$manage_team$", Vec2f(0, 0), this, this.getCommandID("manage"), "Manage Team", params);
				butt.enableRadius = 999;
			}
		}
	}
}

bool hasValidLeader(CBlob@ this, CPlayer@ leader)
{
	return !(leader is null || leader.getTeamNum() != this.getTeamNum());
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
				if(isServer())
				{
					CMap@ map = getMap();
					CBitStream para;
					para.write_string(map.get_string("team" + this.getTeamNum() + "leader"));
					this.SendCommand(this.getCommandID("sync"), para);
				}
			}
		}
	}
	else if (cmd == this.getCommandID("sync"))
	{
		CMap@ map = getMap();
		if(isClient())
		{
			string leader = params.read_string();
			map.set_string("team" + this.getTeamNum() + "leader", leader);
		}
	}
	else if (cmd == this.getCommandID("manage"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		CPlayer@ p = getPlayerByNetworkId(callerID);
		if(p !is null)
		{
			CBlob@ b = p.getBlob();
			if(p is getLocalPlayer() && b !is null)
			{
				CMap@ map = getMap();
				bool isleader = map.get_string("team" + this.getTeamNum() + "leader") == p.getUsername();
				//Menu eww
				int playercount = 0;
				for(int i = 0; i < getPlayerCount(); i++)
				{
					if(getPlayer(i).getTeamNum() == this.getTeamNum())
						playercount++;
				}
				CGridMenu@ menu = CreateGridMenu(Vec2f(getScreenWidth() / 2, getScreenHeight() / 2), this, Vec2f(5, playercount), "Manage Team");
				for(int i = 0; i < getPlayerCount(); i++)
				{
					CPlayer@ np = getPlayer(i);
					if(np.getTeamNum() == this.getTeamNum())
					{
						CGridButton@ butt = menu.AddTextButton(np.getUsername(), Vec2f(4, 1));
						butt.clickable = false;
						CBitStream pram;
						pram.write_u16(getLocalPlayer().getNetworkID());
						pram.write_u16(np.getNetworkID());

						if(np is p && isleader)
						{
							CGridButton@ kick = menu.AddButton("ManagementIcons.png", 1, Vec2f(16, 16), "Resign", this.getCommandID("resign"), Vec2f(1, 1), pram);
							kick.clickable = true;
						}
						else
						{
							CGridButton@ kick = menu.AddButton("ManagementIcons.png", 0, Vec2f(16, 16), "Kick Player", this.getCommandID("kick"), Vec2f(1, 1), pram);
							kick.SetEnabled(isleader);
						}
					}
				}
			}
		}
	}
	else if (cmd == this.getCommandID("kick"))
	{
		u16 callerID = params.read_u16();
		u16 onID = params.read_u16();
		CPlayer@ c = getPlayerByNetworkId(callerID);
		CPlayer@ on = getPlayerByNetworkId(onID);
		if(c !is null && on !is null)
		{
			CMap@ map = getMap();
			bool isleader = map.get_string("team" + this.getTeamNum() + "leader") == c.getUsername();
			if(isleader)
			{
				on.server_setTeamNum(-1);
				CBlob@ b = on.getBlob();
				if(b !is null)
					b.server_Die();
				client_AddToChat(on.getUsername() + " has been kicked!", SColor(255, 200, 150, 0));
			}
		}
	}
	else if (cmd == this.getCommandID("resign"))
	{
		u16 callerID = params.read_u16();
		u16 onID = params.read_u16();
		CPlayer@ c = getPlayerByNetworkId(callerID);
		if(c !is null && onID == callerID)
		{
			CMap@ map = getMap();
			bool isleader = map.get_string("team" + this.getTeamNum() + "leader") == c.getUsername();
			if(isleader)
			{
				map.set_string("team" + this.getTeamNum() + "leader", "");
				client_AddToChat(c.getUsername() + " has resigned!", SColor(255, 200, 150, 0));
			}
		}
	}
	else if (cmd == this.getCommandID("claim"))
	{
		u16 callerID = params.read_u16();
		CPlayer@ c = getPlayerByNetworkId(callerID);
		if(c !is null)
		{
			CMap@ map = getMap();
			CPlayer@ leader = getPlayerByUsername(map.get_string("team" + this.getTeamNum() + "leader"));
			if(!hasValidLeader(this, leader))
			{
				map.set_string("team" + this.getTeamNum() + "leader", c.getUsername());
				client_AddToChat(c.getUsername() + " has become a leader!", SColor(255, 200, 150, 0));
			}
		}
	}
}
