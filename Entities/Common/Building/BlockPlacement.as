#include "PlacementCommon.as"
#include "BuildBlock.as"
#include "Requirements.as"

#include "GameplayEvents.as"

//server-only
void PlaceBlock(CBlob@ this, u8 index, Vec2f cursorPos)
{
	BuildBlock @bc = getBlockByIndex(this, index);

	if (bc is null)
	{
		warn("BuildBlock is null " + index);
		return;
	}

	CBitStream missing;

	CInventory@ inv = this.getInventory();
	if (bc.tile > 0 && hasRequirements(inv, bc.reqs, missing))
	{
		server_TakeRequirements(inv, bc.reqs);
		getMap().server_SetTile(cursorPos, bc.tile);

		GE_BuildBlock(this.getPlayer().getNetworkID(), bc.tile);
	}
}

void onInit(CBlob@ this)
{
	AddCursor(this);
	SetupBuildDelay(this);
	this.addCommandID("placeBlock");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onTick(CBlob@ this)
{
	if (this.isInInventory())
	{
		return;
	}

	//don't build with menus open
	if (getHUD().hasMenus())
	{
		return;
	}

	CBlob @carryBlob = this.getCarriedBlob();
	if (carryBlob !is null)
	{
		return;
	}

	if (isBuildDelayed(this))
	{
		return;
	}

	BlockCursor @bc;
	this.get("blockCursor", @bc);
	if (bc is null)
	{
		return;
	}

	SetTileAimpos(this, bc);
	// check buildable
	bc.buildable = false;
	bc.supported = false;
	bc.hasReqs = false;
	TileType buildtile = this.get_TileType("buildtile");

	if (buildtile > 0)
	{
		bc.blockActive = true;
		bc.blobActive = false;
		CMap@ map = this.getMap();
		u8 blockIndex = getBlockIndexByTile(this, buildtile);
		BuildBlock @block = getBlockByIndex(this, blockIndex);
		if (block !is null)
		{
			bc.missing.Clear();
			bc.hasReqs = hasRequirements(this.getInventory(), block.reqs, bc.missing, not block.buildOnGround);
		}

		if (bc.cursorClose)
		{
			Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);
			bc.buildableAtPos = isBuildableAtPos(this, bc.tileAimPos + halftileoffset, buildtile, null, bc.sameTileOnBack);
			//printf("bc.buildableAtPos " + bc.buildableAtPos );
			bc.rayBlocked = isBuildRayBlocked(this.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
			bc.buildable = bc.buildableAtPos && !bc.rayBlocked;

			bc.supported = bc.buildable && (map.hasSupportAtPos(bc.tileAimPos) /*|| (buildtile == CCTiles::tile_gold)*/);//NOTE: Replace tile_gold with a tile we want to float
		}

		// place block

		if (!getHUD().hasButtons() && this.isKeyPressed(key_action1))
		{
			if (bc.cursorClose && bc.buildable && bc.supported)
			{
				CBitStream params;
				params.write_u8(blockIndex);
				params.write_Vec2f(bc.tileAimPos);
				this.SendCommand(this.getCommandID("placeBlock"), params);
				u32 delay = this.get_u32("build delay");
				SetBuildDelay(this, block.tile < 255 ? delay : delay);
				bc.blockActive = false;
			}
			else if (this.isKeyJustPressed(key_action1) && !bc.sameTileOnBack)
			{
				Sound::Play("NoAmmo.ogg");
			}
		}
	}
	else
	{
		bc.blockActive = false;
	}
}

// render block placement

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (getHUD().hasButtons())
	{
		return;
	}

	if (blob.isKeyPressed(key_action2) || blob.isKeyPressed(key_pickup))   //hack: dont show when builder is attacking
	{
		return;
	}

	CBlob @carryBlob = blob.getCarriedBlob();
	if (carryBlob !is null)
	{
		return;
	}

	if (isBuildDelayed(blob))
	{
		return;
	}

	// draw a map block or other blob that snaps to grid
	TileType buildtile = blob.get_TileType("buildtile");

	if (buildtile > 0)
	{
		CMap@ map = getMap();
		BlockCursor @bc;
		blob.get("blockCursor", @bc);

		if (bc !is null)
		{
			if (bc.cursorClose && bc.hasReqs && bc.buildable)
			{
				SColor color;
				Vec2f aimpos = bc.tileAimPos + getCamera().getInterpolationOffset();

				if (bc.buildable && bc.supported)
				{
					color.set(255, 255, 255, 255);
					map.DrawTile(aimpos, buildtile, color, getCamera().targetDistance, false);
				}
				else
				{
					// no support
					color.set(255, 255, 46, 50);
					const u32 gametime = getGameTime();
					Vec2f offset(0.0f, -1.0f + 1.0f * ((gametime * 0.2f) % 8));
					map.DrawTile(aimpos + offset, buildtile, color, getCamera().targetDistance, false);

					if (gametime % 16 < 9)
					{
						Vec2f supportPos = aimpos + Vec2f(blob.isFacingLeft() ? map.tilesize : -map.tilesize, map.tilesize);
						Vec2f point;
						if (map.rayCastSolid(supportPos, supportPos + Vec2f(0.0f, map.tilesize * 32.0f), point))
						{
							const uint count = (point - supportPos).getLength() / map.tilesize;
							for (uint i = 0; i < count; i++)
							{
								map.DrawTile(supportPos + Vec2f(0.0f, map.tilesize * i), buildtile,
								             SColor(255, 205, 16, 10),
								             getCamera().targetDistance, false);
							}
						}
					}
				}
			}
			else
			{
				f32 halfTile = map.tilesize / 2.0f;
				Vec2f aimpos = blob.getAimPos() + getCamera().getInterpolationOffset();
				Vec2f offset(-0.2f + 0.4f * (Maths::Sin(getGameTime() * 0.5f)), 0.0f);
				map.DrawTile(Vec2f(aimpos.x - halfTile, aimpos.y - halfTile) + offset, buildtile,
				             SColor(255, 255, 46, 50),
				             getCamera().targetDistance, false);
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (getNet().isServer() && cmd == this.getCommandID("placeBlock"))
	{
		u8 index = params.read_u8();
		Vec2f pos = params.read_Vec2f();
		PlaceBlock(this, index, pos);
	}
}

