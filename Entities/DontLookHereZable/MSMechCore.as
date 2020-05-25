
#include "MechCommon.as";
#include "Explosion.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.addCommandID("attachpart");
	this.addCommandID("vehicle getout");
	this.addCommandID("partcommand");
	
	CShapeManager manager();
	this.set("shapemanager", @manager);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	AttachmentPoint@[] aps;
	if (blob.getAttachmentPoints(@aps))
	{
		CBlob@ driver = blob.getAttachments().getAttachedBlob("DRIVER");
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ ablob = ap.getOccupied();

			if (ablob !is null && ap.socket && ap.name != "DRIVER" && !blob.hasTag("immobile"))
			{
				IMechPart@ part  = @getMechPart(ablob);
				if(part !is null)
				{
					part.onRender(blob, driver);
				}
			}  
		}   
	}
}

void onTick(CBlob@ this)
{
	f32 heat = this.get_f32("heat");
	heat -= this.get_f32("heatvent");
	if(heat < 0)
		heat = 0;
	if(heat > this.get_f32("heatlimit"))
	{
		this.server_Hit(this, this.getPosition(), Vec2f(0, 0), heat - this.get_f32("heatlimit"), 0);
		heat = this.get_f32("heatlimit");
	}
	this.set_f32("heat", heat);
	if(getGameTime() + this.getNetworkID() % 5 == 0)
		this.Sync("heat", true);
	
	//LUL
	if(XORRandom(100) > 30)
	{
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			CBlob@ driver = this.getAttachments().getAttachedBlob("DRIVER");
			// GET OUT
			if (driver !is null && driver.isMyPlayer() && driver.isKeyJustPressed(key_pickup))
			{
				CBitStream params;
				params.write_u16(driver.getNetworkID());
				this.SendCommand(this.getCommandID("vehicle getout"), params);
				return;
			} // get out
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				CBlob@ blob = ap.getOccupied();

				if (blob !is null && ap.socket && ap.name != "DRIVER" && !this.hasTag("immobile"))
				{
					IMechPart@ part  = @getMechPart(blob);
					if(part !is null)
					{
						part.onTick(this, driver);
					}
				}  
			}   
		}
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	AttachmentPoint@[] aps;
	if (blob.getAttachmentPoints(@aps))
	{
		CBlob@ driver = blob.getAttachments().getAttachedBlob("DRIVER");
		// GET OUT
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ ablob = ap.getOccupied();

			if (ablob !is null && ap.socket && ap.name != "DRIVER" && !blob.hasTag("immobile"))
			{
				IMechPart@ part  = @getMechPart(ablob);
				if(part !is null)
				{
					part.onTick(this, driver);
				}
			}  
		}   
	}

	float healthratio = blob.getHealth() / blob.getInitialHealth();
	
	float heatratio = blob.get_f32("heat") / blob.get_f32("heatlimit");
	
	if(healthratio < 0.25)//critical health
	{
		if(getGameTime() % 3 == 0)
			makeSteamParticle(blob, Vec2f(), "Smoke.png");
	}
	if(heatratio > 0.75)//critical heat
	{
		if(getGameTime() % 1 == 0)
			makeSteamParticle(blob, Vec2f());
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(blob.getTeamNum() != this.getTeamNum())
		return true;
	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getAttachments().getAttachedBlob("DRIVER") !is null) return;

	if (this.getTeamNum() == caller.getTeamNum() && true && !caller.isAttached())
	{
		AttachmentPoint@[] aps;
		if (this.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				CBlob@ blob = ap.getOccupied();
				CBlob@ heldblob = caller.getCarriedBlob();
				if(ap.name != "DRIVER")
				{
					CBitStream params;
					params.write_u8(ap.getID());
					params.write_u16(caller.getNetworkID());
					if(blob is null)
					{
						if(heldblob !is null)
						{
							IMechPart@ part = @getMechPart(heldblob);
							if(part is null || part.canBeEquipped(ap.name))
							{
								caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Attach Part", params);
							}
						}
					}
					else
					{
						if(heldblob is null)
							caller.CreateGenericButton(2, ap.offset, this, this.getCommandID("attachpart"), "Detach Part", params);
					}
				}
			}
		}
	}
}

