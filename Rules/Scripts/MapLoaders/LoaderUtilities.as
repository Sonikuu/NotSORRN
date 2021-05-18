// LoaderUtilities.as

#include "DummyCommon.as";
#include "CustomBlocks.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	array<int>@ heightdata;
	map.get("heightdata", @heightdata);
	if(heightdata[offset % map.tilemapwidth] <= offset / map.tilemapwidth)
	{
		bool loopsie = true;
		while (loopsie)
		{
			offset += map.tilemapwidth;
			if(map.hasTileFlag(offset, Tile::SOLID) || offset > map.tilemapwidth * map.tilemapheight)
			{
				heightdata[offset % map.tilemapwidth] = offset / map.tilemapwidth;
				loopsie = false;
			}
		}
	}
	if(isDummyTile(map.getTile(offset).type))
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if(blob !is null)
		{
			blob.server_Die();
		}
	}
	return true;
}

CParticle@ makeTileParticles(string pname, Vec2f pos)
{
	CParticle@ p = makeGibParticle(pname, pos, Vec2f(0.5f * (-10.0 / 2.0 + XORRandom(10)), 0.60f * (-10.0 / 2.0 + XORRandom(10))), 0, XORRandom(7), Vec2f(1, 1), 0.45, 255, "");
	if(p !is null)
	{
		p.bounce = 0.52;
		p.damping = 0.994;
		p.waterdamping = 0.9;
		p.mass = 4.5;
		p.deadeffect = 255;
		p.width = 1;
		p.height = 1;
		p.rotates = false;
		p.Z = XORRandom(50);
	}
	return p;
}

TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	string hitsfx = "dig_stone" + (XORRandom(3) + 1);
	TileType output = oldTileType;
	int particlec = 0;
	string particlename = "";
	//CORRUPT HANDLER
	while(damage > 0)
	{
		int damnum = 255 * damage + 1;
		bool partial = damage < 1.0;
		if(partial)
		{
			if(this.getTile(index).damage + damnum <= 255)
			{
				Tile t = this.getTile(index);
				t.damage += damnum;
				break;
			}
		}

		if(output >= CCTiles::tile_cor1 && output < CCTiles::tile_cor1 + cor_variation)
		{
			output = CCTiles::tile_cord1;//FIRST HIT ON A TILE
			hitsfx = "dig_dirt" + (XORRandom(3) + 1);
			particlec += 3;
			particlename = "Corrupthit.png";
		}
		else if(output >= CCTiles::tile_cord1 && output < CCTiles::tile_cord1 + cor_damaged)
		{
			if(output == CCTiles::tile_cord3)//WHEN TILE FINALLY BREAKS
			{
				output = 0;
				hitsfx = "destroy_dirt";
				damage = 0;
				particlec += 16;
				particlename = "Corrupthit.png";
				
			}
			else//DAMAGING TILE
			{
				output += 1;
				hitsfx = "dig_dirt" + (XORRandom(3) + 1);
				particlec += 3;
				particlename = "Corrupthit.png";
			}
		}
		//PURE
		else if(output >= CCTiles::tile_pur1 && output < CCTiles::tile_pur1 + pur_variation)
		{
			output = 0;
			hitsfx = "destroy_dirt";
			damage = 0;
			particlec += 16;
			particlename = "Purehit.png";
		}
		//MARBLE
		else if(output >= CCTiles::tile_mar && output < CCTiles::tile_mard1)
		{
			output = CCTiles::tile_mard1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
			particlec += 3;
			particlename = "Marblehit.png";
		}
		else if(output >= CCTiles::tile_mard1 && output < CCTiles::tile_mard1 + mar_damaged)
		{
			if(output == CCTiles::tile_mard7)//WHEN TILE FINALLY BREAKS
			{
				output = 0;
				hitsfx = "destroy_wall";
				damage = 0;
				particlec += 16;
				particlename = "Marblehit.png";
			}
			else//DAMAGING TILE
			{
				output += 1;
				hitsfx = "PickStone" + (XORRandom(3) + 1);
				particlec += 3;
				particlename = "Marblehit.png";
			}
		}
		//MARBLE BACK
		else if(output >= CCTiles::tile_mar_back && output < CCTiles::tile_mar_backd1)
		{
			output = CCTiles::tile_mar_backd1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
			particlec += 3;
			particlename = "Marblehit.png";
		}
		else if(output >= CCTiles::tile_mar_backd1 && output <= CCTiles::tile_mar_backd5)
		{
			if(output == CCTiles::tile_mar_backd5)//WHEN TILE FINALLY BREAKS
			{
				output = 0;
				hitsfx = "destroy_wall";
				damage = 0;
				particlec += 16;
				particlename = "Marblehit.png";
			}
			else//DAMAGING TILE
			{
				output += 1;
				hitsfx = "PickStone" + (XORRandom(3) + 1);
				particlec += 3;
				particlename = "Marblehit.png";
			}
		}
		//BASALT
		else if(output >= CCTiles::tile_bas && output < CCTiles::tile_basd1)
		{
			output = CCTiles::tile_basd1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
			particlec += 3;
			particlename = "Basalthit.png";
		}
		else if(output >= CCTiles::tile_basd1 && output < CCTiles::tile_basd1 + bas_damaged)
		{
			if(output == CCTiles::tile_basd7)//WHEN TILE FINALLY BREAKS
			{
				output = 0;
				hitsfx = "destroy_wall";
				damage = 0;
				particlec += 16;
				particlename = "Basalthit.png";
			}
			else//DAMAGING TILE
			{
				output += 1;
				hitsfx = "PickStone" + (XORRandom(3) + 1);
				particlec += 3;
				particlename = "Basalthit.png";
			}
		}
		//BASALT BACKGROUND
		else if(output >= CCTiles::tile_bas_back && output < CCTiles::tile_bas_backd1)
		{
			output = CCTiles::tile_bas_backd1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
			particlec += 3;
			particlename = "Basalthit.png";
		}
		else if(output >= CCTiles::tile_bas_backd1 && output < CCTiles::tile_bas_backd1 + bas_back_damaged)
		{
			if(output == CCTiles::tile_bas_backd5)//WHEN TILE FINALLY BREAKS
			{
				output = 0;
				hitsfx = "destroy_wall";
				damage = 0;
				particlec += 16;
				particlename = "Basalthit.png";
			}
			else//DAMAGING TILE
			{
				output += 1;
				hitsfx = "PickStone" + (XORRandom(3) + 1);
				particlec += 3;
				particlename = "Basalthit.png";
			}
		}
		//TRACK
		else if(output >= CCTiles::tile_track && output < CCTiles::tile_track + track_variation)
		{
			output = 0;
			hitsfx = "metal_stone";
			damage = 0;
			particlec += 16;
			particlename = "Metalhit.png";
		}
		//GOLD
		else if(output >= CCTiles::tile_gold && output < CCTiles::tile_goldd1)
		{
			output = CCTiles::tile_goldd1;
			hitsfx = "dig_stone" + (XORRandom(3) + 1);
			particlec += 3;
			particlename = "Goldhit.png";
		}
		else if(output >= CCTiles::tile_goldd1 && output < CCTiles::tile_goldd1 + gold_damaged)
		{
			if(output == CCTiles::tile_goldd7)//WHEN TILE FINALLY BREAKS
			{
				output = 0;
				hitsfx = "destroy_gold";
				damage = 0;
				particlec += 16;
				particlename = "Goldhit.png";
			}
			else//DAMAGING TILE
			{
				output += 1;
				hitsfx = "dig_stone" + (XORRandom(3) + 1);
				particlec += 3;
				particlename = "Goldhit.png";
			}
		}
		damage -= 1;
	}
	hitsfx += ".ogg";
	if(oldTileType > 256)
		Sound::Play(hitsfx, Vec2f(index % this.tilemapwidth, index / this.tilemapwidth) * 8, 1.0);
	for(int i = 0; i < particlec; i++)
	{
		makeTileParticles("Sprites/Tilehits/" + particlename, Vec2f(index % this.tilemapwidth, index / this.tilemapwidth) * 8);
	}
	return output;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	array<int>@ heightdata;
	map.get("heightdata", @heightdata);
	if(heightdata is null)
	{
		@heightdata = @array<int>(map.tilemapwidth, 999);
		map.set("heightdata", @heightdata);
	}
	
	if(isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}
	else
	{
		string buildsfx = "";
		if(tile_new >= CCTiles::tile_cor1 && tile_new < CCTiles::tile_cor1 + cor_variation + cor_damaged)
		{
			map.SetTileSupport(index, 1);
			map.RemoveTileFlag(index, 0xFFFF);
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			//map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
			//map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
		}
		else if(tile_new >= CCTiles::tile_pur1 && tile_new < CCTiles::tile_pur1 + pur_variation)
		{
			
			map.SetTileSupport(index, 1);
			map.RemoveTileFlag(index, 0xFFFF);
			map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
			//map.RemoveTileFlag(index, Tile::SOLID | Tile::COLLISION);
			//map.AddTileFlag(index, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE);
		}
		else if(tile_new >= CCTiles::tile_mar && tile_new <= CCTiles::tile_goldd7)
		{
			if(tile_new == CCTiles::tile_mar || tile_new == CCTiles::tile_bas || tile_new == CCTiles::tile_bas_back || tile_new == CCTiles::tile_mar_back)
				buildsfx = "build_wall2";
			else if (tile_new == CCTiles::tile_gold)
				buildsfx = "dig_stone" + (XORRandom(3) + 1);
			HandleCustomTile(map, index, tile_new);
			map.SetTileSupport(index, 8);
		}
			//YEET
		buildsfx += ".ogg";
		if(buildsfx != ".ogg")
			Sound::Play(buildsfx, Vec2f(index % map.tilemapwidth, index / map.tilemapwidth) * 8, 1.0);

		updateAllNeighbors(index, map);
	}
	
	if(heightdata[index % map.tilemapwidth] > index / map.tilemapwidth && map.hasTileFlag(index, Tile::SOLID))
		heightdata[index % map.tilemapwidth] = index / map.tilemapwidth;
	else if(heightdata[index % map.tilemapwidth] == index / map.tilemapwidth && !map.hasTileFlag(index, Tile::SOLID))
	{
		bool loopsie = true;
		while (loopsie)
		{
			index += map.tilemapwidth;
			if(map.hasTileFlag(index, Tile::SOLID) || index > map.tilemapwidth * map.tilemapheight)
			{
				heightdata[index % map.tilemapwidth] = index / map.tilemapwidth;
				loopsie = false;
			}
		}
	}
}













