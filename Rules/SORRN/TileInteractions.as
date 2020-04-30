//This will store functions that say what a tile does when ticked, or how to convert a tile

#include "CHitters.as";

void corruptTile(Vec2f tilepos, CMap@ map)
{
	if(isServer())
	{
		Tile tile = map.getTileFromTileSpace(tilepos);
		//Doesnt corrupt itself or purified dust
		if(map.isTileSolid(tile) && (tile.type < 400 || tile.type > 408) && !(tile.type >= 106 && tile.type <= 111))
		{
			map.server_SetTile(tilepos * map.tilesize, 400 + XORRandom(3));
			Tile gtile = map.getTileFromTileSpace(tilepos - Vec2f(0, 1));
			if(map.isTileGrass(gtile.type))
				map.server_SetTile((tilepos - Vec2f(0, 1)) * map.tilesize, 0);
			//corruptTick(tilepos, map);
			//corruptTick(tilepos, map);
		}
	}
}

void corruptTick(Vec2f tilepos, CMap@ map)
{
	if(isServer())
	{
		tilepos += Vec2f(XORRandom(3) - 1, XORRandom(3) - 1);
		corruptTile(tilepos, map);
		
		//Damage effect
		if(XORRandom(2) == 0)
		{
			CBlob@[] blobs;
			if(map.getBlobsInRadius(tilepos * map.tilesize, 32, @blobs))
			{
				for (int i = 0; i < blobs.length; i++)
				{
					if(blobs[i].hasTag("tree") && !blobs[i].hasTag("corrupt"))
					{
						CBlob@ newblob = server_CreateBlobNoInit("tree_corrupt");
						newblob.Tag("startbig");
						newblob.setPosition(blobs[i].getPosition());
						newblob.server_setTeamNum(blobs[i].getTeamNum());
						newblob.Init();
						blobs[i].Tag("nodrops");
						blobs[i].server_Die();
						
					}
					else if(blobs[i].hasTag("nature"))
					{
						CBlob@ newblob = server_CreateBlobNoInit("corruptbush");
						newblob.setPosition(blobs[i].getPosition());
						newblob.server_setTeamNum(blobs[i].getTeamNum());
						newblob.Init();
						blobs[i].Tag("nodrops");//leaving this in case we want bushes to drop seeds or other garbage
						blobs[i].server_Die();
					}
					//else if(!blobs[i].hasTag("corrupt")) We'll rely on spawned monsters to hurt playerss
						//blobs[i].server_Hit(blobs[i], blobs[i].getPosition(), Vec2f_zero, 0.2, CHitters::corrupt);
				}
			}
		}
		
		//Spawning effect
		if(XORRandom(150) == 0)
		{
			if(!map.isTileSolid(map.getTileFromTileSpace(tilepos + Vec2f(0, -1))))
			{
				CBlob@[] blobs;
				map.getBlobsInRadius(tilepos * map.tilesize, 320, @blobs);
				int knokcount = 0;
				bool dospawn = true;
				for(int i = 0; i < blobs.length(); i++)
				{
					if(blobs[i].getConfig() == "knokling")
					{
						knokcount++;
						if(knokcount >= 3)
						{
							dospawn = false;
							break;
						}
					}
				}
				if(dospawn)
					server_CreateBlob("knokling", -1, (tilepos + Vec2f(0, -1)) * map.tilesize);
			}
		}
	}
}

void purifyTile(Vec2f tilepos, CMap@ map)
{
	if(isServer())
	{
		Tile tile = map.getTileFromTileSpace(tilepos);
		if(map.isTileSolid(tile) && (tile.type >= 400 && tile.type <= 405))
		{
			map.server_SetTile(tilepos * map.tilesize, 406 + XORRandom(3));
		}
	}
}

