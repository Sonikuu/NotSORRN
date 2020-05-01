
#include "BasePNGLoader.as";
#include "TileInteractions.as";

/**
 *	Template for modders - add custom blocks by
 *		putting this file in your mod with custom
 *		logic for creating tiles in HandleCustomTile.
 *
 * 		Don't forget to check your colours don't overlap!
 *
 *		Note: don't modify this file directly, do it in a mod!
 */

namespace CCTiles
{
	enum CustomTiles
	{
		//pick tile indices from here - indices > 256 are advised.
		tile_cor1 = 400,
		tile_cor2 = 401,
		tile_cor3 = 402,
		tile_cord1 = 403,
		tile_cord2 = 404,
		tile_cord3 = 405,
		tile_pur1 = 406,
		tile_pur2 = 407,
		tile_pur3 = 408,
		tile_mar = 409,
		tile_marh,
		tile_marv,
		tile_mard1,
		tile_mard2,
		tile_mard3,
		tile_mard4,
		tile_mard5,
		tile_mard6,
		tile_mard7 = 418,
		tile_mar_back = 419,
		tile_mar_backv = 420, //blaze it
		tile_mar_backt,
		tile_mar_backb,
		tile_mar_backd1 = 423,
		tile_mar_backd2,
		tile_mar_backd3,
		tile_mar_backd4,
		tile_mar_backd5 = 427,
		tile_bas = 428,
		tile_bash,
		tile_basv,
		tile_basd1,
		tile_basd2,
		tile_basd3,
		tile_basd4,
		tile_basd5,
		tile_basd6,
		tile_basd7,
		tile_bas_back = 438,
		tile_bas_backe, //edge
		tile_bas_backc, //corner
		tile_bas_backd1,
		tile_bas_backd2,
		tile_bas_backd3,
		tile_bas_backd4,
		tile_bas_backd5 = 445,
		tile_track = 446,
		tile_tracks,//straight
		tile_trackc,//corner
		tile_trackt,//t-junction
		tile_tracki = 450,//intersection, 100% not designing roads here
		tile_tracke = 451, //end
		tile_gold = 452, //gold block
		tile_goldf,//floor
		tile_goldv,//vertical
		tile_goldd1,
		tile_goldd2,
		tile_goldd3,
		tile_goldd4,
		tile_goldd5,
		tile_goldd6,
		tile_goldd7 = 461
	};
};

const SColor color_spawn_cave(255, 128, 128, 0);
const SColor color_trade_post(255, 200, 200, 150);
const SColor color_rail_platform(255, 200, 200, 10);
const SColor color_tile_cor1(0xFFAF00AF); // ARGB(255, 175, 0, 175);
const int cor_variation = 3;
const int cor_damaged = 3;

const int pur_variation = 3;

const SColor color_tile_mar(0xFFFAFAFA);
const int mar_variation = 3;
const int mar_damaged = 7;

const SColor color_tile_mar_back(0xFF6A6A6A);
const int mar_back_variation = 4;
const int mar_back_damaged = 5;

const SColor color_tile_bas(0xFF505050);
const int bas_variation = 3;
const int bas_damaged = 7;

const SColor color_tile_bas_back(0xFF202020);
const int bas_back_variation = 3;
const int bas_back_damaged = 5;

const SColor color_tile_track(0xFFAAAAD0);
const int track_variation = 6;

const SColor color_tile_gold(0xFFFFcc22);
const int gold_variation = 3;
const int gold_damaged = 7;

void HandleCustomTile(CMap@ map, int offset, SColor pixel)
{
	const Vec2f position = getSpawnPosition(map, offset);
	
	
	SColor rgb = SColor(0xFF, pixel.getRed(), pixel.getGreen(), pixel.getBlue());
	Vec2f pos = map.getTileWorldPosition(offset);
	f32 tile_offset = map.tilesize * 0.5f;
	pos.x += tile_offset;
	pos.y += tile_offset;
	if(pixel == color_spawn_cave)
	{
		server_CreateBlob("spawncave", 0, Vec2f(0, 4) + position);
		PlaceMostLikelyTile(map, offset);
	}
	if(pixel == color_rail_platform)
	{
		server_CreateBlob("railplatform", 0, position);
		PlaceMostLikelyTile(map, offset);
	}
	if(pixel == color_trade_post)
	{
		server_CreateBlob("tradingpost", 0, position);
		PlaceMostLikelyTile(map, offset);
	}
	else if(pixel == color_tile_cor1)
	{
		HandleCustomTile(map, offset, CCTiles::tile_cor1);
	}
	else if(pixel == color_tile_mar)
	{
		HandleCustomTile(map, offset, CCTiles::tile_mar);
	}
	else if(pixel == color_tile_mar_back)
	{
		HandleCustomTile(map, offset, CCTiles::tile_mar_back);
	}
	else if(pixel == color_tile_bas)
	{
		HandleCustomTile(map, offset, CCTiles::tile_bas);
	}
	else if(pixel == color_tile_bas_back)
	{
		HandleCustomTile(map, offset, CCTiles::tile_bas_back);
	}
	else if(pixel == color_tile_track)
	{
		HandleCustomTile(map, offset, CCTiles::tile_track);
	}
	else if(pixel == color_tile_gold)
	{
		HandleCustomTile(map, offset, CCTiles::tile_gold);
	}
}

