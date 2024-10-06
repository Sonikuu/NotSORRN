#include "NodeCommon.as";
#include "RenderParticleCommon.as";

void onInit(CBlob@ this)
{	
	CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(12, 0));
	tank.dynamictank = true;
	tank.singleelement = true;
	tank.maxelements = 50;

	CLogicPlug@ disable = @addLogicPlug(this, "Disable", true, Vec2f(0, 0));
	
	this.addCommandID("activate");
	
	this.addCommandID("toggle");
	
	this.addCommandID("flip");
	
	this.set_bool("active", true);
	
	AddIconToken("$toggle_pad$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	AddIconToken("$flip_pad$", "InteractionIcons.png", Vec2f(32, 32), 8);
	
	this.set_TileType("background tile", 0);

	this.set_f32("leftovers", 0);
	
	if(this.getSprite() !is null)
		this.getSprite().SetFrame(this.get_bool("active") ? 0 : 1);
		
}

void onTick(CBlob@ this)
{
	this.set_bool("active", !getDisabled(this));
	if(this.get_u16("cooldown") != 0)
		this.add_u16("cooldown", -1);
	else
	{
		CBlob@[] blobs;
		if(this.getOverlapping(@blobs) && this.get_bool("active") && getNet().isServer())
		{
			CAlchemyTank@ tank = getTank(this, 0);
			if(tank is null)
				return;
			for (int i = 0; i < elementlist.length; i++)
			{
				if(tank.storage.elements[i] >= 50)
				{
					CBitStream params;
					params.write_u8(i);
					this.set_u16("cooldown", 30);
					this.SendCommand(this.getCommandID("activate"), params);
					break;
				}
			}
		}
	}
	if(this.isFacingLeft())
		getTank(this, 0).offset = Vec2f(-12, 0);
	else
		getTank(this, 0).offset = Vec2f(12, 0);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	//caller.CreateGenericButton("$toggle_pad$", Vec2f(0, -12), this, this.getCommandID("toggle"), this.get_bool("active") ? "Deactivate Pad" : "Reactivate Pad");
	
	caller.CreateGenericButton("$flip_pad$", Vec2f(0, 0), this, this.getCommandID("flip"), "Flip Pad");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("toggle") == cmd)
	{
		this.set_bool("active", this.get_bool("active") ? false : true);
		if(this.getSprite() !is null)
			this.getSprite().SetFrame(this.get_bool("active") ? 0 : 1);
	}
	else if(this.getCommandID("activate") == cmd)
	{
		u8 elementid = params.read_u8();
		CAlchemyTank@ tank = getTank(this, 0);
		if(tank is null)
			return;
		
		CBlob@[] blobs;
		this.getOverlapping(@blobs);
		float minmult = 0;
		for (int i = 0; i < blobs.length; i++)
		{
			minmult = Maths::Max(elementlist[elementid].padbehavior(blobs[i], 5, this), minmult);
		}
		minmult *= 50;
		minmult += this.get_f32("leftovers");
		int intdown = minmult;
		tank.storage.elements[elementid] -= intdown;
		this.set_f32("leftovers", minmult - intdown);

	}
	else if(this.getCommandID("flip") == cmd)
	{
		if(this.isFacingLeft())
			this.SetFacingLeft(false);
		else
			this.SetFacingLeft(true);
		//getTank(this, 0).offset *= -1;
			
			
	}
	
}