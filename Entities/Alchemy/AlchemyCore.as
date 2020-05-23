//Basic alchemy setup and ticking maybe?
//Will also handle syncing to new players, since it wont be done automatically

#include "AlchemyCommon.as";

const float maxrange = 128;

void onInit(CBlob@ this)
{
	addTankController(this);
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
	CControls@ controls = getControls();
	CCamera@ camera = getCamera();
	if(controls is null || blob is null)
		return;
	GUI::SetFont("snes");
	CAlchemyTankController@ controller = getTankController(blob);
	if(controller is null)
		return;
	for (uint i = 0; i < controller.tanks.length; i++)
	{
		Vec2f tankpos = (controller.tanks[i].offset * camera.targetDistance * 2 + blob.getScreenPos());
		if((tankpos - controls.getMouseScreenPos()).Length() < 24)
		{
			renderElementsCentered(controller.tanks[i].storage.elements, tankpos);
		}
	}
	
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	
	CAlchemyTankController@ controller = getTankController(blob);
	if(controller is null)
		return;
	
	for (uint i = 0; i < controller.tanks.length; i++)
	{
		int ltid = controller.tanks[i].lasttransfer;
		//Since apparently SetColor is broken and worthless we'll just make our own sprites on the go
		if(blob.get_s16("transfercache" + i) != ltid)
		{
			CSpriteLayer@ pipe = this.getSpriteLayer("pipe" + i);
			CSpriteLayer@ pipestart = this.getSpriteLayer("pipestart" + i);
			CSpriteLayer@ pipeend = this.getSpriteLayer("pipeend" + i);
			
			
			
			if(pipe !is null && pipestart !is null && pipeend !is null)
			{
				if(ltid == -1)
				{
					pipe.ReloadSprite("AlchemyPipe.png");
					pipestart.ReloadSprite("AlchemyPipe.png");
					pipeend.ReloadSprite("AlchemyPipe.png");
				}
				else
				{
					if(!Texture::exists("AlchemyPipe" + ltid))
					{
						//print("Making image");
						//Makes base alchemypipe texture
						//Making our modified version directly from file seems to have strange side effects
						if(!Texture::exists("AlchemyPipe"))
							Texture::createFromFile("AlchemyPipe", "AlchemyPipe.png");
						//print("New img: " + ltid);
						ImageData@ newimage = Texture::data("AlchemyPipe");
						for(uint x = 0; x < newimage.width(); x++)
						{
							for(uint y = 0; y < newimage.height(); y++)
							{
								SColor mixcolor = newimage.get(x, y);
								mixcolor.set(mixcolor.getAlpha(), 
								float(mixcolor.getRed() * elementlist[ltid].color.getRed()) / 255.0, 
								float(mixcolor.getGreen() * elementlist[ltid].color.getGreen()) / 255.0, 
								float(mixcolor.getBlue() * elementlist[ltid].color.getBlue()) / 255.0);
								newimage.put(x, y, mixcolor);
							}
						}
						Texture::createFromData("AlchemyPipe" + ltid, newimage);
					}
					//print("Setting tex");
					pipe.SetTexture("AlchemyPipe" + ltid);
					pipestart.SetTexture("AlchemyPipe" + ltid);
					pipeend.SetTexture("AlchemyPipe" + ltid);
				}
			}
				//pipe.SetColor(controller.tanks[i].lasttransfer == -1 ? SColor(255, 255, 255, 255) : elementlist[controller.tanks[i].lasttransfer].color);
			blob.set_s16("transfercache" + i, ltid);
		}
		
		if(controller.tanks[i].connection !is null && (controller.tanks[i].dynamicconnection || controller.tanks[i].connection.dynamicconnection))
		{
			CBlob@ toblob = getBlobByNetworkID(controller.tanks[i].connectionid);
			if(toblob !is null)
				updateSprite(blob, toblob, controller.tanks[i], controller.tanks[i].connection, i, false);
		}
	}
}