Vec2f offsetToVec2f(int offset, CMap@ map)
{	
	return Vec2f(offset % map.tilemapwidth, Maths::Floor(offset / map.tilemapwidth));
}

void HandleCustomTile(CMap@ map, int offset, int tile)
{
	if(tile == CCTiles::tile_cor1)
	{
		int variation = XORRandom(cor_variation);
		
		map.SetTile(offset, CCTiles::tile_cor1 + variation);
		map.RemoveTileFlag(offset, 0xFFFF);
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
	}
	else if(tile == CCTiles::tile_pur1)
	{
		int variation = XORRandom(pur_variation);
		
		map.SetTile(offset, CCTiles::tile_pur1 + variation);
		map.RemoveTileFlag(offset, 0xFFFF);
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
	}
	else if(tile >= CCTiles::tile_mar && tile < CCTiles::tile_mar + mar_variation + mar_damaged)
	{	
		if(tile == CCTiles::tile_mar)
		{
			updateMarble(offset, map, true);
		}
		map.RemoveTileFlag(offset, 0xFFFF);
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.RemoveTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
	}
	else if(tile >= CCTiles::tile_mar_back && tile < CCTiles::tile_mar_back + mar_back_variation + mar_back_damaged)
	{	
		map.RemoveTileFlag(offset, 0xFFFF);
		if(tile == CCTiles::tile_mar_back)
		{
			updateMarbleBack(offset, map, true);
		}
		map.AddTileFlag(offset, Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::BACKGROUND);
		//map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.RemoveTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
	}
	else if(tile >= CCTiles::tile_bas && tile < CCTiles::tile_bas + bas_variation + bas_damaged)
	{	
		if(tile == CCTiles::tile_bas)
		{
			updateBasalt(offset, map, true);
		}
		map.RemoveTileFlag(offset, 0xFFFF);
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.RemoveTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
	}
	else if(tile >= CCTiles::tile_bas_back && tile < CCTiles::tile_bas_back + bas_back_variation + bas_back_damaged)
	{	
		map.RemoveTileFlag(offset, 0xFFFF);
		if(tile == CCTiles::tile_bas_back)
		{
			updateBasaltBack(offset, map, true);
		}
		map.AddTileFlag(offset, Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::BACKGROUND);
		//map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.RemoveTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
	}
	else if(tile >= CCTiles::tile_track && tile < CCTiles::tile_track + track_variation)
	{	
		map.RemoveTileFlag(offset, 0xFFFF);
		if(tile == CCTiles::tile_track)
		{
			updateTrack(offset, map, true);
		}
		map.AddTileFlag(offset, Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::BACKGROUND);
		//map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.RemoveTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
	}
	else if(tile >= CCTiles::tile_gold && tile < CCTiles::tile_gold + gold_variation + gold_damaged)
	{	
		map.RemoveTileFlag(offset, 0xFFFF);
		if(tile == CCTiles::tile_gold)
		{
			updateGold(offset, map, true);
		}
		map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.AddTileFlag(offset, Tile::SOLID | Tile::COLLISION);
		//map.RemoveTileFlag(offset, Tile::LIGHT_PASSES | Tile::LIGHT_SOURCE | Tile::WATER_PASSES);
	}
}



