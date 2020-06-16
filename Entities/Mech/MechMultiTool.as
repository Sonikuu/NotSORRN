#include "MechCommon.as";
#include "BuilderCommon.as";
#include "PlacementCommon.as";
#include "Help.as";
#include "CommonBuilderBlocks.as";

const u32 markcmdbits = MechBitStreams::TVec2f | MechBitStreams::Tu16;

namespace Builder
{
	enum Cmd
	{
		nil = 0,
		TOOL_CLEAR = 31,
		PAGE_SELECT = 32,

		make_block = 64,
		make_reserved = 99
	};

	enum Page
	{
		PAGE_ZERO = 0,
		PAGE_ONE,
		PAGE_TWO,
		PAGE_THREE,
		PAGE_COUNT
	};
}

const string[] PAGE_NAME =
{
	"Building",
	"Component",
	"Source",
	"Device"
};

const string[] PAGE_NAME_SORRN =
{
	"Basic",
	"Alchemic",
	"Source",
	"Device"
};

const u8 GRID_SIZE = 48;
const u8 GRID_PADDING = 12;

const Vec2f MENU_SIZE(6, 6);
const u32 SHOW_NO_BUILD_TIME = 90;

const f32 MAX_MECH_BUILD_LENGTH = 7.0f;

class CMechTool : CMechCore
{
	//I could probs rewrite to make this unneccessary but nah
	BlockCursor@ bc;
	
	//These two will store our build queue thing
	array<Vec2f> bppos;
	array<u16> bpid;
	
	float targangle;
	
