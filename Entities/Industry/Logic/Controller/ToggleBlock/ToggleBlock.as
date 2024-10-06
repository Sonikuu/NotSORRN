
#include "LogicControllerCommon.as";

void onInit(CBlob@ this)
{	
	this.Tag("logiccont");
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if(this.get_bool("active") != this.get_bool("activecache"))
	{
		this.set_bool("activecache", this.get_bool("active"));
		this.getShape().checkCollisionsAgain = true;
	}
}

void onTick(CSprite@ this)
{

	bool a = this.getBlob().get_bool("active");
	if(a && this.getFrame() == 0)
		this.SetFrame(1);
	else if(!a && this.getFrame() == 1)
		this.SetFrame(0);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !this.get_bool("active");
}







