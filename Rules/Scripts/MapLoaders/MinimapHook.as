///Minimap Code
// Almost 100% accurately replicates the legacy minimap drawer
// This is due to it being a port of the legacy code, provided by Geti
#include "CustomBlocks.as";
#include "DynamicFluidCommon.as";

void CalculateMinimapColour( CMap@ map, u32 offset, TileType tile, SColor &out col)
{
	int X = offset % map.tilemapwidth;
	int Y = offset/map.tilemapwidth;

	Vec2f pos = Vec2f(X, Y);

	float ts = map.tilesize;
	Tile ctile = map.getTile(pos * ts);

	bool show_gold = getRules().get_bool("show_gold");

	///Colours

	const SColor color_minimap_solid_edge   (0xff844715);
	const SColor color_minimap_solid        (0xffc4873a);
	const SColor color_minimap_back_edge    (0xffc4873a); //yep, same as above
	const SColor color_minimap_back         (0xfff3ac5c);
	const SColor color_minimap_open         (0x00edcca6);
	const SColor color_minimap_gold         (0xffffbd34);
	const SColor color_minimap_gold_edge    (0xffc56c22);
	const SColor color_minimap_gold_exposed (0xfff0872c);

	const SColor color_minimap_water        (0xff2cafde);
	const SColor color_minimap_fire         (0xffd5543f);
	
	const SColor color_minimap_corrupt_edge	(0xff7f007f);
	const SColor color_minimap_corrupt		(0xffaf30af);
	
	const SColor color_minimap_purified_edge(0xff7f7f7f);
	const SColor color_minimap_purified		(0xffafafaf);
	
	//const SColor color_minimap_marble_edge(0xff7f7f7f);
	//const SColor color_minimap_marble	  (0xffafafaf);
	

	//neighbours
	Tile tile_l = map.getTile(MiniMap::clampInsideMap(pos * ts - Vec2f(ts, 0), map));
	Tile tile_r = map.getTile(MiniMap::clampInsideMap(pos * ts + Vec2f(ts, 0), map));
	Tile tile_u = map.getTile(MiniMap::clampInsideMap(pos * ts - Vec2f(0, ts), map));
	Tile tile_d = map.getTile(MiniMap::clampInsideMap(pos * ts + Vec2f(0, ts), map));

	///figure out the correct colour
	if (
		//always solid
		map.isTileGround( tile ) || map.isTileStone( tile ) ||
        map.isTileBedrock( tile ) || map.isTileThickStone( tile ) ||
        map.isTileCastle( tile ) || map.isTileWood( tile ) ||
        //only solid if we're not showing gold separately
        (!show_gold && map.isTileGold( tile )) ||
		//Custom solid tiles
		(ctile.type >= CCTiles::tile_mar && ctile.type <= CCTiles::tile_mard7) ||
		(ctile.type >= CCTiles::tile_bas && ctile.type <= CCTiles::tile_basd7) ||
		(ctile.type >= CCTiles::tile_gold && ctile.type <= CCTiles::tile_goldd7)
    ) {
		//Foreground
		col = color_minimap_solid;

		//Edge
		if( MiniMap::isForegroundOutlineTile(tile_u, map) || MiniMap::isForegroundOutlineTile(tile_d, map) ||
		    MiniMap::isForegroundOutlineTile(tile_l, map) || MiniMap::isForegroundOutlineTile(tile_r, map) )
		{
			col = color_minimap_solid_edge;
		}
		else if(
			show_gold && (
				MiniMap::isGoldOutlineTile(tile_u, map, false) || MiniMap::isGoldOutlineTile(tile_d, map, false) ||
			    MiniMap::isGoldOutlineTile(tile_l, map, false) || MiniMap::isGoldOutlineTile(tile_r, map, false)
			)
		) {
			col = color_minimap_gold_edge;
		}
	}
	else if((map.isTileBackground(ctile) && !map.isTileGrass(tile)) ||
			(ctile.type >= CCTiles::tile_mar_back && ctile.type <= CCTiles::tile_mar_backd5) ||
			(ctile.type >= CCTiles::tile_bas_back && ctile.type <= CCTiles::tile_bas_backd5)
			)
	{
		//Background
		col = color_minimap_back;

		//Edge
		if( MiniMap::isBackgroundOutlineTile(tile_u, map) || MiniMap::isBackgroundOutlineTile(tile_d, map) ||
		    MiniMap::isBackgroundOutlineTile(tile_l, map) || MiniMap::isBackgroundOutlineTile(tile_r, map) )
		{
			col = color_minimap_back_edge;
		}
	}
	else if(show_gold && map.isTileGold(tile))
	{
		//Gold
		col = color_minimap_gold;

		//Edge
		if( MiniMap::isGoldOutlineTile(tile_u, map, true) || MiniMap::isGoldOutlineTile(tile_d, map, true) ||
		    MiniMap::isGoldOutlineTile(tile_l, map, true) || MiniMap::isGoldOutlineTile(tile_r, map, true) )
		{
			col = color_minimap_gold_exposed;
		}
	}
	//Corrupt tiles
	else if(ctile.type >= 400 && ctile.type <= 405)
	{
		if(MiniMap::isForegroundOutlineTile(tile_u, map) || MiniMap::isForegroundOutlineTile(tile_d, map) ||
		MiniMap::isForegroundOutlineTile(tile_l, map) || MiniMap::isForegroundOutlineTile(tile_r, map))
			col = color_minimap_corrupt_edge;
		else
			col = color_minimap_corrupt;
	}
	else if(ctile.type >= 406 && ctile.type <= 408)
	{
		if(MiniMap::isForegroundOutlineTile(tile_u, map) || MiniMap::isForegroundOutlineTile(tile_d, map) ||
		MiniMap::isForegroundOutlineTile(tile_l, map) || MiniMap::isForegroundOutlineTile(tile_r, map))
			col = color_minimap_purified_edge;
		else
			col = color_minimap_purified;
	}
	else
	{
		//Sky
		col = color_minimap_open;
	}

	///Tint the map based on Fire/Water State
	if(IS_WATER_ACTIVE)
	{
		array<array<SColor>>@ waterdata;
		map.get("waterdata", @waterdata);
		if(waterdata !is null && pos.y < waterdata.size() && pos.x < waterdata[0].size())
		{
			if(waterdata[pos.y][pos.x].getRed() > 0)
				col = col.getInterpolated(color_minimap_water,0.5f);
		}
	}
	else 
	{
		if (map.isInWater( pos * ts ))
		{
			col = col.getInterpolated(color_minimap_water,0.5f);
		}
	}
	
	
	if (map.isInFire( pos * ts ))
	{
		col = col.getInterpolated(color_minimap_fire,0.5f);
	}
}