void updateMarble(int offset, CMap@ map, bool updateneighbors = false)
{
	Tile lt = map.getTile(offset - 1);
	Tile rt = map.getTile(offset + 1);
	Tile tt = map.getTile(offset - map.tilemapwidth);
	Tile bt = map.getTile(offset + map.tilemapwidth);
	
	bool islt = lt.type >= CCTiles::tile_mar && lt.type <= CCTiles::tile_mard7;
	bool isrt = rt.type >= CCTiles::tile_mar && rt.type <= CCTiles::tile_mard7;
	bool istt = tt.type >= CCTiles::tile_mar && tt.type <= CCTiles::tile_mard7;
	bool isbt = bt.type >= CCTiles::tile_mar && bt.type <= CCTiles::tile_mard7;
	//Check all sides
	if(islt && isrt && istt && isbt)
	{
		map.SetTile(offset, CCTiles::tile_mar);
	}
	//Is left/right tile check
	else if(islt &&
	isrt) //&&
	//!istt &&
	//!isbt)
	{
		map.SetTile(offset, CCTiles::tile_marh);
	}
	//Is up/down tile check
	else if(//!islt &&
	//!isrt &&
	istt &&
	isbt)
	{
		map.SetTile(offset, CCTiles::tile_marv);
	}
	else
	{
		map.SetTile(offset, CCTiles::tile_mar);
	}
}

void updateBasalt(int offset, CMap@ map, bool updateneighbors = false)
{
	Tile lt = map.getTile(offset - 1);
	Tile rt = map.getTile(offset + 1);
	Tile tt = map.getTile(offset - map.tilemapwidth);
	Tile bt = map.getTile(offset + map.tilemapwidth);
	
	bool islt = lt.type >= CCTiles::tile_bas && lt.type <= CCTiles::tile_basd7;
	bool isrt = rt.type >= CCTiles::tile_bas && rt.type <= CCTiles::tile_basd7;
	bool istt = tt.type >= CCTiles::tile_bas && tt.type <= CCTiles::tile_basd7;
	bool isbt = bt.type >= CCTiles::tile_bas && bt.type <= CCTiles::tile_basd7;
	//Check all sides
	if(islt && isrt && istt && isbt)
	{
		map.SetTile(offset, CCTiles::tile_bas);
	}
	//Is left/right tile check
	else if(islt &&
	isrt) //&&
	//!istt &&
	//!isbt)
	{
		map.SetTile(offset, CCTiles::tile_bash);
	}
	//Is up/down tile check
	else if(//!islt &&
	//!isrt &&
	istt &&
	isbt)
	{
		map.SetTile(offset, CCTiles::tile_basv);
	}
	else
	{
		map.SetTile(offset, CCTiles::tile_bas);
	}
}



void updateMarbleBack(int offset, CMap@ map, bool updateneighbors = false)
{
	Tile lt = map.getTile(offset - 1);
	Tile rt = map.getTile(offset + 1);
	Tile tt = map.getTile(offset - map.tilemapwidth);
	Tile bt = map.getTile(offset + map.tilemapwidth);
	
	bool islt = lt.type >= CCTiles::tile_mar_back && lt.type <= CCTiles::tile_mar_backd5;
	bool isrt = rt.type >= CCTiles::tile_mar_back && rt.type <= CCTiles::tile_mar_backd5;
	bool istt = tt.type >= CCTiles::tile_mar_back && tt.type <= CCTiles::tile_mar_backd5;
	bool isbt = bt.type >= CCTiles::tile_mar_back && bt.type <= CCTiles::tile_mar_backd5;
	
	bool islta = lt.type >= 1;
	bool isrta = rt.type >= 1;
	bool iscta = 0 < map.getTileDirt(offset);
	
	//First check if any on left or right
	map.RemoveTileFlag(offset, Tile::LIGHT_SOURCE);
	if(islta || isrta || iscta)
	{
		map.SetTile(offset, CCTiles::tile_mar_back);
	}
	//Check both sides
	else if(istt && isbt)
	{
		map.SetTile(offset, CCTiles::tile_mar_backv);
		map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
	}
	//Check top
	else if(istt)
	{
		map.SetTile(offset, CCTiles::tile_mar_backb);
		map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
	}
	//Check bottom
	else if(isbt)
	{
		map.SetTile(offset, CCTiles::tile_mar_backt);
		map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
	}
	else
	{
		map.SetTile(offset, CCTiles::tile_mar_back);
	}
}

