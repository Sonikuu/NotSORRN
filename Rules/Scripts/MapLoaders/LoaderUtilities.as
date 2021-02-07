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

TileType server_onTileHit(CMap@ this, f32 damage, u32 index, TileType oldTileType)
{
	string hitsfx = "dig_stone" + (XORRandom(3) + 1);
	TileType output = oldTileType;
	//CORRUPT HANDLER
	if(oldTileType >= CCTiles::tile_cor1 && oldTileType < CCTiles::tile_cor1 + cor_variation)
	{
		output = CCTiles::tile_cord1;//FIRST HIT ON A TILE
		hitsfx = "dig_dirt" + (XORRandom(3) + 1);
	}
	else if(oldTileType >= CCTiles::tile_cord1 && oldTileType < CCTiles::tile_cord1 + cor_damaged)
	{
		if(oldTileType == CCTiles::tile_cord3)//WHEN TILE FINALLY BREAKS
		{
			output = 0;
			hitsfx = "destroy_dirt";
		}
		else//DAMAGING TILE
		{
			output += 1;
			hitsfx = "dig_dirt" + (XORRandom(3) + 1);
		}
	}
	//PURE
	else if(oldTileType >= CCTiles::tile_pur1 && oldTileType < CCTiles::tile_pur1 + pur_variation)
	{
		output = 0;
		hitsfx = "destroy_dirt";
	}
	//MARBLE
	else if(oldTileType >= CCTiles::tile_mar && oldTileType < CCTiles::tile_mard1)
	{
		output = CCTiles::tile_mard1;
		hitsfx = "PickStone" + (XORRandom(3) + 1);
	}
	else if(oldTileType >= CCTiles::tile_mard1 && oldTileType < CCTiles::tile_mard1 + mar_damaged)
	{
		if(oldTileType == CCTiles::tile_mard7)//WHEN TILE FINALLY BREAKS
		{
			output = 0;
			hitsfx = "destroy_wall";
		}
		else//DAMAGING TILE
		{
			output += 1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
		}
	}
	//MARBLE BACK
	else if(oldTileType >= CCTiles::tile_mar_back && oldTileType < CCTiles::tile_mar_backd1)
	{
		output = CCTiles::tile_mar_backd1;
		hitsfx = "PickStone" + (XORRandom(3) + 1);
	}
	else if(oldTileType >= CCTiles::tile_mar_backd1 && oldTileType <= CCTiles::tile_mar_backd5)
	{
		if(oldTileType == CCTiles::tile_mar_backd5)//WHEN TILE FINALLY BREAKS
		{
			output = 0;
			hitsfx = "destroy_wall";
		}
		else//DAMAGING TILE
		{
			output += 1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
		}
	}
	//BASALT
	else if(oldTileType >= CCTiles::tile_bas && oldTileType < CCTiles::tile_basd1)
	{
		output = CCTiles::tile_basd1;
		hitsfx = "PickStone" + (XORRandom(3) + 1);
	}
	else if(oldTileType >= CCTiles::tile_basd1 && oldTileType < CCTiles::tile_basd1 + bas_damaged)
	{
		if(oldTileType == CCTiles::tile_basd7)//WHEN TILE FINALLY BREAKS
		{
			output = 0;
			hitsfx = "destroy_wall";
		}
		else//DAMAGING TILE
		{
			output += 1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
		}
	}
	//BASALT BACKGROUND
	else if(oldTileType >= CCTiles::tile_bas_back && oldTileType < CCTiles::tile_bas_backd1)
	{
		output = CCTiles::tile_bas_backd1;
		hitsfx = "PickStone" + (XORRandom(3) + 1);
	}
	else if(oldTileType >= CCTiles::tile_bas_backd1 && oldTileType < CCTiles::tile_bas_backd1 + bas_back_damaged)
	{
		if(oldTileType == CCTiles::tile_bas_backd5)//WHEN TILE FINALLY BREAKS
		{
			output = 0;
			hitsfx = "destroy_wall";
		}
		else//DAMAGING TILE
		{
			output += 1;
			hitsfx = "PickStone" + (XORRandom(3) + 1);
		}
	}
	//TRACK
	else if(oldTileType >= CCTiles::tile_track && oldTileType < CCTiles::tile_track + track_variation)
	{
		output = 0;
		hitsfx = "metal_stone";
	}
	//GOLD
	else if(oldTileType >= CCTiles::tile_gold && oldTileType < CCTiles::tile_goldd1)
	{
		output = CCTiles::tile_goldd1;
		hitsfx = "dig_stone" + (XORRandom(3) + 1);
	}
	else if(oldTileType >= CCTiles::tile_goldd1 && oldTileType < CCTiles::tile_goldd1 + gold_damaged)
	{
		if(oldTileType == CCTiles::tile_goldd7)//WHEN TILE FINALLY BREAKS
		{
			output = 0;
			 hitsfx = "destroy_gold";
		}
		else//DAMAGING TILE
		{
			output += 1;
			 hitsfx = "dig_stone" + (XORRandom(3) + 1);
		}
	}
	hitsfx += ".ogg";
	if(oldTileType > 256)
		Sound::Play(hitsfx, Vec2f(index % this.tilemapwidth, index / this.tilemapwidth) * 8, 1.0);
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