	CMechTool()
	{
		@bc = @BlockCursor();
		
		array<Vec2f> bppos();
		array<u16> bpid();
		
		targangle = 0;
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		if(driver !is getLocalPlayerBlob()) return;
		
		CMap@ map = getMap();
		for(int i = 0; i < bpid.size(); i++)
		{
			Vec2f marker = bppos[i];
			CControls@ controls = getControls();
			CCamera@ camera = getCamera();
			if(marker != Vec2f_zero && controls !is null && camera !is null)
			{
				Vec2f scrhalf(getScreenWidth() / 2.0, getScreenHeight() / 2.0);
				float opacity = Maths::Min((marker - controls.getMouseWorldPos()).Length() / 64.0, 1.0);
				Vec2f pos = ((marker + Vec2f(8, 8) - (camera.getPosition())) * camera.targetDistance * 2) + scrhalf;
				
				map.DrawTile(marker - Vec2f(1, 1) * map.tilesize / 2.0, bpid[i], SColor(255, 100, 255, 200), camera.targetDistance, false);
				//GUI::DrawIcon("World.png", bpid[i], Vec2f(16, 16), pos - Vec2f(16, 16), 1, SColor(255 * opacity, 100, 255, 200));
			}
		}
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		if(driver !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? driver.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyPressed(key_action2) :
							false;
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			
			if(part !is null)
			{
				//This doesnt seem to work properly for client :V
				//Fixed by setting SetMouseTaken to false on driver attachmentpoint
				
				part.setAimPos(driver.getAimPos());
				
				CMap@ map = part.getMap();
				//Setting build queue
				if(actionkey && part.get_TileType("buildtile") != 0 && driver is getLocalPlayerBlob())
				{
					Vec2f worldpos = (Vec2f(Maths::Floor(driver.getAimPos().x / map.tilesize), Maths::Floor(driver.getAimPos().y / map.tilesize)) * map.tilesize) + Vec2f(1, 1) * map.tilesize / 2.0;
					if(bppos.find(worldpos) < 0)
					{
						if(isBuildableAtPosIgnoreSupportBlocking(part, worldpos, part.get_TileType("buildtile"), null, bc.sameTileOnBack))
						{
							/*CBitStream params;
							params.write_u8(blob.getAttachments().getAttachmentPoint(attachedPoint).getID());
							params.write_u32(markcmdbits);
							
							params.write_u16(part.get_TileType("buildtile"));
							params.write_Vec2f(worldpos);
							
							//print("CMD Sent");
							blob.SendCommand(blob.getCommandID("partcommand"), params);*/
							bppos.push_back(worldpos);
							bpid.push_back(part.get_TileType("buildtile"));
						}
					}
				}
		
		
		
				CSprite@ sprite = part.getSprite();
				const bool facingleft = part.isFacingLeft();
				Vec2f direction = Vec2f(1, 0).RotateBy(part.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
				
				if (isBuildDelayed(part))
				{
					float angle = targangle;
					if(angle >= 90 && angle < 270)
					{
						part.SetFacingLeft(true);
						angle += 180;
					}
					else
					{
						part.SetFacingLeft(false);
					}
					part.setAngleDegrees(angle);
					return;
				}
				
				if (driver.isInInventory())
				{
					return;
				}

				//don't build with menus open
				if (getHUD().hasMenus())
				{
					return;
				}
				
				if(driver !is getLocalPlayerBlob()) return;

				/*CBlob @carryBlob = this.getCarriedBlob();
				if (carryBlob !is null)
				{
					return;
				}*/

				

				if (bc is null)
				{
					return;
				}
				
				//printInt("BP LEN: ", bpid.length());
				
				int selid = -1;
				u8 selind = 0;
				float seldist = 0;
				Vec2f selpos = Vec2f_zero;
				
				for(int i = 0; i < bpid.size(); i++)
				{

					SetTileAimpos(part, bc, bppos[i]);
					// check buildable
					bc.buildable = false;
					bc.supported = false;
					bc.hasReqs = false;
					TileType buildtile = bpid[i];

					if (buildtile > 0)
					{
						bc.blockActive = true;
						bc.blobActive = false;
						
						u8 blockIndex = getBlockIndexByTile(part, buildtile);
						BuildBlock @block = getBlockByIndex(part, blockIndex);
						if (block !is null)
						{
							bc.missing.Clear();
							bc.hasReqs = hasRequirements(blob.getInventory(), block.reqs, bc.missing, not block.buildOnGround);
						}
						if (bc.cursorClose)
						{
							Vec2f halftileoffset(map.tilesize * 0.5f, map.tilesize * 0.5f);
							bc.buildableAtPos = isBuildableAtPos(part, bc.tileAimPos + halftileoffset, buildtile, null, bc.sameTileOnBack);
							//printf("bc.buildableAtPos " + bc.buildableAtPos );
							bc.rayBlocked = isBuildRayBlocked(part.getPosition(), bc.tileAimPos + halftileoffset, bc.rayBlockedPos);
							bc.buildable = bc.buildableAtPos && !bc.rayBlocked;

							bc.supported = bc.buildable && map.hasSupportAtPos(bc.tileAimPos);
						}

						if(!isBuildableAtPosIgnoreSupportBlocking(part, bppos[i], bpid[i], null, bc.sameTileOnBack))
						{
							bpid.removeAt(i);
							bppos.removeAt(i);
							i--;
							continue;
						}

						if (!getHUD().hasButtons())
						{
							if (bc.cursorClose && bc.buildable && bc.supported)
							{
								if(seldist < (bc.tileAimPos - part.getPosition()).Length())
								{
									seldist = (bc.tileAimPos - part.getPosition()).Length();
									selid = i;
									selind = blockIndex;
									selpos = bc.tileAimPos;
								}
								
							}
							/*else if (part.isKeyJustPressed(key_action1) && !bc.sameTileOnBack)
							{
								Sound::Play("NoAmmo.ogg");
							}*/
						}
					}
					/*else
					{
						bc.blockActive = false;
					}*/
				}
				if(selid != -1)
				{
					CBitStream params;
					params.write_u8(selind);
					params.write_Vec2f(selpos);
					part.SendCommand(part.getCommandID("placeBlock"), params);
					u32 delay = part.get_u32("build delay");
					SetBuildDelay(part, delay);
					bc.blockActive = false;
					
					addHeat(blob, 3);
					
					targangle = -(selpos - part.getPosition()).Angle();
					
					bpid.removeAt(selid);
					bppos.removeAt(selid);
				}
			}
		}
	}
	
	void onTick(CSprite@ sprite, CBlob@ driver)
	{
	
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params)
	{
		if(bits == markcmdbits)
		{
			u16 tileid = params.read_u16();
			Vec2f tilepos = params.read_Vec2f();
			
			bits = 0;
			
			bppos.push_back(tilepos);
			bpid.push_back(tileid);
		}
		return bits;
	}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		CMechCore::onAttach(blob, part);
	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{
	
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "BACK_ARM" || slot == "FRONT_ARM")
			return true;
		return false;
	}
	