void updateBasaltBack(int offset, CMap@ map, bool updateneighbors = false)
{
	Tile lt = map.getTile(offset - 1);
	Tile rt = map.getTile(offset + 1);
	Tile tt = map.getTile(offset - map.tilemapwidth);
	Tile bt = map.getTile(offset + map.tilemapwidth);
	
	bool islt = lt.type >= 1;
	bool isrt = rt.type >= 1;
	bool istt = tt.type >= 1;
	bool isbt = bt.type >= 1;
	
	int totalc = (islt ? 1 : 0) + (isrt ? 1 : 0) + (istt ? 1 : 0) + (isbt ? 1 : 0);
	
	//bool islta = lt.type >= 1;
	//bool isrta = rt.type >= 1;
	bool iscta = 0 < map.getTileDirt(offset);
	
	map.RemoveTileFlag(offset, Tile::LIGHT_SOURCE | Tile::FLIP | Tile::ROTATE | Tile::MIRROR);
	if(totalc >= 4 || iscta)
	{
		map.SetTile(offset, CCTiles::tile_bas_back);
	}
	else if(totalc == 3)
	{
		map.SetTile(offset, CCTiles::tile_bas_backe);
		map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
		if(!isbt)
			map.AddTileFlag(offset, Tile::FLIP);
		else if (!islt)
			map.AddTileFlag(offset, Tile::ROTATE | Tile::MIRROR);
		else if(!isrt)
			map.AddTileFlag(offset, Tile::ROTATE);
	}
	else if(totalc == 2)
	{
		map.SetTile(offset, CCTiles::tile_bas_backc);
		map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
		if(isbt && isrt)
			map.AddTileFlag(offset, Tile::MIRROR);
		else if(isbt && islt){}
		else if(istt && isrt)
			map.AddTileFlag(offset, Tile::MIRROR | Tile::FLIP);
		else if(istt && islt)
			map.AddTileFlag(offset, Tile::FLIP);
		else
		{
			map.SetTile(offset, CCTiles::tile_bas_back);
			map.RemoveTileFlag(offset, Tile::LIGHT_SOURCE);
		}
	}
	else if(totalc == 1)
	{
		map.SetTile(offset, CCTiles::tile_bas_backe);
		map.AddTileFlag(offset, Tile::LIGHT_SOURCE);
		if(istt)
			map.AddTileFlag(offset, Tile::FLIP);
		else if (isrt)
			map.AddTileFlag(offset, Tile::ROTATE | Tile::MIRROR);
		else if(islt)
			map.AddTileFlag(offset, Tile::ROTATE);
	}
	else
	{
		map.SetTile(offset, CCTiles::tile_bas_back);
	}
}

void updateTrack(int offset, CMap@ map, bool updateneighbors = false)
{
	Tile lt = map.getTile(offset - 1);
	Tile rt = map.getTile(offset + 1);
	Tile tt = map.getTile(offset - map.tilemapwidth);
	Tile bt = map.getTile(offset + map.tilemapwidth);
	
	bool islt = lt.type >= CCTiles::tile_track && lt.type <= CCTiles::tile_tracke;
	bool isrt = rt.type >= CCTiles::tile_track && rt.type <= CCTiles::tile_tracke;
	bool istt = tt.type >= CCTiles::tile_track && tt.type <= CCTiles::tile_tracke;
	bool isbt = bt.type >= CCTiles::tile_track && bt.type <= CCTiles::tile_tracke;
	
	int totalc = (islt ? 1 : 0) + (isrt ? 1 : 0) + (istt ? 1 : 0) + (isbt ? 1 : 0);
	
	map.RemoveTileFlag(offset, Tile::LIGHT_SOURCE | Tile::FLIP | Tile::ROTATE | Tile::MIRROR);
	if(totalc >= 4)
	{
		map.SetTile(offset, CCTiles::tile_tracki);
	}
	else if(totalc == 3)
	{
		map.SetTile(offset, CCTiles::tile_trackt);
		if(!isbt)
			map.AddTileFlag(offset, Tile::FLIP);
		else if (!islt)
			map.AddTileFlag(offset, Tile::ROTATE | Tile::MIRROR);
		else if(!isrt)
			map.AddTileFlag(offset, Tile::ROTATE);
	}
	else if(totalc == 2)
	{
		if(isbt && istt)
		{
			map.SetTile(offset, CCTiles::tile_tracks);
			map.AddTileFlag(offset, Tile::ROTATE);
		}
		else if (islt && isrt)
		{
			map.SetTile(offset, CCTiles::tile_tracks);
		}
		else
		{
			map.SetTile(offset, CCTiles::tile_trackc);
			if(isbt && isrt)
				map.AddTileFlag(offset, Tile::MIRROR);
			else if(istt && isrt)
				map.AddTileFlag(offset, Tile::MIRROR | Tile::FLIP);
			else if(istt && islt)
				map.AddTileFlag(offset, Tile::FLIP);
		}
	}
	else if(totalc == 1)
	{
		map.SetTile(offset, CCTiles::tile_tracke);
		if(istt)
			map.AddTileFlag(offset, Tile::FLIP);
		else if (isrt)
			map.AddTileFlag(offset, Tile::ROTATE | Tile::MIRROR);
		else if(islt)
			map.AddTileFlag(offset, Tile::ROTATE);
	}
	else
	{
		map.SetTile(offset, CCTiles::tile_track);
	}
}

