// generic character head script

// TODO: fix double includes properly, added the following line temporarily to fix include issues
#include "PaletteSwap.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"
#include "EquipmentArmorCommon.as"

const s32 NUM_HEADFRAMES = 4;
const s32 NUM_UNIQUEHEADS = 30;
const int FRAMES_WIDTH = 8 * NUM_HEADFRAMES;

//handling Heads pack DLCs

int getHeadsPackIndex(int headIndex)
{
	if (headIndex > 255) {
		if ((headIndex % 256) >= NUM_UNIQUEHEADS) {
			return Maths::Min(getHeadsPackCount() - 1, Maths::Floor(headIndex / 256.0f));
		}
	}
	return 0;
}

bool doTeamColour(int packIndex)
{
	switch (packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

bool doSkinColour(int packIndex)
{
	switch (packIndex) {
		case 1: //FOTW
			return false;
	}
	//otherwise
	return true;
}

int getHeadFrame(CBlob@ blob, int headIndex, bool default_pack)
{
	if (headIndex < NUM_UNIQUEHEADS)
	{
		return headIndex * NUM_HEADFRAMES;
	}

	//special heads logic for default heads pack
	if (default_pack && (headIndex == 255 || headIndex < NUM_UNIQUEHEADS))
	{
		CRules@ rules = getRules();
		bool holidayhead = false;
		if (rules !is null && rules.exists("holiday"))
		{
			const string HOLIDAY = rules.get_string("holiday");
			if (HOLIDAY == "Halloween")
			{
				headIndex = NUM_UNIQUEHEADS + 43;
				holidayhead = true;
			}
			else if (HOLIDAY == "Christmas")
			{
				headIndex = NUM_UNIQUEHEADS + 61;
				holidayhead = true;
			}
		}

		//if nothing special set
		if (!holidayhead)
		{
			string config = blob.getConfig();
			if (config == "builder")
			{
				headIndex = NUM_UNIQUEHEADS;
			}
			else if (config == "knight")
			{
				headIndex = NUM_UNIQUEHEADS + 1;
			}
			else if (config == "archer")
			{
				headIndex = NUM_UNIQUEHEADS + 2;
			}
			else if (config == "migrant")
			{
				Random _r(blob.getNetworkID());
				headIndex = 69 + _r.NextRanged(2); //head scarf or old
			}
			else
			{
				// default
				headIndex = NUM_UNIQUEHEADS;
			}
		}
	}

	return (((headIndex - NUM_UNIQUEHEADS / 2) * 2) +
	        (blob.getSexNum() == 0 ? 0 : 1)) * NUM_HEADFRAMES;
}

string getHeadTexture(int headIndex)
{
	return getHeadsPackByIndex(getHeadsPackIndex(headIndex)).filename;
}

CSpriteLayer@ LoadHead(CSprite@ this, int headIndex)
{
	if(!isClient())
		return null;
	CBlob@ blob = this.getBlob();
	CPlayer@ player = blob.getPlayer();

	// strip old head
	this.RemoveSpriteLayer("head");

	// get dlc pack info
	int headsPackIndex = getHeadsPackIndex(headIndex);
	HeadsPack@ pack = getHeadsPackByIndex(headsPackIndex);
	string texture_file = pack.filename;

	bool override_frame = false;

	//get the head index relative to the pack index (without unique heads counting)
	int headIndexInPack = (headIndex - NUM_UNIQUEHEADS) - (headsPackIndex * 256);

	//(has default head set)
	bool defaultHead = (headIndex == 255 || headIndexInPack < 0 || headIndexInPack >= pack.count);
	if (defaultHead)
	{
		//accolade custom head handling
		//todo: consider pulling other custom head stuff out to here
		if (player !is null && !player.isBot())
		{
			Accolades@ acc = getPlayerAccolades(player.getUsername());
			if (acc.hasCustomHead())
			{
				texture_file = acc.customHeadTexture;
				headIndex = acc.customHeadIndex;
				headsPackIndex = 0;
				override_frame = true;
			}
		}
	}
	else
	{
		//not default head; do not use accolades data
	}

	int team = Maths::Min(doTeamColour(headsPackIndex) ? blob.getTeamNum() : 0, 7);
	int skin = doSkinColour(headsPackIndex) ? blob.getSkinNum() : 0;

	
	
	//add new head
	//CSpriteLayer@ head = this.addSpriteLayer("head", texture_file, 16, 16, team, skin);

	//
	headIndex = headIndex % 256; // wrap DLC heads into "pack space"

	// figure out head frame
	s32 headFrame = override_frame ?
		(headIndex * NUM_HEADFRAMES) :
		getHeadFrame(blob, headIndex, headsPackIndex == 0);

	//-------------------Soniku Code-------------------
	
	string texname = texture_file + headFrame / 4 + team;
	
	if(blob !is null)
	{
		for(int i = 0; i < equipslots.size(); i++)
		{
			CBlob@ equipped = null;
			if(blob.get_u16(equipslots[i].name) != 0xFFFF)
				@equipped = getBlobByNetworkID(blob.get_u16(equipslots[i].name));
			
			if(equipped is null)
				continue;
			IEquipment@ equip = @getEquipment(equipped);
			if(equip !is null)
			{
				texname = equip.appendTexName(texname, true);
			}
		}
	}
	
	if(!Texture::exists(texname))
	{
		if (!Texture::exists(texture_file))
			if(!Texture::createFromFile(texture_file, texture_file))
					//Bad things, theres a lotta bad things that they wishin they wishin they wishin they wishin they wishin on me
					print("Failed to create head texture");
					
		Texture::createBySize(texname, 64, 16);
		
		ImageData@ headsheet = Texture::data(texture_file);
		ImageData@ newhead = Texture::data(texname);
			
		Vec2f startpos((headFrame / 4) % (headsheet.width() / 64) * 64, Maths::Floor((headFrame / 4) / (headsheet.width() / 64)) * 16);
		for(int x = 0; x < newhead.width(); x++)
		{
			for(int y = 0; y < newhead.height(); y++)
			{
				SColor c = headsheet.get(x + startpos.x, y + startpos.y);
				//if(c.getAlpha() == 255)
					newhead.put(x, y, c);
			}
		}
		
		
		if(blob !is null)
		{
			for(int i = 0; i < equipslots.size(); i++)
			{
				CBlob@ equipped = null;
				if(blob.get_u16(equipslots[i].name) != 0xFFFF)
					@equipped = getBlobByNetworkID(blob.get_u16(equipslots[i].name));
				
				if(equipped is null)
					continue;
				IEquipment@ equip = @getEquipment(equipped);
				if(equip !is null)
				{
					equip.modifyTexture(equipped, blob, texname, newhead, true);
				}
			}
		}
		
		if(team != 0)
		{
			//COLOR REMAP
			string psfile = "TeamPalette.png";
			if (!Texture::exists(psfile))
				if(!Texture::createFromFile(psfile, psfile))
						print("Failed to create team swap palette data");
						
			ImageData@ paletteswap = Texture::data(psfile);
			//Adding swap colors
			array<SColor> fromcol;
			array<SColor> tocol;
			
			for(int i = 0; i < paletteswap.height(); i++)
			{
				fromcol.push_back(paletteswap.get(0, i));
				tocol.push_back(paletteswap.get(team, i));
			}
			newhead.remap(fromcol, tocol);
		}

		Texture::update(texname, newhead);
	}
	CSpriteLayer@ head = this.addTexturedSpriteLayer("head", texname, 16, 16);
	
	if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		head.SetAnimation(anim);

		head.SetFacingLeft(blob.isFacingLeft());
	}
	//--------------------End Soniku Code--------------------
		
	/*if (head !is null)
	{
		Animation@ anim = head.addAnimation("default", 0, false);
		anim.AddFrame(headFrame);
		anim.AddFrame(headFrame + 1);
		anim.AddFrame(headFrame + 2);
		head.SetAnimation(anim);

		head.SetFacingLeft(blob.isFacingLeft());
	}*/

	//setup gib properties
	blob.set_s32("head index", headFrame);
	blob.set_string("head texture", texture_file);
	blob.set_s32("head team", team);
	blob.set_s32("head skin", skin);

	return head;
}
