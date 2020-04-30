//Gravity Status effect
#include "FxLightFall.as";
#include "WorldRenderCommon.as";

void onTick(CBlob@ this)
{
	if(this.get_u16("fxlightfalltime") == 0)
		removeFxLightFall(this);
	else
		this.add_u16("fxlightfalltime", -1);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob.get_u16("fxlightfalltime") != 0)
	//	removeFxCorrupt(blob);
	//else
		lightFallFxRender(blob);
}



void lightFallFxRender(CBlob@ this)
{
	array<Vertex> vertlist(0);
	
	CShape@ shape = this.getShape();	
	float sizemult = 8 * this.get_u16("fxlightfallpower");//effect intensity p much
	const float drrendrange = 1.5 * (shape !is null ? shape.getConsts().radius : 8);//radius
	const float drsections = 3;//how many lines there are in the circle
	const int segments = 45;//how many verts there are
	
	//u32 color = (0xFF << 24) + (elecolor.getRed() << 16) + (elecolor.getGreen() << 8) + elecolor.getBlue();
	
	CMap@ map = getMap();
	
	Random rando(this.getNetworkID());
	
	float lastdegrees = -360 / segments;
	float lastradians = (lastdegrees / 180) * Maths::Pi;
	float lastwidth = (Maths::Abs((lastdegrees + (float(getGameTime() + this.getNetworkID()) + getInterpolationFactor()) * 4) % (360 / drsections) - (180 / drsections)) - 90 / drsections) / (90 / drsections) * (drrendrange / 64.0) * sizemult;

	Vec2f lastupperpos = Vec2f(Maths::Cos(lastradians), Maths::Sin(lastradians)) * (drrendrange + lastwidth) + this.getInterpolatedPosition();
	Vec2f lastlowerpos = Vec2f(Maths::Cos(lastradians), Maths::Sin(lastradians)) * (drrendrange) + this.getInterpolatedPosition();
	
	for (uint i = 0; i < segments; i++)
	{
		SColor elecolor(255, 200 + rando.NextRanged(20), 200 + rando.NextRanged(20), 90 + rando.NextRanged(20));
		
		float degrees = i * 360 / segments;
		float radians = (degrees / 180) * Maths::Pi;
		float width = (Maths::Abs((degrees + (float(getGameTime() + this.getNetworkID()) + getInterpolationFactor()) * 4) % (360 / drsections) - (180 / drsections)) - 90 / drsections) / (90 / drsections) * (drrendrange / 64.0) * sizemult;
		
		Vec2f upperpos = Vec2f(Maths::Cos(radians), Maths::Sin(radians)) * (drrendrange + width) + this.getInterpolatedPosition();
		Vec2f lowerpos = Vec2f(Maths::Cos(radians), Maths::Sin(radians)) * (drrendrange) + this.getInterpolatedPosition();
		
		
		
		if(width > 0 && lastwidth > 0)
		{
			vertlist.push_back(Vertex(lastupperpos.x, lastupperpos.y, 30, 0, 0, elecolor));
			vertlist.push_back(Vertex(upperpos.x, upperpos.y, 30, 1, 0, elecolor));
			vertlist.push_back(Vertex(lowerpos.x, lowerpos.y, 30, 1, 1, elecolor));
			vertlist.push_back(Vertex(lastlowerpos.x, lastlowerpos.y, 30, 0, 1, elecolor));
		}
		
		lastupperpos = upperpos;
		lastlowerpos = lowerpos;
		lastwidth = width;
	}
	addVertsToExistingRender(@vertlist, "../Entities/PixelWhite.png");
}