void onTick(CBlob@ this)
{
	CAlchemyTankController@ controller = getTankController(this);
	
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
					float dist = (b.getPosition() - this.getPosition()).Length();
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

	
	for (uint i = 0; i < controller.tanks.length; i++)
	{
		//controller.tanks[i].lasttransfer = -1;
		if(controller.tanks[i].connection !is null)
		{
			CBlob@ toblob = getBlobByNetworkID(controller.tanks[i].connectionid);
			if(toblob is null)
			{
				if(isServer())
				{
					//Detach on death
					CBitStream params;
					params.write_u8(i);
					this.SendCommand(this.getCommandID("disconnect"), params);
				}
			}
			else
			{
				if((getWorldTankPos(this, getTank(this, i)) - getWorldTankPos(toblob, controller.tanks[i].connection)).Length() > maxrange)
				{
					if(isServer())
					{
						//Detach out of range
						CBitStream params;
						params.write_u8(i);
						this.SendCommand(this.getCommandID("disconnect"), params);
					}
				}
				else if(toblob.isInInventory() || this.isInInventory())
				{
					if(isServer())
					{
						//Detach if in inv
						CBitStream params;
						params.write_u8(i);
						this.SendCommand(this.getCommandID("disconnect"), params);
					}
				}
				else
				{
					if(controller.tanks[i].connection.singleelement)
						transferOnly(controller.tanks[i], controller.tanks[i].connection, this.get_u16("transferrate"), firstId(controller.tanks[i].connection));
					else if(controller.tanks[i].connection.onlyele < elementlist.length)
						transferOnly(controller.tanks[i], controller.tanks[i].connection, this.get_u16("transferrate"), controller.tanks[i].connection.onlyele);
					else
						transferSimple(controller.tanks[i], controller.tanks[i].connection, this.get_u16("transferrate"));
				}
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if((this.hasTag("building") && this.isAttached()) || (this.getTeamNum() != caller.getTeamNum() && !(this.getTeamNum() > 7 && caller.getTeamNum() > 7)))
		return;
	CAlchemyTankController@ controller = getTankController(this);
	
	if(controller is null)
		return;
		
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
		//Disconnect
		else if(controller.tanks[i].connection !is null)
		{
			CBitStream params;
			params.write_u8(i);
			caller.CreateGenericButton("$disconnect_alc$", buttonpos, this, this.getCommandID("disconnect"), "Disconnect", params);
		}
		//Cancel connection
		else if(caller.get_bool("connectingalchemy") && caller.get_u16("connectingblob") == this.getNetworkID())
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			//params.write_u8(i);
			//params.write_u16(caller.get_u16("connectingblob"));
			//params.write_u8(caller.get_u8("tankid"));
			caller.CreateGenericButton("$cancel_alc$", buttonpos, this, this.getCommandID("cancel"), "Cancel Connection", params);
		}
		//Finishing connection
		else if(caller.get_bool("connectingalchemy") && controller.tanks[i].input/* && caller.get_u16("connectingblob") != this.getNetworkID()*/)
		{
			//If you think this is too many params to write:
			//It's to make sure that players joining while in the process of connecting dont get desynced
			//Also maybe could make syncing to new joins easier
			CBlob@ connectblob = getBlobByNetworkID(caller.get_u16("connectingblob"));
			if(connectblob !is null)
			{
				CBitStream params;
				params.write_u16(caller.getNetworkID());
				params.write_u8(i);
				params.write_u16(caller.get_u16("connectingblob"));
				params.write_u8(caller.get_u8("tankid"));
				CAlchemyTank@ tank = getTank(connectblob, caller.get_u8("tankid"));
				if(tank !is null && (getWorldTankPos(this, getTank(this, i)) - getWorldTankPos(connectblob, tank)).Length() <= maxrange)
				{
					caller.CreateGenericButton("$connect_alc$", buttonpos, this, this.getCommandID("connect"), "Connect To", params);
				}
				else
				{
					caller.CreateGenericButton("$connect_alc$", buttonpos, this, this.getCommandID("connect"), "Out of Range!", params).SetEnabled(false);
				}
			}
			else
			{
				caller.set_bool("connectingalchemy", false);
			}
		}
		//Starting connection
		else if(!caller.get_bool("connectingalchemy") && !controller.tanks[i].input)
		{
			CBitStream params;
			params.write_u16(caller.getNetworkID());
			params.write_u8(i);
			//params.write_u16(caller.get_u16("connectingblob"));
			//params.write_u8(caller.get_u8("tankid"));
			caller.CreateGenericButton("$connect_alc$", buttonpos, this, this.getCommandID("startconnect"), "Connect From", params);
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
					CAlchemyTank@ fromtank = getTank(connecttank, targtank);
					CAlchemyTank@ totank = getTank(this, tankid);
					if(fromtank is null || totank is null)
					{
						//printInt("Fromtank null with ID: ", targtank);
						return;
					}
					
					//This is pretty hacky but oh wellllllllllll
					if(isequipcmd)
					{
						CAlchemyTank@ interm = @fromtank;
						@fromtank = @totank;
						@totank = @interm;
					}
					if(fromtank.connection !is totank)
					{
						@fromtank.connection = @totank;
						fromtank.connectionid = isequipcmd ? connecttank.getNetworkID() : this.getNetworkID();
						fromtank.dynamicconnection = totank.dynamictank || fromtank.dynamictank;
						
						if(isequipcmd)
							updateSprite(this, connecttank, totank, fromtank, tankid);
						else
							updateSprite(connecttank, this, fromtank, totank, targtank);
					}
				}
				if(caller !is null)
					caller.set_bool("connectingalchemy", false);
			}
		}
	}
	else if(this.getCommandID("startconnect") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		u8 tankid = params.read_u8();
		if(caller !is null)
		{
			caller.set_bool("connectingalchemy", true);
			caller.set_u16("connectingblob", this.getNetworkID());
			caller.set_u8("tankid", tankid);
		}
	}
	else if(this.getCommandID("cancel") == cmd)
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
			caller.set_bool("connectingalchemy", false);
	}
	else if(this.getCommandID("disconnect") == cmd)
	{
		u8 tankid = params.read_u8();
		CAlchemyTank@ tank = getTank(this, tankid);
		if(tank !is null)
			disconnectTank(this, tank, tankid);
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
				CAlchemyTankController@ controller = getTankController(this);
				if(controller is null)
					return;
				for (uint i = 0; i < controller.tanks.length; i++)
				{
					if(controller.tanks[i].connection !is null)
					{
						CBlob@ toblob = getBlobByNetworkID(controller.tanks[i].connectionid);
						if(toblob !is null)
						{
							CAlchemyTankController@ targcontroll = getTankController(toblob);
							CBitStream newparams;
							newparams.write_u16(0xFFFF);//Shouldnt matter much
							//What a mess
							//Hope it works
							newparams.write_u8(targcontroll.getTankID(controller.tanks[i].connection.name));
							newparams.write_u16(this.getNetworkID());
							newparams.write_u8(i);
							toblob.server_SendCommandToPlayer(toblob.getCommandID("connect"), newparams, player);
							//ok, so thats connections synced... next is tank storage... urgh
						}
					}

					CBitStream elementparams;
					elementparams.write_u8(i);
					CElementalCore@ storage = @controller.tanks[i].storage;
					for (uint j = 0; j < storage.elements.length; j++)
					{
						elementparams.write_s32(storage.elements[j]);
					}
					this.server_SendCommandToPlayer(this.getCommandID("recsync"), elementparams, player);
					//Maybe works? might actually be too much data to send at once lel
					//oh well
				}
			}
		}
	}
	else if(this.getCommandID("recsync") == cmd)
	{
		if(getNet().isClient())
		{
			//Not gonna check null for this one cause this kinda needs to happen
			CAlchemyTankController@ controller = getTankController(this);
			u8 tankid = params.read_u8();
			if(controller.tanks.length > tankid)
			{
				CElementalCore@ storage = @controller.tanks[tankid].storage;
				for (uint j = 0; j < storage.elements.length; j++)
				{
					storage.elements[j] = params.read_s32();
				}
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

void disconnectTank(CBlob@ blob, CAlchemyTank@ tank, u8 tankid)
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
}

void updateSprite(CBlob@ blob, CBlob@ toblob, CAlchemyTank@ fromtank, CAlchemyTank@ totank, int tankid, bool deletelayer = true)
{
	CSprite@ sprite = blob.getSprite();
					
	//Making the tube bit
	if(sprite !is null)
	{	
		CSpriteLayer@ pipe;
		CSpriteLayer@ pipestart;
		CSpriteLayer@ pipeend;
		string idstr = formatInt(tankid, "");
		
		Vec2f topos = getWorldTankPos(toblob, totank);
		Vec2f frompos = getWorldTankPos(blob, fromtank);
		
		if(deletelayer)
		{
			sprite.RemoveSpriteLayer("pipe" + idstr);//Shouldnt be necessary, but hey, you never know
			sprite.RemoveSpriteLayer("pipestart" + idstr);
			sprite.RemoveSpriteLayer("pipeend" + idstr);
			//sprite.RemoveSpriteLayer("pipefluid" + idstr);
			@pipe = sprite.addSpriteLayer("pipe" + idstr, "AlchemyPipe.png", 8, 8);
			pipe.SetRelativeZ(-3);
			pipe.SetFrame(1);
			pipe.SetIgnoreParentFacing(true);
			pipe.SetFacingLeft(false);
			
			@pipestart = sprite.addSpriteLayer("pipestart" + idstr, "AlchemyPipe.png", 8, 8);
			pipestart.SetRelativeZ(-2);
			pipestart.SetFrame(0);
			pipestart.SetIgnoreParentFacing(true);
			pipestart.SetFacingLeft(false);
			
			@pipeend = sprite.addSpriteLayer("pipeend" + idstr, "AlchemyPipe.png", 8, 8);
			pipeend.SetRelativeZ(-2);
			pipeend.SetFrame(2);
			pipeend.SetIgnoreParentFacing(true);
			pipeend.SetFacingLeft(false);
		}
		else
		{
			@pipe = sprite.getSpriteLayer("pipe" + idstr);
			@pipestart = sprite.getSpriteLayer("pipestart" + idstr);
			@pipeend = sprite.getSpriteLayer("pipeend" + idstr);
		}
		
		if(pipe is null || pipeend is null || pipestart is null)
		{
			warn("Null sprite layer for pipes in alchemycore!");
			return;
		}
		
		pipe.ResetTransform();
		pipeend.ResetTransform();
		pipestart.ResetTransform();
		
		//CSpriteLayer@ pipefluid = sprite.addSpriteLayer("pipefluid" + idstr, "PixelWhite.png", 1, 1);
		//pipefluid.SetRelativeZ(1);
		//pipefluid.SetColor(SColor(0, 0, 0, 0));
		//pipefluid.setRenderStyle(RenderStyle::shadow);
		
		
		
		Vec2f diff = (topos) - (frompos);
		Vec2f enddiff = topos - blob.getPosition();
		enddiff.RotateBy(-blob.getAngleDegrees());
		
		Vec2f tempoffs = -totank.offset;
		tempoffs.RotateBy(blob.getAngleDegrees());
		tempoffs += diff;
		tempoffs.RotateBy(-blob.getAngleDegrees());
		
		pipe.ScaleBy(Vec2f(diff.Length() / 8.0, 1));
		pipe.RotateBy(diff.Angle() * -1 + 360 - blob.getAngleDegrees(), Vec2f(diff.Length() / 2, 0));
		pipe.TranslateBy(fromtank.offset + Vec2f(diff.Length() / 2, 0));
		
		//pipefluid.ScaleBy(Vec2f(diff.Length(), 2));
		//pipefluid.RotateBy(diff.Angle() * -1 + 360, Vec2f(diff.Length() / 2, 0));
		//pipefluid.TranslateBy(fromtank.offset + Vec2f(diff.Length() / 2, 0));
		
		pipeend.RotateBy(diff.Angle() * -1 + 360 -blob.getAngleDegrees(), Vec2f_zero);
		pipeend.TranslateBy(enddiff);
		
		//diff *= 8.0 / diff.Length() + 1.0;
		
		pipestart.RotateBy(diff.Angle() * -1 + 360 -blob.getAngleDegrees(), Vec2f_zero);
		pipestart.TranslateBy(fromtank.offset);
	}
}

Vec2f getWorldTankPos(CBlob@ blob, CAlchemyTank@ tank)
{
	Vec2f offset = tank.offset;
	Vec2f topos = blob.getPosition() + offset.RotateBy(blob.getAngleDegrees());
		
		
	if(blob.get_bool("equipped"))
	{
		CBlob@ equipper = getBlobByNetworkID(blob.get_u16("equipper"));
		if(equipper !is null)
			topos = equipper.getPosition();
	}
	
	return topos;
}