void updateGold(int offset, CMap@ map, bool updateneighbors = false)
{
	Tile lt = map.getTile(offset - 1);
	Tile rt = map.getTile(offset + 1);
	Tile tt = map.getTile(offset - map.tilemapwidth);
	Tile bt = map.getTile(offset + map.tilemapwidth);
	
	bool islt = lt.type >= 1;
	bool isrt = rt.type >= 1;
	bool istt = tt.type >= 1;
	bool isbt = bt.type >= 1;
	
	int totalc = (islt ? 1 : 0) + (isrt ? 1 : 0) + (istt ? 1 : 0) + (isbt ? 1 : 0);
	
	//bool islta = lt.type >= 1;
	//bool isrta = rt.type >= 1;
	bool iscta = 0 < map.getTileDirt(offset);
	
	if(tt.flags & Tile::SOLID == 0 && lt.type >= CCTiles::tile_gold && lt.type <= CCTiles::tile_goldd7 && rt.type >= CCTiles::tile_gold && rt.type <= CCTiles::tile_goldd7)
	{
		map.SetTile(offset, CCTiles::tile_goldf);
	}
	else if(tt.type >= CCTiles::tile_gold && tt.type <= CCTiles::tile_goldd7 && bt.type >= CCTiles::tile_gold && bt.type <= CCTiles::tile_goldd7)
	{
		map.SetTile(offset, CCTiles::tile_goldv);
	}
	else
	{
		map.SetTile(offset, CCTiles::tile_gold);
	}
}

void updateAllNeighbors(int offset, CMap@ map)
{
	//Can change this when needed, right now just up down left and right
	array<int> positions = {offset - 1, offset + 1, offset - map.tilemapwidth, offset + map.tilemapwidth};
	for(int i = 0; i < positions.length; i++)
	{
		Tile tile = map.getTile(positions[i]);
		if(tile.type >= CCTiles::tile_mar && tile.type < CCTiles::tile_mar + mar_variation)
			updateMarble(positions[i], map);
		else if(tile.type >= CCTiles::tile_mar_back && tile.type < CCTiles::tile_mar_back + mar_back_variation)
			updateMarbleBack(positions[i], map);
		else if(tile.type >= CCTiles::tile_bas && tile.type < CCTiles::tile_bas + bas_variation)
			updateBasalt(positions[i], map);
		else if(tile.type >= CCTiles::tile_bas_back && tile.type < CCTiles::tile_bas_back + bas_back_variation)
			updateBasaltBack(positions[i], map);
		else if(tile.type >= CCTiles::tile_track && tile.type < CCTiles::tile_track + track_variation)
			updateTrack(positions[i], map);
		else if(tile.type >= CCTiles::tile_gold && tile.type < CCTiles::tile_gold + gold_variation)
			updateGold(positions[i], map);
	}
}



/*Vec2f getSpawnPosition(CMap@ map, int offset)
{
	Vec2f pos = map.getTileWorldPosition(offset);
	f32 tile_offset = map.tilesize * 0.5f;
	pos.x += tile_offset;
	pos.y += tile_offset;
	return pos;
}

void PlaceMostLikelyTile(CMap@ map, int offset)
{
	const TileType up = map.getTile(offset - map.tilemapwidth).type;
	const TileType down = map.getTile(offset + map.tilemapwidth).type;
	const TileType left = map.getTile(offset - 1).type;
	const TileType right = map.getTile(offset + 1).type;
	
	if (up != CMap::tile_empty)
	{
		const TileType[] neighborhood = { up, down, left, right };
		
		if ((neighborhood.find(CMap::tile_castle) != -1) ||
		    (neighborhood.find(CMap::tile_castle_back) != -1))
		{
			map.SetTile(offset, CMap::tile_castle_back);
		}
		else if ((neighborhood.find(CMap::tile_wood) != -1) ||
		         (neighborhood.find(CMap::tile_wood_back) != -1))
		{
			map.SetTile(offset, CMap::tile_wood_back );
		}
		else if ((neighborhood.find(CMap::tile_ground) != -1) ||
		         (neighborhood.find(CMap::tile_ground_back) != -1))
		{
			map.SetTile(offset, CMap::tile_ground_back);
		}
	}
	else if(map.isTileSolid(down) && (map.isTileGrass(left) || map.isTileGrass(right)))
	{
		map.SetTile(offset, CMap::tile_grass + 2 + map_random.NextRanged(2));
	}
}*/