	void onCreateInventoryMenu(CBlob@ blob, CBlob@ driver, CGridMenu @gridmenu)
	{
		if(driver is null || blob is null)
			return;
		CInventory@ inv = blob.getInventory();
		CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
		if(inv is null || gridmenu is null || part is null)
			return;
			
		const Vec2f INVENTORY_CE = inv.getInventorySlots() * GRID_SIZE / 2 + gridmenu.getUpperLeftPosition();
		blob.set_Vec2f("backpack position", INVENTORY_CE);

		driver.ClearGridMenusExceptInventory();

		MakeBlocksMenu(inv, driver, INVENTORY_CE, part);
	}

	void MakeBlocksMenu(CInventory@ this, CBlob@ blob, const Vec2f &in INVENTORY_CE, CBlob@ part)
	{
		const bool SRN = getRules().gamemode_name == "SORRN";
		
		//CBlob@ blob = this.getBlob();
		if(blob is null) return;

		BuildBlock[][]@ blocks;
		part.get(blocks_property, @blocks);
		if(blocks is null) return;

		const Vec2f MENU_CE = Vec2f(0, MENU_SIZE.y * -GRID_SIZE - GRID_PADDING) + INVENTORY_CE;

		CGridMenu@ menu = CreateGridMenu(MENU_CE, part, MENU_SIZE, getTranslatedString("Build"));
		if(menu !is null)
		{
			menu.deleteAfterClick = false;

			const u8 PAGE = part.get_u8("build page");

			for(u8 i = 0; i < blocks[PAGE].length; i++)
			{
				BuildBlock@ b = blocks[PAGE][i];
				if(b is null) continue;
				string block_desc = getTranslatedString(b.description);
				CGridButton@ button = menu.AddButton(b.icon, "\n" + block_desc, Builder::make_block + i);
				if(button is null) continue;

				button.selectOneOnClick = true;

				CBitStream missing;
				if(hasRequirements(this, b.reqs, missing, not b.buildOnGround))
				{
					button.hoverText = block_desc + "\n" + getButtonRequirementsText(b.reqs, false);
				}
				else
				{
					button.hoverText = block_desc + "\n" + getButtonRequirementsText(missing, true);
					button.SetEnabled(false);
				}

				CBlob@ carryBlob = part.getCarriedBlob();
				if(carryBlob !is null && carryBlob.getName() == b.name)
				{
					button.SetSelected(1);
				}
				else if(b.tile == part.get_TileType("buildtile") && b.tile != 0)
				{
					button.SetSelected(1);
				}
			}

			const Vec2f TOOL_POS = menu.getUpperLeftPosition() - Vec2f(GRID_PADDING, 0) + Vec2f(-1, 1) * GRID_SIZE / 2;

			CGridMenu@ tool = CreateGridMenu(TOOL_POS, part, Vec2f(1, 1), "");
			if(tool !is null)
			{
				tool.SetCaptionEnabled(false);

				CBitStream params;
				params.write_u16(part.getNetworkID());

				CGridButton@ clear = tool.AddButton("$BUILDER_CLEAR$", "", Builder::TOOL_CLEAR, Vec2f(1, 1), params);
				if(clear !is null)
				{
					clear.SetHoverText(getTranslatedString("Stop building\n"));
				}
			}

			// index menu only available in sandbox
			// Or SORRN
			if(getRules().gamemode_name != "Sandbox" && !SRN) return;

			const Vec2f INDEX_POS = Vec2f(menu.getLowerRightPosition().x + GRID_PADDING + GRID_SIZE, menu.getUpperLeftPosition().y + GRID_SIZE * Builder::PAGE_COUNT / 2);

			CGridMenu@ index = CreateGridMenu(INDEX_POS, part, Vec2f(2, Builder::PAGE_COUNT), "Type");
			if(index !is null)
			{
				index.deleteAfterClick = false;

				CBitStream params;
				params.write_u16(part.getNetworkID());

				for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
				{
					CGridButton@ button;
					if(SRN)
						@button = index.AddButton("$"+PAGE_NAME_SORRN[i]+"$", PAGE_NAME_SORRN[i], Builder::PAGE_SELECT + i, Vec2f(2, 1), params);
					else
						@button = index.AddButton("$"+PAGE_NAME[i]+"$", PAGE_NAME[i], Builder::PAGE_SELECT + i, Vec2f(2, 1), params);
					if(button is null) continue;

					button.selectOneOnClick = true;

					if(i == PAGE)
					{
						button.SetSelected(1);
					}
				}
			}
		}
	}
	
