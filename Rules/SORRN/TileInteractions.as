//This will store functions that say what a tile does when ticked, or how to convert a tile

#include "CHitters.as";
#include "LoaderColors.as";

void corruptTile(Vec2f tilepos, CMap@ map)
{
	if(isServer())
	{
		if(tilepos.x > map.tilemapwidth || tilepos.y > map.tilemapheight || tilepos.x < 0 || tilepos.y < 0)
			return;
		Tile tile = map.getTileFromTileSpace(tilepos);
		//Doesnt corrupt itself or purified dust
		if(map.isTileSolid(tile) && (tile.type < 400 || tile.type > 408) && !(tile.type >= 106 && tile.type <= 111) && map.getSectorAtPosition(tilepos * 8, "no build") is null)
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
				for(int i = 0; i < blobs.size(); i++)
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
		if(XORRandom(300) == 0)
		{
			if(!map.isTileSolid(map.getTileFromTileSpace(tilepos + Vec2f(0, -1))) && map.isTileSolid(map.getTileFromTileSpace(tilepos)))
			{
				CBlob@[] blobs;
				map.getBlobsInRadius(tilepos * map.tilesize, 480, @blobs);
				bool dospawn = true;
				for(int i = 0; i < blobs.size(); i++)
				{
					if(blobs[i].getConfig() == "zest")
					{
						dospawn = false;
						break;
					}
				}
				if(dospawn)
					server_CreateBlob("zest", -1, (tilepos - Vec2f(0, 1)) * map.tilesize);
			}
		}
		if(XORRandom(150) == 0)
		{
			if(!map.isTileSolid(map.getTileFromTileSpace(tilepos + Vec2f(0, -1))) && map.isTileSolid(map.getTileFromTileSpace(tilepos)))
			{
				CBlob@[] blobs;
				map.getBlobsInRadius(tilepos * map.tilesize, 128, @blobs);
				bool dospawn = true;
				for(int i = 0; i < blobs.size(); i++)
				{
					if(blobs[i].getConfig() == "spritz")
					{
						dospawn = false;
						break;
					}
				}
				if(dospawn)
					server_CreateBlob("spritz", -1, (tilepos - Vec2f(0, 1)) * map.tilesize);
			}
		}
		if(XORRandom(1000) == 0)
		{
			if(!map.isTileSolid(map.getTileFromTileSpace(tilepos + Vec2f(0, -1))) && map.isTileSolid(map.getTileFromTileSpace(tilepos)))
			{
				CBlob@[] blobs;
				map.getBlobsInRadius(tilepos * map.tilesize, 1024, @blobs);
				bool dospawn = true;
				for(int i = 0; i < blobs.size(); i++)
				{
					if(blobs[i].getConfig() == "drizz" || blobs[i].getConfig() == "drizzegg")
					{
						dospawn = false;
						break;
					}
				}
				if(dospawn)
					server_CreateBlob("drizzegg", -1, (tilepos - Vec2f(0, 1)) * map.tilesize);
			}
		}
	}
}

bool purifyTile(Vec2f tilepos, CMap@ map)
{
	//if(isServer())
	{
		Tile tile = map.getTileFromTileSpace(tilepos);
		if(map.isTileSolid(tile) && (tile.type >= 400 && tile.type <= 405))
		{
			map.server_SetTile(tilepos * map.tilesize, 406 + XORRandom(3));
			return true;
		}
	}
	return false;
}


void mapRegenEffect(Vec2f mappos, float power, bool always = false)
{
	CMap@ map = getMap();
	string currmap = map.getMapName();
	Vec2f worldpos = mappos * map.tilesize;
	
	//if(!Texture::exists(currmap + "zzz"))
		//Texture::createFromFile(currmap + "zzz", currmap);
	CFileImage@ mapdata = @CFileImage(currmap);
	
	//Random rando(XORRandom(0x7FFFFFFF));
	
	if(mapdata !is null)
	{
		Tile tile = map.getTileFromTileSpace(mappos);
		if((tile.type == 0 || tile.type == CMap::tile_ground_back || (tile.type >= 406 && tile.type <= 408)) && map.getSectorAtPosition(worldpos, "no build") is null)
		{
			mappos.x = int(mappos.x);
			mappos.y = int(mappos.y);
			mapdata.setPixelPosition(mappos);
			SColor tilecol = mapdata.readPixel();
			//printVec2f("Pos: ", mapdata.getPixelPosition());
			//print("Col: R:" + tilecol.getRed() + " G:" + tilecol.getGreen() + " B:" + tilecol.getBlue());
			if(tilecol == map_colors::tile_ground)
				map.server_SetTile(worldpos, CMap::tile_ground);
			else if(tilecol == map_colors::tile_stone && (getGameTime() % (10 / power) == 0 || always))
				map.server_SetTile(worldpos, CMap::tile_stone);
			else if(tilecol == map_colors::tile_thickstone && (getGameTime() % (15 / power)  == 0 || always))
				map.server_SetTile(worldpos, CMap::tile_thickstone);
			else if(tilecol == map_colors::tile_gold && (getGameTime() % (30 / power) == 0 || always))
				map.server_SetTile(worldpos, CMap::tile_gold);
		}
	}
}
