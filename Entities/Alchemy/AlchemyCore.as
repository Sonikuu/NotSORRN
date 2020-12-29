//Basic alchemy setup and ticking maybe?
//Will also handle syncing to new players, since it wont be done automatically

#include "NodeCommon.as";

void onInit(CBlob@ this)
{
	//Note: Later on we should move all node init and tick stuff to a separate file, only not doing now cause im a lazy bum
	addNodeController(this);
	this.addCommandID("startconnect");
	this.addCommandID("connect");
	this.addCommandID("disconnect");
	this.addCommandID("cancel");
	this.addCommandID("sync");
	this.addCommandID("recsync");
	//Already so many commands
	this.addCommandID("connectequip");
	this.addCommandID("erase");
	
	this.Tag("hassynccmd");
	this.Tag("builder always hit");
	
	AddIconToken("$connect_alc$", "InteractionIcons.png", Vec2f(32, 32), 0);
	AddIconToken("$disconnect_alc$", "InteractionIcons.png", Vec2f(32, 32), 1);
	AddIconToken("$cancel_alc$", "InteractionIcons.png", Vec2f(32, 32), 9);
	AddIconToken("$erase_alc$", "InteractionIcons.png", Vec2f(32, 32), 10);
	
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;
	
	//Can be changed in the blob's own scripts
	this.set_u16("transferrate", 1);
	
	for(int i = 0; i < elementlist.length; i++)
	{
		AddIconToken("$element_" + elementlist[i].name + "$", "ElementIcons.png", Vec2f(16, 16), i);
	}
	
}

void onRender(CSprite@ this)
{
	//Change to look gud when possible
	CBlob@ blob = this.getBlob();
	connectSysRender(blob);
	CControls@ controls = getControls();
	CCamera@ camera = getCamera();
	if(controls is null || blob is null)
		return;
	GUI::SetFont("snes");
	CNodeController@ controller = getNodeController(blob);
	if(controller is null)
		return;
	for (uint i = 0; i < controller.tanks.size(); i++)
	{
		Vec2f tankpos = (controller.tanks[i].offset * camera.targetDistance * 2 + blob.getScreenPos());
		if((tankpos - controls.getMouseScreenPos()).Length() < 24)
		{
			renderElementsCentered(controller.tanks[i].storage.elements, tankpos);
		}
	}

	for (uint i = 0; i < controller.nodes.size(); i++)
	{
		controller.nodes[i].onRender(blob);
	}
	
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	CNodeController@ controller = getNodeController(blob);
	if(controller is null)
		return;
	
	for (uint i = 0; i < controller.nodes.length; i++)
	{
		controller.nodes[i].updateSprite(blob, this);
	}
}