	//Taken straight from BuilderInventory.as
	
	
	void SetTileAimpos(CBlob@ this, BlockCursor@ bc, Vec2f aimpos)
	{
		// calculate tile mouse pos
		Vec2f pos = this.getPosition();

		Vec2f mouseNorm = aimpos - pos;
		f32 mouseLen = mouseNorm.Length();
		const f32 maxLen = MAX_MECH_BUILD_LENGTH;
		mouseNorm /= mouseLen;

		/*if (mouseLen > maxLen * getMap().tilesize)
		{
			f32 d = maxLen * getMap().tilesize;
			Vec2f p = pos + Vec2f(d * mouseNorm.x, d * mouseNorm.y);
			p = getMap().getTileSpacePosition(p);
			bc.tileAimPos = getMap().getTileWorldPosition(p);
		}
		else*/
		{
			bc.tileAimPos = getMap().getTileSpacePosition(aimpos);
			bc.tileAimPos = getMap().getTileWorldPosition(bc.tileAimPos);
		}

		bc.cursorClose = (mouseLen < getMaxBuildDistance(this));
	}

	f32 getMaxBuildDistance(CBlob@ this)
	{
		return (MAX_MECH_BUILD_LENGTH + 0.51f) * getMap().tilesize;
	}
}


void onInit(CBlob@ this)
{
	CMechTool part();
	setMechPart(this, @part);
	
	if(this is null) return;
	
	this.addCommandID("placeBlock");

	if(!this.exists(blocks_property))
	{
		BuildBlock[][] blocks;
		addCommonBuilderBlocks(blocks);
		this.set(blocks_property, blocks);
	}

	if(!this.exists(inventory_offset))
	{
		this.set_Vec2f(inventory_offset, Vec2f(0, 174));
	}

	AddIconToken("$BUILDER_CLEAR$", "BuilderIcons.png", Vec2f(32, 32), 2);

	for(u8 i = 0; i < Builder::PAGE_COUNT; i++)
	{
		AddIconToken("$"+PAGE_NAME[i]+"$", "BuilderPageIcons.png", Vec2f(48, 24), i);
	}

	this.set_Vec2f("backpack position", Vec2f_zero);

	this.set_u8("build page", 0);

	this.set_u8("buildblob", 255);
	this.set_TileType("buildtile", 0);

	this.set_u32("cant build time", 0);
	this.set_u32("show build time", 0);
	
	this.set_u32("build time", getGameTime());
	this.set_u32("build delay", 3);
}

void onTick(CBlob@ this)
{
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
}

