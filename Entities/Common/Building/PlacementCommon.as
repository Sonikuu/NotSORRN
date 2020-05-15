#include "CustomBlocks.as";

const f32 MAX_BUILD_LENGTH = 4.0f;

shared class BlockCursor
{
	Vec2f tileAimPos;
	bool cursorClose;
	bool buildable;
	bool supported;
	bool hasReqs;
	// for gui
	bool rayBlocked;
	bool buildableAtPos;
	Vec2f rayBlockedPos;
	bool blockActive;
	bool blobActive;
	bool sameTileOnBack;
	CBitStream missing;

	BlockCursor()
	{
		blobActive = blockActive = buildableAtPos = rayBlocked = hasReqs = supported = buildable = cursorClose = sameTileOnBack = false;
	}
};

void AddCursor(CBlob@ this)
{
	if (!this.exists("blockCursor"))
	{
		BlockCursor bc;
		this.set("blockCursor", bc);
	}
}

bool canPlaceNextTo(CMap@ map, const Tile &in tile)
{
	return tile.support > 0;
}

bool isBuildableAtPos(CBlob@ this, Vec2f p, TileType buildTile, CBlob @blob, bool &out sameTile)
{
	f32 radius = 0.0f;
	CMap@ map = this.getMap();
	sameTile = false;

	if (blob is null) // BLOCKS
	{
		radius = map.tilesize;
	}
	else // BLOB
	{
		radius = blob.getRadius();
	}

	//check height + edge proximity
	if (p.y < 2 * map.tilesize ||
			p.x < 2 * map.tilesize ||
			p.x > (map.tilemapwidth - 2.0f)*map.tilesize)
	{
		return false;
	}

	// tilemap check
	const bool issolid = map.isTileSolid(buildTile) || 
	(buildTile >= CCTiles::tile_mar && buildTile <= CCTiles::tile_mard7) || 
	(buildTile >= CCTiles::tile_bas && buildTile <= CCTiles::tile_basd7) || 
	(buildTile >= CCTiles::tile_gold && buildTile <= CCTiles::tile_goldd7);
	const bool buildSolid = (issolid || (blob !is null && blob.isCollidable()));
	Vec2f tilespace = map.getTileSpacePosition(p);
	const int offset = map.getTileOffsetFromTileSpace(tilespace);
	Tile backtile = map.getTile(offset);
	Tile left = map.getTile(offset - 1);
	Tile right = map.getTile(offset + 1);
	Tile up = map.getTile(offset - map.tilemapwidth);
	Tile down = map.getTile(offset + map.tilemapwidth);
	const int backtilerating = getRating(backtile.type, map);
	const int tilerating = getRating(buildTile, map);
	

	if (buildTile > 0 /*&& buildTile < 255*/ && blob is null && buildTile == backtile.type)
	{
		sameTile = true;
		return false;
	}
	//Special modded tile exceptions and stuff
	else if((buildTile == CCTiles::tile_mar_back && (backtile.type >= CCTiles::tile_mar_back && backtile.type < CCTiles::tile_mar_back + mar_back_variation)) ||
			(buildTile == CCTiles::tile_bas_back && (backtile.type >= CCTiles::tile_bas_back && backtile.type < CCTiles::tile_bas_back + bas_back_variation)) ||
			(buildTile == CCTiles::tile_track && (backtile.type >= CCTiles::tile_track && backtile.type < CCTiles::tile_track + track_variation))
	)
	{
		sameTile = true;
		return false;
	}
	

	if(map.isTileCollapsing(offset))
	{
		return false;
	}

	if ((buildTile == CMap::tile_wood && backtile.type >= CMap::tile_wood_d1 && backtile.type <= CMap::tile_wood_d0) ||
			(buildTile == CMap::tile_castle && backtile.type >= CMap::tile_castle_d1 && backtile.type <= CMap::tile_castle_d0) ||
			(buildTile == CCTiles::tile_mar && backtile.type >= CCTiles::tile_mard1 && backtile.type <= CCTiles::tile_mard7) ||
			(buildTile == CCTiles::tile_bas && backtile.type >= CCTiles::tile_basd1 && backtile.type <= CCTiles::tile_basd7) ||
			(buildTile == CCTiles::tile_gold && backtile.type >= CCTiles::tile_goldd1 && backtile.type <= CCTiles::tile_goldd7))
	{
		//repair like tiles
	}
	//else if (backtile.type == CMap::tile_wood && buildTile == CMap::tile_castle)
	else if (tilerating > backtilerating && blob is null && (issolid == map.isTileSolid(backtile)))
	{
		// can build stone on wood, do nothing
	}
	else if (tilerating < backtilerating && blob is null && (issolid == map.isTileSolid(backtile)))
	{
		//cant build wood on stone background
		return false;
	}
	else if (map.isTileSolid(backtile) || map.hasTileSolidBlobs(backtile))
	{
		if (!buildSolid && !map.hasTileSolidBlobsNoPlatform(backtile) && !map.isTileSolid(backtile))
		{
			//skip onwards, platforms don't block backwall
		}
		else
		{
			return false;
		}
	}

//printf("c");
	bool canPlaceOnBackground = ((blob is null) || (blob.getShape().getConsts().support > 0));   // if this is a blob it has to do support - so spikes cant be placed on back

	if (
		(!canPlaceOnBackground || !map.isTileBackgroundNonEmpty(backtile)) &&      // can put against background
		!(                                              // can put sticking next to something
			canPlaceNextTo(map, left) || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(left))  ||
			canPlaceNextTo(map, right) || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(right)) ||
			canPlaceNextTo(map, up)   || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(up))    ||
			canPlaceNextTo(map, down) || (canPlaceOnBackground && map.isTileBackgroundNonEmpty(down))
		)
	)
	{
		return false;
	}
	// no blocking actors?
	// printf("d");
	if (blob is null || !blob.hasTag("ignore blocking actors"))
	{
		bool isLadder = false;
		bool isSpikes = false;
		float bwidth = 0;
		float bheight = 0;
		float maxsize = 0;
		if (blob !is null)
		{
			const string bname = blob.getName();
			isLadder = bname == "ladder";
			isSpikes = bname == "spikes";
			bheight = blob.getShape().getWidth();
			bwidth = blob.getShape().getWidth();
			maxsize = Maths::Max(bwidth, bheight);
		}

		Vec2f middle = p;

		if (!isLadder && (buildSolid || isSpikes) && map.getSectorAtPosition(middle, "no build") !is null)
		{
			return false;
		}

		//if (blob is null)
		//middle += Vec2f(map.tilesize*0.5f, map.tilesize*0.5f);

		const string name = blob !is null ? blob.getName() : "";
		CBlob@[] blobsInRadius;
		if (map.getBlobsInRadius(middle, (blob !is null && blob.hasTag("building")) ? maxsize : buildSolid ? map.tilesize : 0.0f, @blobsInRadius))
		{
			for (uint i = 0; i < blobsInRadius.length; i++)
			{
				CBlob @b = blobsInRadius[i];
				if (!b.isAttached() && b !is blob)
				{
					if (blob !is null || buildSolid)
					{
						if (b is this && isSpikes) continue;

						Vec2f bpos = b.getPosition();

						const string bname = b.getName();

						bool cantBuild = isBlocking(b) || b.hasTag("building");

						// cant place on any other blob
						//print("gere");
						if (cantBuild &&
							!b.hasTag("dead") &&
							!b.hasTag("material") &&
							!b.hasTag("projectile") &&
							bname != "bush")
						{
							//print("asdadasdasd");
							f32 angle_decomp = Maths::FMod(Maths::Abs(b.getAngleDegrees()), 180.0f);
							bool rotated = angle_decomp > 45.0f && angle_decomp < 135.0f;
							f32 width = rotated ? b.getHeight() : b.getWidth();
							f32 height = rotated ? b.getWidth() : b.getHeight();
							if ((middle.x > bpos.x - width * 0.5f) && (middle.x < bpos.x + width * 0.5f)
								&& (middle.y > bpos.y - height * 0.5f) && (middle.y < bpos.y + height * 0.5f))
							{
								return false;
							}
						}
					}
				}
			}
		}
	}

	return true;
}