void onTick(CBlob@ this)
{
	manageConnectSys(this);
	CNodeController@ controller = getNodeController(this);
	
	if(controller is null)
		return;
	
	//Automatic syncing for nearby blobs
	//Cause sometimes, stuff succs
	if(isServer())
	{
		for (uint i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			
			if(p !is null)
			{
				CBlob@ b = p.getBlob();
				if(b !is null)
				{
					Vec2f topos = this.getPosition();
					if(this.get_bool("equipped"))
					{
						CBlob@ equipper = getBlobByNetworkID(this.get_u16("equipper"));
						if(equipper !is null)
							topos = equipper.getPosition();
					}
					float dist = (b.getPosition() - topos).Length();
					int modmult = dist < 128 ? 1 : dist < 256 ? 3 : 30;
					int mod = 30 * modmult;
					if((this.getNetworkID() * modmult + getGameTime()) % mod == 0)
					{
						CBitStream params;
						params.write_u16(p.getNetworkID());
						this.SendCommand(this.getCommandID("sync"), params);
					}
				}
			}
		}
	}

	
	for (uint i = 0; i < controller.nodes.length; i++)
	{
		//controller.tanks[i].lasttransfer = -1;
		controller.nodes[i].update(this, 0);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if((this.hasTag("building") && this.isAttached()) || (this.getTeamNum() != caller.getTeamNum() && !(this.getTeamNum() > 7 && caller.getTeamNum() > 7)))
		return;
	CNodeController@ controller = getNodeController(this);
	
	if(controller is null)
		return;
		
	//Not going to change tanks here to nodes because I don't really see the point, all of this is tank specific code
	for (uint i = 0; i < controller.tanks.length; i++)
	{
		Vec2f buttonpos = (controller.tanks[i].offset / 2);
		if(this.isFacingLeft())
			buttonpos.x *= -1;
			
		
		CBlob@ equipped = null;
		if(caller.get_u16("primaryequip") != 0xFFFF)
			@equipped = @getBlobByNetworkID(caller.get_u16("primaryequip"));
		//Override for if holding the eraser
		if(caller.getCarriedBlob() !is null && caller.getCarriedBlob().getConfig() == "alchemyeraser")
		{
			if(controller.tanks[i].input)
			{
				CBitStream params;
				params.write_u8(i);
				caller.CreateGenericButton("$erase_alc$", buttonpos, this, this.getCommandID("erase"), "Erase all Essence", params);
			}
		}
		//Special case for alchemy item equipped: connected equipped to selected tank
		else if(equipped !is null && getTank(equipped, 0) !is null && !controller.tanks[i].input)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(i);
			params.write_u16(equipped.getNetworkID());
			params.write_u8(0);
			CAlchemyTank@ tank = getTank(equipped, 0);
			if(tank !is null && (getWorldTankPos(this, getTank(this, i)) - getWorldTankPos(equipped, tank)).Length() <= maxrange)
			{
				caller.CreateGenericButton("$connect_alc$", buttonpos, this, this.getCommandID("connectequip"), "Connect Equipped Item", params);
			}
			else
			{
				caller.CreateGenericButton("$connect_alc$", buttonpos, this, this.getCommandID("connectequip"), "Out of Range!", params).SetEnabled(false);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	bool isequipcmd = this.getCommandID("connectequip") == cmd;
	if(this.getCommandID("connect") == cmd || isequipcmd)
	{
		u16 bnet = params.read_u16();
		CBlob@ caller = null;
		if(bnet != 0xFFFF)
			@caller = getBlobByNetworkID(bnet);
		u8 tankid = params.read_u8();
		CBlob@ connecttank = getBlobByNetworkID(params.read_u16());
		u8 targtank = params.read_u8();
		//if(caller !is null)
		{
			//if(caller.get_bool("connectingalchemy"))
			{
				//CBlob@ connecttank = getBlobByNetworkID(caller.get_u16("connectingblob"));
				if(connecttank !is null && this !is connecttank)
				{
					//CAlchemyTank@ fromtank = getTank(connecttank, caller.get_u8("tankid"));
					INodeCore@ fromtank = getNode(connecttank, targtank);
					INodeCore@ totank = getNode(this, tankid);
					if(fromtank is null || totank is null)
					{
						//printInt("Fromtank null with ID: ", targtank);
						return;
					}
					
					//This is pretty hacky but oh wellllllllllll
					if(isequipcmd)
					{
						INodeCore@ interm = @fromtank;
						@fromtank = @totank;
						@totank = @interm; 
					}
					if(cast<CAlchemyTank@>(fromtank) !is null)//Hacky :(
					{
						CAlchemyTank@ tfromtank = cast<CAlchemyTank@>(fromtank);
						CAlchemyTank@ ttotank = cast<CAlchemyTank@>(totank);
						if(tfromtank.connection !is ttotank)
						{
							tfromtank.connectTo(ttotank, this, connecttank);
							tfromtank.connectionid = isequipcmd ? connecttank.getNetworkID() : this.getNetworkID();
							tfromtank.dynamicconnection = ttotank.dynamictank || tfromtank.dynamictank;
							
							if(isequipcmd)
								updateSpriteNode(this, connecttank, cast<INodeCore@>(ttotank), cast<INodeCore@>(tfromtank));
							else
								updateSpriteNode(connecttank, this, cast<INodeCore@>(tfromtank), cast<INodeCore@>(ttotank));
						}
					}
					else if(cast<CItemIO@>(fromtank) !is null)
					{
						CItemIO@ tfromtank = cast<CItemIO@>(fromtank);
						CItemIO@ ttotank = cast<CItemIO@>(totank);
						if(tfromtank.connection !is ttotank)
						{
							tfromtank.connectTo(ttotank, this, connecttank);
							tfromtank.connectionid = isequipcmd ? connecttank.getNetworkID() : this.getNetworkID();
							tfromtank.dynamicconnection = ttotank.dynamictank || tfromtank.dynamictank;
							
							if(isequipcmd)
								updateSpriteNode(this, connecttank, cast<INodeCore@>(ttotank), cast<INodeCore@>(tfromtank));
							else
								updateSpriteNode(connecttank, this, cast<INodeCore@>(tfromtank), cast<INodeCore@>(ttotank));
						}
					}
				}
				if(caller !is null)
					caller.set_bool("connectingalchemy", false);
			}
		}
	}

	else if(this.getCommandID("disconnect") == cmd)
	{
		u8 nodeid = params.read_u8();
		INodeCore@ node = getNode(this, nodeid);
		if(node !is null)
			node.disconnectAll(this);
	}
	//What this command will need to do is sync both connections and tank storages
	//Might be a bit tough
	else if(this.getCommandID("sync") == cmd)
	{
		if(getNet().isServer())
		{
			CPlayer@ player = getPlayerByNetworkId(params.read_u16());
			if(player !is null)
			{
				CNodeController@ controller = getNodeController(this);
				if(controller is null)
					return;
				for (uint i = 0; i < controller.nodes.length; i++)
				{
					controller.nodes[i].writeSyncData(this, player);
				}
			}
		}
	}
	else if(this.getCommandID("recsync") == cmd)
	{
		if(getNet().isClient())
		{
			//Not gonna check null for this one cause this kinda needs to happen
			CNodeController@ controller = getNodeController(this);
			u8 nodeid = params.read_u8();
			if(controller.nodes.length > nodeid)
			{
				controller.nodes[nodeid].readSyncData(this, params);
			}
		}
	}
	else if(this.getCommandID("erase") == cmd)
	{
		u8 tankid = params.read_u8();
		CAlchemyTank@ tank = getTank(this, tankid);
		if(tank !is null)
		{
			for (uint j = 0; j < tank.storage.elements.length; j++)
			{
				tank.storage.elements[j] = 0;
			}
		}
	}
}

/*void disconnectTank(CBlob@ blob, CAlchemyTank@ tank, u8 tankid)
{
	@tank.connection = null;
	tank.lasttransfer = -1;
		
	CSprite@ sprite = blob.getSprite();
				
	if(sprite !is null)
	{
		sprite.RemoveSpriteLayer("pipe" + formatInt(tankid, ""));
		sprite.RemoveSpriteLayer("pipestart" + formatInt(tankid, ""));
		sprite.RemoveSpriteLayer("pipeend" + formatInt(tankid, ""));
	}
	
	blob.set_s16("transfercache" + tankid, -1);
}*/


u16 fromtanknet = 0;
u8 fromtankid = 0;

u16 hoveredtanknet = 0;
u8 hoveredtankid = 0;

void manageConnectSys(CBlob@ this)
{
	CBlob@ local = getLocalPlayerBlob();
	CControls@ con = getControls();
	if(local !is null && con !is null && this.isPointInside(con.getMouseWorldPos()) && local.get_u8("wiringmode") != 0)
	{
		u8 currmode = local.get_u8("wiringmode");
		Vec2f mousepos = con.getMouseWorldPos();
		u8 nearesttank = 200;
		float nearestdist = 999;
		CNodeController@ controller = getNodeController(this);

	//	print("infdunc");
	
		if(controller is null)
			return;
			
		for (uint i = 0; i < controller.nodes.size(); i++)
		{
			Vec2f thistankpos =  controller.nodes[i].getWorldPosition(this);
			if((thistankpos - mousepos).Length() < nearestdist && 
			(((local.isKeyPressed(key_action1) || local.isKeyJustReleased(key_action1)) && controller.nodes[i].isInput() && fromtanknet != 0) || 
			((!local.isKeyPressed(key_action1) || local.isKeyJustPressed(key_action1)) && !controller.nodes[i].isInput() && !local.isKeyJustReleased(key_action1))))
			{
				if((currmode == 1 && cast<CAlchemyTank@>(controller.nodes[i]) !is null) || 
				(currmode == 2 && cast<CItemIO@>(controller.nodes[i]) !is null))
				{
					nearesttank = i;
					nearestdist = (thistankpos - mousepos).Length();
				}
			}
		}
		hoveredtanknet = this.getNetworkID();
		hoveredtankid = nearesttank;
		if(nearesttank >= controller.nodes.size()) return;
		INodeCore@ seltank = @controller.nodes[nearesttank];
		if(local.isKeyJustPressed(key_action1) && !seltank.isInput())
		{
			
			fromtankid = nearesttank;
			fromtanknet = this.getNetworkID();
		}
		//print("masdasd");
		if(local.isKeyJustPressed(key_action2))
		{
			CBitStream params;
			params.write_u8(hoveredtankid);
			this.SendCommand(this.getCommandID("disconnect"), params);
		}

		if(local.isKeyJustReleased(key_action1))
		{
			CBlob@ fromblob = getBlobByNetworkID(fromtanknet);
			if(fromblob !is null)
			{
				CNodeController@ fromcon = getNodeController(fromblob);
				if(fromcon !is null && fromcon.nodes.size() > fromtankid)
				{
					INodeCore@ fromtank = @fromcon.nodes[fromtankid];
					if(fromtank.isConnectable(seltank, fromblob, this))
					{
						CBitStream params;
						params.write_u16(hoveredtanknet);
						params.write_u8(hoveredtankid);
						params.write_u16(fromtanknet);
						params.write_u8(fromtankid);
						this.SendCommand(this.getCommandID("connect"), params);
					}
				}
			}
		}
	}
	if(local !is null && local.isKeyJustReleased(key_action1) && this.getNetworkID() == hoveredtanknet)
	{
		fromtanknet = 0;
		fromtankid = 0;
	}
}

void connectSysRender(CBlob@ this)
{
	CBlob@ local = getLocalPlayerBlob();
	CControls@ cont = getControls();
	if(this.getNetworkID() == fromtanknet && local !is null && local.isKeyPressed(key_action1) && local.get_u8("wiringmode") != 0)
	{
		Vec2f mousepos = local.getAimPos();
		//CBlob@ netblob = getBlobByNetworkID(fromtanknet);
	//	if(netblob !is null)
		{
			CNodeController@ fromcontroller = getNodeController(this);

			if(fromcontroller !is null && fromcontroller.nodes.size() > fromtankid)
			{
				array<Vertex> vertlist;

				INodeCore@ fromtank = fromcontroller.nodes[fromtankid];

				CBlob@ hovertank = getBlobByNetworkID(hoveredtanknet);
				bool valid = false;
				if(hovertank !is null && hovertank.isPointInside(mousepos))
				{
					CNodeController@ hovercon = getNodeController(hovertank);
					if(hovercon !is null && hoveredtankid < hovercon.nodes.size())
					{
						if(fromtank.isConnectable(hovercon.nodes[hoveredtankid], this, hovertank))
						{
							valid = true;
							mousepos = hovercon.nodes[hoveredtankid].getWorldPosition(hovertank);
						}
					}
				}

				Vec2f startpos = fromtank.getWorldPosition(this);
				Vec2f endvec = mousepos;
				if((startpos - endvec).Length() > maxrange)
				{
					endvec = Vec2f_lengthdir(maxrange, (endvec - startpos).Angle() * -1) + startpos;
				}
				float perp = ((((endvec - startpos).Angle() * -1) / 180.0) * Maths::Pi) + Maths::Pi / 2;
				Vec2f perpoffs(Maths::Cos(perp) * 4, Maths::Sin(perp) * 4);
			
				
				SColor linecol = SColor(255, 200, 255, 200);
				if(!valid)
					 linecol = SColor(255, 255, 0, 0);
				vertlist.push_back(Vertex(startpos.x - perpoffs.x, startpos.y - perpoffs.y, 0, 0.3333, 0, linecol));
				vertlist.push_back(Vertex(endvec.x - perpoffs.x, endvec.y - perpoffs.y, 0, 0.6666, 0, linecol));
				vertlist.push_back(Vertex(endvec.x + perpoffs.x, endvec.y + perpoffs.y, 0, 0.6666, 1, linecol));
				vertlist.push_back(Vertex(startpos.x + perpoffs.x, startpos.y + perpoffs.y, 0, 0.3333, 1, linecol));

				addVertsToExistingRender(@vertlist, "Entities/Alchemy/AlchemyPipe.png", "RLrender");
			}
		}
	}

	//Drawing circle and node name
	if(this.getNetworkID() == hoveredtanknet && local !is null && this.isPointInside(local.getAimPos()) && local.get_u8("wiringmode") != 0)
	{
		CCamera@ cam = getCamera();
		CNodeController@ fromcontroller = getNodeController(this);
		if(fromcontroller !is null && fromcontroller.nodes.size() > hoveredtankid && cam !is null)
		{
			INodeCore@ fromtank = fromcontroller.nodes[hoveredtankid];
			Vec2f drawpos = (fromtank.getWorldPosition(this) - this.getPosition()) / 0.5 * cam.targetDistance + this.getInterpolatedScreenPos();
			GUI::DrawCircle(drawpos, 8, SColor(255, 255, 255, 255));
			GUI::SetFont("menu");
			GUI::DrawTextCentered(fromtank.getName(), drawpos - Vec2f(0, 32), SColor(255, 255, 255, 255));
		}
	}
}

bool canAttachTank(CAlchemyTank@ input, CBlob@ inputblob, CAlchemyTank@ output, CBlob@ outputblob)
{
	return (input !is output && !input.input && output.input && inputblob !is outputblob && (getWorldTankPos(inputblob, input) - getWorldTankPos(outputblob, output)).Length() < maxrange);
}