//Also copy pasted from BuilderInventory.as;
//is gud
void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	//print("CMD Rec");
	string dbg = "MechMultiTool.as: Unknown command ";

	if(this is null) return;

	if(cmd >= Builder::make_block && cmd < Builder::make_reserved)
	{
		const bool isServer = getNet().isServer();

		BuildBlock[][]@ blocks;
		if(!this.get(blocks_property, @blocks)) return;

		uint i = cmd - Builder::make_block;

		const u8 PAGE = this.get_u8("build page");
		if(blocks !is null && i >= 0 && i < blocks[PAGE].length)
		{
			IMechPart@ part = @getMechPart(this);
			CMechCore@ core = cast<CMechCore>(part);
			if(core is null) return;
			CBlob@ blob = this.getAttachments().getAttachmentPointByName(core.attachedPoint).getOccupied();
			
			if(blob is null) return;
			
			BuildBlock@ block = @blocks[PAGE][i];

			//if(!canBuild(blob, @blocks[PAGE], i)) return; dont need this if we're gonna do it the BP way anyway
			print("asdasqqqqqqqqqqqqqq");
			// put carried in inventory thing first
			if(isServer)
			{
				CBlob@ carryBlob = this.getCarriedBlob();
				if(carryBlob !is null)
				{
					// check if this isn't what we wanted to create
					if(carryBlob.getName() == block.name)
					{
						return;
					}

					if(carryBlob.hasTag("temp blob"))
					{
						carryBlob.Untag("temp blob");
						carryBlob.server_Die();
					}
					else
					{
						// try put into inventory whatever was in hands
						// creates infinite mats duplicating if used on build block, not great :/
						if(!block.buildOnGround && !this.server_PutInInventory(carryBlob))
						{
							carryBlob.server_DetachFromAll();
						}
					}
				}
			}

			if(block.tile == 0)
			{
				//server_BuildBlob(this, @blocks[PAGE], i);
			}
			else
			{
				print("set");
				this.set_TileType("buildtile", block.tile);
			}
		}
	}
	else if(cmd == Builder::TOOL_CLEAR)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;

		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;
		
		IMechPart@ part = @getMechPart(this);
		CMechTool@ core = cast<CMechTool>(part);
		if(core is null) return;
		core.bpid.clear();
		core.bppos.clear();

		target.ClearGridMenus();

		ClearCarriedBlock(target);
	}
	else if(cmd >= Builder::PAGE_SELECT && cmd < Builder::PAGE_SELECT + Builder::PAGE_COUNT)
	{
		u16 id;
		if(!params.saferead_u16(id)) return;

		CBlob@ target = getBlobByNetworkID(id);
		if(target is null) return;

		target.ClearGridMenus();

		target.set_u8("build page", cmd - Builder::PAGE_SELECT);

		ClearCarriedBlock(target);

		if(target is getLocalPlayerBlob())
		{
			//target.CreateInventoryMenu(target.get_Vec2f("backpack position"));
		}
	}
	if (getNet().isServer() && cmd == this.getCommandID("placeBlock"))
	{
		//print("CMD REC");
		u8 index = params.read_u8();
		Vec2f pos = params.read_Vec2f();
		PlaceBlock(this, index, pos);
	}
	
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if(blob.hasTag("flesh"))
		return false;
	return true;
}

void PlaceBlock(CBlob@ this, u8 index, Vec2f cursorPos)
{
	
	
	IMechPart@ part = @getMechPart(this);
	CMechCore@ core = cast<CMechCore>(part);
	if(core is null) return;
	CBlob@ blob = this.getAttachments().getAttachmentPointByName(core.attachedPoint).getOccupied();;
	if(blob is null) return;
	
	BuildBlock @bc = getBlockByIndex(this, index);

	if (bc is null)
	{
		warn("BuildBlock is null " + index);
		return;
	}

	CBitStream missing;

	CInventory@ inv = blob.getInventory();
	if (bc.tile > 0 && hasRequirements(inv, bc.reqs, missing))
	{
		server_TakeRequirements(inv, bc.reqs);
		getMap().server_SetTile(cursorPos, bc.tile);
		
		CBlob@ driver = blob.getAttachments().getAttachedBlob("DRIVER");
		CPlayer@ player = null;
		if(driver !is null)
			@player = driver.getPlayer();

		SendGameplayEvent(createBuiltBlockEvent(player, bc.tile));
	}
}