int getRating(int tile, CMap@ map)
{
	return 	(tile >= CMap::tile_wood && tile <= CMap::tile_wood_d0) || tile == CMap::tile_wood_back ? 1 ://WOOD
			(tile >= CMap::tile_castle && tile <= CMap::tile_castle_d0) || tile == CMap::tile_castle_back ? 2 ://STONE
			tile >= CCTiles::tile_mar && tile <= CCTiles::tile_bas_backd5 ? 3 ://MARBLE AND BASALT
			tile >= CCTiles::tile_gold && tile <= CCTiles::tile_goldd7 ? 3 : //GOLD
			tile >= CCTiles::tile_track && tile <= CCTiles::tile_tracke ? 10 ://TRACK
			map.isTileSolid(tile) || (tile >= CCTiles::tile_cor1 && tile <= CCTiles::tile_pur3) ? 100 ://REMEMBER TO ADD OTHER NEW NATURAL CUSTOM TILES
			0;
}

bool isBlocking(CBlob@ blob)
{
	string name = blob.getName();
	if (name == "heart" || name == "log" || name == "food" || name == "fishy" || name == "steak" || name == "grain")
		return false;

	return blob.isCollidable() || blob.getShape().isStatic();
}

void SetTileAimpos(CBlob@ this, BlockCursor@ bc, Vec2f size = Vec2f(8, 8))
{
	// calculate tile mouse pos
	if(size == Vec2f_zero)
		size.Set(8, 8);
	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	Vec2f mouseNorm = aimpos - pos;
	f32 mouseLen = mouseNorm.Length();
	const f32 maxLen = MAX_BUILD_LENGTH;
	mouseNorm /= mouseLen;

	if (mouseLen > maxLen * getMap().tilesize)
	{
		f32 d = maxLen * getMap().tilesize;
		Vec2f p = pos + Vec2f(d * mouseNorm.x, d * mouseNorm.y);
		p = getMap().getTileSpacePosition(p);
		bc.tileAimPos = getMap().getTileWorldPosition(p);
		//if(blob !is null)
		{
			bc.tileAimPos.x -= (((size.x / int(getMap().tilesize)) + 1) % 2) * getMap().tilesize * 0.5;
			bc.tileAimPos.y -= (((size.y / int(getMap().tilesize)) + 1) % 2) * getMap().tilesize * 0.5;
		}
	}
	else
	{
		bc.tileAimPos = getMap().getTileSpacePosition(aimpos);
		bc.tileAimPos = getMap().getTileWorldPosition(bc.tileAimPos);

		bc.tileAimPos.x -= (((size.x / int(getMap().tilesize)) + 1) % 2) * getMap().tilesize * 0.5;
		bc.tileAimPos.y -= (((size.y / int(getMap().tilesize)) + 1) % 2) * getMap().tilesize * 0.5;
	}

	bc.cursorClose = (mouseLen < getMaxBuildDistance(this));
}

