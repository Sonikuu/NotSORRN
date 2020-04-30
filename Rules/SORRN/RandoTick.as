//Random tile ticking
//Think ill either have this file handle all interactions or have other scripts 'attach' functions to blocks

#include "TileInteractions.as";

float tickmult = 0.0025;

void onInit(CRules@ this)
{
	CMap@ map = getMap();
	printInt("Random tile ticks per tick: ", Maths::Ceil(map.tilemapwidth * map.tilemapheight * tickmult));
	this.set_f32("tickmult", 1);
}

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	int loopcount = Maths::Ceil(map.tilemapwidth * map.tilemapheight * tickmult * this.get_f32("tickmult"));
	for(int i = 0; i < loopcount; i++)
	{
		Random rando(XORRandom(0x7FFFFFFF));
		Vec2f nexttile(rando.NextRanged(map.tilemapwidth), rando.NextRanged(map.tilemapheight));
		Tile tile = map.getTileFromTileSpace(nexttile);
		if(tile.type >= 400 && tile.type <= 405)
		{
			corruptTick(nexttile, map);
		}
	}
}

void onRender(CRules@ this)
{
	
}
