#include "AlchemyCommon.as";

const float wardrange = 64;
//64 = 8 tiles

void onInit(CBlob@ this)
{	
	CAlchemyTank@ tank = addTank(this, "Input", true, Vec2f(0, 4));
	tank.maxelements = 10;
	tank.singleelement = true;
	//getTank(this, 0).dynamictank = true;
	
	//this.addCommandID("activate");
	
	this.addCommandID("toggle");
	
	//this.addCommandID("flip");
	
	this.set_bool("active", true);
	
	AddIconToken("$toggle_pad$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	//AddIconToken("$flip_pad$", "InteractionIcons.png", Vec2f(32, 32), 8);
	
	this.set_TileType("background tile", 0);
	
	this.set_u8("lasteleid", 255);

	this.set_f32("leftovers", 0);
}

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ layer = this.addSpriteLayer("runes");
	layer.SetFrame(1);
	//layer.setRenderStyle(RenderStyle::light);
	layer.SetLighting(false);
	
	Render::addBlobScript(Render::layer_objects, blob, "AlchemicalWard.as", "renderArea");
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ layer = this.getSpriteLayer("runes");
	CBlob@ blob = this.getBlob();
	if(blob.get_u8("lasteleid") == 255)
	{
		layer.SetColor(SColor(0, 0, 0, 0));
	}
	else
	{
		layer.SetColor(elementlist[blob.get_u8("lasteleid")].color);
	}
	
}

void renderArea(CBlob@ this, int id)
{
	if(this.get_u8("lasteleid") == 255)
		return;
	array<Vertex> vertlist(0);
	
		
	float sizemult = 0.5;
	
	SColor elecolor = elementlist[this.get_u8("lasteleid")].color;
	u32 color = (0xFF << 24) + (elecolor.getRed() << 16) + (elecolor.getGreen() << 8) + elecolor.getBlue();
	
	CMap@ map = getMap();
	
	
	float lastdegrees = -4;
	float lastradians = (lastdegrees / 180) * Maths::Pi;
	float lastwidth = Maths::Sin((lastradians + (float(getGameTime() + this.getNetworkID()) + getInterpolationFactor()) / 6) * 3) * (wardrange / 64.0);

	Vec2f lastupperpos = Vec2f(Maths::Cos(lastradians), Maths::Sin(lastradians)) * (wardrange + lastwidth) + this.getPosition();
	Vec2f lastlowerpos = Vec2f(Maths::Cos(lastradians), Maths::Sin(lastradians)) * (wardrange - lastwidth) + this.getPosition();
	
	for (uint i = 0; i < 90; i++)
	{
		
		float degrees = i * 4;
		float radians = (degrees / 180) * Maths::Pi;
		float width = Maths::Sin((radians + (float(getGameTime() + this.getNetworkID()) + getInterpolationFactor()) / 6) * 3) * (wardrange / 64.0);
		
		Vec2f upperpos = Vec2f(Maths::Cos(radians), Maths::Sin(radians)) * (wardrange + width) + this.getPosition();
		Vec2f lowerpos = Vec2f(Maths::Cos(radians), Maths::Sin(radians)) * (wardrange - width) + this.getPosition();
		
		
		
		if(width > 0)
		{
			vertlist.push_back(Vertex(lastupperpos.x, lastupperpos.y, 30, 0, 0, color));
			vertlist.push_back(Vertex(upperpos.x, upperpos.y, 30, 1, 0, color));
			vertlist.push_back(Vertex(lowerpos.x, lowerpos.y, 30, 1, 1, color));
			vertlist.push_back(Vertex(lastlowerpos.x, lastlowerpos.y, 30, 0, 1, color));
		}
		
		lastupperpos = upperpos;
		lastlowerpos = lowerpos;
	}
	Render::RawQuads("PixelWhite.png", vertlist);
}

void onTick(CBlob@ this)
{
	this.set_u8("lasteleid", 255);
	if(this.get_bool("active"))
	{
		CAlchemyTank@ tank = getTank(this, 0);
		if(tank is null)
			return;
		for (int i = 0; i < elementlist.length; i++)
		{
			if(tank.storage.elements[i] >= 1)
			{
				this.set_u8("lasteleid", i);
				float minout = this.get_f32("leftovers");
				minout += elementlist[i].wardbehavior(wardrange, 5, this) / 5.0;

				tank.storage.elements[i] -= int(minout);
				minout -= int(minout);
				this.set_f32("leftovers", minout);

				break;
			}
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_bool(!this.get_bool("active"));
	caller.CreateGenericButton("$toggle_pad$", Vec2f(0, -12), this, this.getCommandID("toggle"), this.get_bool("active") ? "Deactivate Ward" : "Reactivate Ward", params);
	
	//caller.CreateGenericButton("$flip_pad$", Vec2f(0, 0), this, this.getCommandID("flip"), "Flip Pad");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("toggle") == cmd)
	{
		this.set_bool("active", params.read_bool());
	}
	/*else if(this.getCommandID("activate") == cmd)
	{
		u8 elementid = params.read_u8();
		CAlchemyTank@ tank = getTank(this, 0);
		tank.storage.elements[elementid] -= 100;
		CBlob@[] blobs;
		this.getOverlapping(@blobs);
		for (int i = 0; i < blobs.length; i++)
		{
			elementlist[elementid].padbehavior(blobs[i], 5, this);
		}
	}
	else if(this.getCommandID("flip") == cmd)
	{
		if(this.isFacingLeft())
			this.SetFacingLeft(false);
		else
			this.SetFacingLeft(true);
		//getTank(this, 0).offset *= -1;
			
			
	}*/
	
}