f32 getMaxBuildDistance(CBlob@ this)
{
	return (MAX_BUILD_LENGTH + 0.51f) * getMap().tilesize;
}

void SetupBuildDelay(CBlob@ this)
{
	this.set_u32("build time", getGameTime());
	this.set_u32("build delay", 7);  // move this to builder init
}

bool isBuildDelayed(CBlob@ this)
{
	return (getGameTime() <= this.get_u32("build time"));
}

void SetBuildDelay(CBlob@ this)
{
	SetBuildDelay(this, this.get_u32("build delay"));
}

void SetBuildDelay(CBlob@ this, uint time)
{
	this.set_u32("build time", getGameTime() + time);
}

bool isBuildRayBlocked(Vec2f pos, Vec2f target, Vec2f &out point)
{
	CMap@ map = getMap();

	Vec2f vector = target - pos;
	vector.Normalize();
	target -= vector * map.tilesize;

	f32 halfsize = map.tilesize * 0.5f;

	return map.rayCastSolid(pos + Vec2f(0, halfsize), target, point) &&
		   map.rayCastSolid(pos + Vec2f(halfsize, 0), target, point) &&
		   map.rayCastSolid(pos + Vec2f(0, -halfsize), target, point) &&
		   map.rayCastSolid(pos + Vec2f(-halfsize, 0), target, point);
}

