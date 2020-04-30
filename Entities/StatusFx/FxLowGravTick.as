//Gravity Status effect
#include "FxLowGrav.as";
#include "WorldRenderCommon.as";

void onTick(CBlob@ this)
{
	if(this.get_u16("fxgravtime") == 0)
		removeFxLowGrav(this);
	else
		this.add_u16("fxgravtime", -1);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob.get_u16("fxgravtime") != 0)
		//removeFxDamageReduce(blob);
	//else
		lowGravRender(blob);
}



void lowGravRender(CBlob@ this)
{
	array<Vertex> vertlist(0);
	
	CShape@ shape = this.getShape();	
	float sizemult = 0.7 * Maths::Min(this.get_u16("fxgravpower"), 5);//effect intensity p much
	const float drrendrange = 1.6 * (shape !is null ? shape.getConsts().radius : 8);//radius
	const float drsections = 10;//how many lines there are in the circle
	const int segments = 60;//how many verts there are
	const float offset = (180 / 180.0) * Maths::Pi;//offset of the lines
	
	//u32 color = (0xFF << 24) + (elecolor.getRed() << 16) + (elecolor.getGreen() << 8) + elecolor.getBlue();
	
	CMap@ map = getMap();
	
	Random rando(this.getNetworkID());
	
	float lastdegrees = -360 / segments;
	float lastradians = (lastdegrees / 180) * Maths::Pi;
	float lastwidth = (Maths::Pow(3.0f, Maths::Sin(offset + (lastradians + (float(getGameTime() + this.getNetworkID()) + getInterpolationFactor()) / drsections) * drsections * 0.5) * 3) - 3) * (drrendrange / 64.0) * sizemult;

	Vec2f lastupperpos = Vec2f(Maths::Cos(lastradians), Maths::Sin(lastradians)) * (drrendrange + lastwidth) + this.getInterpolatedPosition();
	Vec2f lastlowerpos = Vec2f(Maths::Cos(lastradians), Maths::Sin(lastradians)) * (drrendrange - lastwidth / 4) + this.getInterpolatedPosition();
	
	for (uint i = 0; i < segments; i++)
	{
		SColor elecolor(255, 190 + rando.NextRanged(20), 190 + rando.NextRanged(20), 190 + rando.NextRanged(20));
		
		float degrees = i * 360 / segments;
		float radians = (degrees / 180) * Maths::Pi;
		float width = (Maths::Pow(3.0f, Maths::Sin(offset + (radians + (float(getGameTime() + this.getNetworkID()) + getInterpolationFactor()) / drsections) * drsections * 0.5) * 3) - 3) * (drrendrange / 64.0) * sizemult;
		
		Vec2f upperpos = Vec2f(Maths::Cos(radians), Maths::Sin(radians)) * (drrendrange + width) + this.getInterpolatedPosition();
		Vec2f lowerpos = Vec2f(Maths::Cos(radians), Maths::Sin(radians)) * (drrendrange - width / 4) + this.getInterpolatedPosition();
		
		
		
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