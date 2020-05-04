//Random tile ticking
//Think ill either have this file handle all interactions or have other scripts 'attach' functions to blocks

#include "TileInteractions.as";
#include "RenderParticleCommon.as";

float tickmult = 0.0025;

void onInit(CRules@ this)
{
	CMap@ map = getMap();
	printInt("Random tile ticks per tick: ", Maths::Ceil(map.tilemapwidth * map.tilemapheight * tickmult));
	this.set_f32("tickmult", 1);
	this.set_u16("raincount", 24);
}

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	if(getNet().isClient())
	{
		CCamera@ camera = getCamera();
		float zoom = camera.targetDistance;
		Vec2f cpos = camera.getPosition();
		for (int i = 0; i < this.get_u16("raincount"); i++)
		{
			float scale = (XORRandom(5) + 2) / 6.0;
			CRenderParticleDrop newpart(scale, true, true, 60 / scale, 0, SColor(100, 100, 100, 255), true, 0);
			newpart.velocity = Vec2f(-2.5, 30.0) * scale;
			newpart.position = Vec2f(XORRandom(getScreenWidth()) + cpos.x - (getScreenWidth() / 2.0), XORRandom(40));
			
			float rotdeg = (newpart.velocity.getAngle() - 90) * -1;
			
			newpart.ul = Vec2f(0, scale * -1.0).RotateBy(rotdeg);
			newpart.ur = Vec2f(2 * scale, scale * 0.125).RotateBy(rotdeg);
			newpart.lr = Vec2f(0, scale * 20.0).RotateBy(rotdeg);
			newpart.ll = Vec2f(-2 * scale, scale * 0.125).RotateBy(rotdeg);
			
			addParticleToList(newpart);
		}
	}
	
	
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