//(avoid conflict with any other functions)
namespace MiniMap
{
	Vec2f clampInsideMap(Vec2f pos, CMap@ map)
	{
		return Vec2f(
			Maths::Clamp(pos.x, 0, (map.tilemapwidth - 0.1f) * map.tilesize),
			Maths::Clamp(pos.y, 0, (map.tilemapheight - 0.1f) * map.tilesize)
		);
	}

	bool isForegroundOutlineTile(Tile tile, CMap@ map)
	{
		return !map.isTileSolid(tile);
	}

	bool isOpenAirTile(Tile tile, CMap@ map)
	{
		return tile.type == CMap::tile_empty ||
			map.isTileGrass(tile.type);
	}

	bool isBackgroundOutlineTile(Tile tile, CMap@ map)
	{
		return isOpenAirTile(tile, map);
	}

	bool isGoldOutlineTile(Tile tile, CMap@ map, bool is_gold)
	{
		return is_gold ?
			!map.isTileSolid(tile.type) :
			map.isTileGold(tile.type);
	}

	//setup the minimap as required on server or client
	void Initialise()
	{
		CRules@ rules = getRules();
		CMap@ map = getMap();

		//add sync script
		//done here to avoid needing to modify gamemode.cfg
		if (!rules.hasScript("MinimapSync.as"))
		{
			rules.AddScript("MinimapSync.as");
		}

		//init appropriately
		if (isServer())
		{
			//load values from cfg
			ConfigFile cfg();
			cfg.loadFile("Base/Rules/MinimapSettings.cfg");

			map.legacyTileMinimap = cfg.read_bool("legacy_minimap", false);
			bool show_gold = cfg.read_bool("show_gold", true);

			//write out values for serialisation
			rules.set_bool("legacy_minimap", map.legacyTileMinimap);
			rules.set_bool("show_gold", show_gold);
		}
		else
		{
			//write defaults for now
			map.legacyTileMinimap = false;
			rules.set_bool("show_gold", true);
		}
	}
}