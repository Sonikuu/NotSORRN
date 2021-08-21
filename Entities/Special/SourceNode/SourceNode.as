#include "WorldRenderCommon.as";
#include "NodeCommon.as";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	array<Vec2f>@ points;
	blob.get("pointlist", @points);
	
	array<Vertex> vertlist;
	
	SColor c = elementlist[blob.get_u8("element")].color;
	
	vertlist.push_back(Vertex(points[0].x, points[0].y, 0, 0, 0, c));
	vertlist.push_back(Vertex(points[1].x, points[1].y, 0, 1, 0, c));
	vertlist.push_back(Vertex(points[2].x, points[2].y, 0, 1, 1, c));
	vertlist.push_back(Vertex(points[3].x, points[3].y, 0, 0, 1, c));

	addVertsToExistingRender(@vertlist, "Rules/Render/PixelWhite.png", "RLrender");
}

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	addTank(this, "Output", false, Vec2f(0, 0));
	int diaangle = XORRandom(90) + 45;
	int element = XORRandom(elementlist.size());
	if(!this.exists("element"))
		this.set_u8("element", element);
	array<Vec2f> points;
	points.push_back(Vec2f_lengthdir_deg(1, diaangle) + this.getPosition());
	points.push_back(Vec2f_lengthdir_deg(8, diaangle + 90) + this.getPosition());
	points.push_back(Vec2f_lengthdir_deg(1, diaangle + 180) + this.getPosition());
	points.push_back(Vec2f_lengthdir_deg(8, diaangle + 270) + this.getPosition());
	this.set("pointlist", @points);
}


void onTick(CBlob@ this)
{
	if(getGameTime() % 10 == 0)
	{
		//Using numbers to get tanks is probs faster than strings
		CAlchemyTank@ tank = getTank(this, 0);
		//if(tank.storage.getElement("aer") < tank.maxelements)
		addToTank(tank, this.get_u8("element"), 1);
	}
}

