bool isBuildableAtPosIgnoreSupport(CBlob@ this, Vec2f p, TileType buildTile, CBlob @blob, bool &out sameTile)
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
	const bool buildSolid = (map.isTileSolid(buildTile) || (blob !is null && blob.isCollidable()));
	Vec2f tilespace = map.getTileSpacePosition(p);
	const int offset = map.getTileOffsetFromTileSpace(tilespace);
	Tile backtile = map.getTile(offset);
	Tile left = map.getTile(offset - 1);
	Tile right = map.getTile(offset + 1);
	Tile up = map.getTile(offset - map.tilemapwidth);
	Tile down = map.getTile(offset + map.tilemapwidth);

	if (buildTile > 0 && buildTile < 255 && blob is null && buildTile == map.getTile(offset).type)
	{
		sameTile = true;
		return false;
	}

	if(map.isTileCollapsing(offset))
	{
		return false;
	}

	if ((buildTile == CMap::tile_wood && backtile.type >= CMap::tile_wood_d1 && backtile.type <= CMap::tile_wood_d0) ||
			(buildTile == CMap::tile_castle && backtile.type >= CMap::tile_castle_d1 && backtile.type <= CMap::tile_castle_d0))
	{
		//repair like tiles
	}
	else if (backtile.type == CMap::tile_wood && buildTile == CMap::tile_castle)
	{
		// can build stone on wood, do nothing
	}
	else if (buildTile == CMap::tile_wood_back && backtile.type == CMap::tile_castle_back)
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

	if (blob is null || !blob.hasTag("ignore blocking actors"))
	{
		bool isLadder = false;
		bool isSpikes = false;
		if (blob !is null)
		{
			const string bname = blob.getName();
			isLadder = bname == "ladder";
			isSpikes = bname == "spikes";
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
		if (map.getBlobsInRadius(middle, buildSolid ? map.tilesize : 0.0f, @blobsInRadius))
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

						bool cantBuild = isBlocking(b);

						// cant place on any other blob
						if (cantBuild &&
							!b.hasTag("dead") &&
							!b.hasTag("material") &&
							!b.hasTag("projectile") &&
							bname != "bush")
						{
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

bool isBuildableAtPosIgnoreSupportBlocking(CBlob@ this, Vec2f p, TileType buildTile, CBlob @blob, bool &out sameTile)
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
	const bool buildSolid = (map.isTileSolid(buildTile) || (blob !is null && blob.isCollidable()));
	Vec2f tilespace = map.getTileSpacePosition(p);
	const int offset = map.getTileOffsetFromTileSpace(tilespace);
	Tile backtile = map.getTile(offset);
	Tile left = map.getTile(offset - 1);
	Tile right = map.getTile(offset + 1);
	Tile up = map.getTile(offset - map.tilemapwidth);
	Tile down = map.getTile(offset + map.tilemapwidth);

	if (buildTile > 0 && buildTile < 255 && blob is null && buildTile == map.getTile(offset).type)
	{
		sameTile = true;
		return false;
	}

	if(map.isTileCollapsing(offset))
	{
		return false;
	}

	if ((buildTile == CMap::tile_wood && backtile.type >= CMap::tile_wood_d1 && backtile.type <= CMap::tile_wood_d0) ||
			(buildTile == CMap::tile_castle && backtile.type >= CMap::tile_castle_d1 && backtile.type <= CMap::tile_castle_d0))
	{
		//repair like tiles
	}
	else if (backtile.type == CMap::tile_wood && buildTile == CMap::tile_castle)
	{
		// can build stone on wood, do nothing
	}
	else if (buildTile == CMap::tile_wood_back && backtile.type == CMap::tile_castle_back)
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
	return true;
}