void onCommand( CBlob@ this, u8 cmd, CBitStream @params )
{
	bool isServer = getNet().isServer();
	if(cmd == this.getCommandID("attachpart"))
	{
		u8 apid = params.read_u8();
		AttachmentPoint@ ap = this.getAttachmentPoint(apid);
		if(ap.getOccupied() !is null)
		{
			this.server_DetachFrom(ap.getOccupied());
		}
		CBlob@ caller = getBlobByNetworkID(params.read_u16());
		if(caller !is null)
		{
			CBlob@ carried = caller.getCarriedBlob();
			if(carried !is null)
			{
				caller.DropCarried();
				this.server_AttachTo(carried, apid);
			}
		}
	}
	else if (isServer && cmd == this.getCommandID("vehicle getout"))
	{
		CBlob@ caller = getBlobByNetworkID(params.read_u16());

		if (caller !is null)
		{
			this.server_DetachFrom(caller);
		}
	}
	else if (cmd == this.getCommandID("partcommand"))
	{
		u8 attid = params.read_u8();
		CBlob@ blob = this.getAttachments().getAttachmentPointByID(attid).getOccupied();
		if(blob !is null)
		{
			IMechPart@ part = @getMechPart(blob);
			u32 bits = params.read_u32();
			CBlob@ driver = this.getAttachments().getAttachedBlob("DRIVER");
			if(part !is null)
			{
				bits = part.onCommand(this, driver, bits, params);

			}
			clearLeftoverBits(bits, params);
		}
	}
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	IMechPart@ part = @getMechPart(attached);
	CMechCore@ core = cast<CMechCore>(part);
	if(part !is null && core !is null)
	{
		core.attachedPoint = attachedPoint.name;
		part.onAttach(this, attached);
	}
	attachedPoint.SetMouseTaken(false);
	attachedPoint.SetKeysToTake(0);
	if(attachedPoint.name == "LOCO")
	{
		attachedPoint.offsetZ = -10;
	}
	else if(attachedPoint.name == "FRONT_ARM")
	{
		attachedPoint.offsetZ = 10;
	}
	else if(attachedPoint.name == "BACK_ARM")
	{
		attachedPoint.offsetZ = -20;
	}
	else if(attachedPoint.name == "DRIVER")
	{
		attachedPoint.offsetZ = -10;
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IMechPart@ part = @getMechPart(detached);
	CMechCore@ core = cast<CMechCore>(part);
	if(part !is null && core !is null)
	{
		core.attachedPoint = "";
		part.onDetach(this, detached);
	}
	if(attachedPoint.name == "DRIVER")
		attachedPoint.SetKeysToTake(key_left | key_right | key_up | key_down);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn)
	{
		//If its fire damage add heat instead
		this.add_f32("heat", damage * 6.0);
		damage = 0;
	}
	else if(customData == Hitters::flying)
	{
		//Ram damage, mech should take more of it to make ramming speed viable
		damage *= 3;
		//might be too much
	}
	else if(customData == Hitters::explosion || customData == Hitters::bomb || customData == Hitters::bomb_arrow || customData == Hitters::keg || customData == Hitters::mine)
	{
		//Explosion vulnerability
		damage *= 7;
		//Might be too much :V
	}
	return damage;
}

// Blame Fuzzle.
bool isOverlapping(CBlob@ this, CBlob@ blob)
{

	Vec2f tl, br, _tl, _br;
	this.getShape().getBoundingRect(tl, br);
	blob.getShape().getBoundingRect(_tl, _br);
	return br.x > _tl.x
	       && br.y > _tl.y
	       && _br.x > tl.x
	       && _br.y > tl.y;

}