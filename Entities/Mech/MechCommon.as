//Core for all mech stuff
//Similar to system used in kagranger
//Some it copy pasta'd from there

//Had a realization, each command can have a constant holding a completed bitstream bit thing
//Instead of checking every time we're about to read another var
//Should replace the system in KAGRanger with similar

//TBH this probably isnt needed for this mod because equipment is an actual blob instead of data attached to the player
//Yeah, might as well remove it

namespace MechBitStreams
{
	enum Types
	{
		Tbool = 	0b00000000001,
		Tu8 = 		0b00000000010,
		Ts8 = 		0b00000000100,
		Tu16 = 		0b00000001000,
		Ts16 = 		0b00000010000,
		Tu32 = 		0b00000100000,
		Ts32 = 		0b00001000000,
		Tf32 = 		0b00010000000,
		Tstring = 	0b00100000000,
		TVec2f =	0b01000000000,
		TVec2f2 =	0b10000000000,
	}
	enum NextToRead
	{
		Nextbool = 		0b00000000001,
		Nextu8 = 		0b00000000011,
		Nexts8 = 		0b00000000111,
		Nextu16 = 		0b00000001111,
		Nexts16 = 		0b00000011111,
		Nextu32 = 		0b00000111111,
		Nexts32 = 		0b00001111111,
		Nextf32 = 		0b00011111111,
		Nextstring = 	0b00111111111,
		NextVec2f =		0b01111111111,
		NextVec2f2 =	0b11111111111,
	}
}


shared interface IMechPart
{
	//All of these only apply once attached
	//Blob should be the core
	//Driver is also an arg for convenience
	void onRender(CBlob@ blob, CBlob@ driver);
	
	void onTick(CBlob@ blob, CBlob@ driver);
	
	void onTick(CSprite@ sprite, CBlob@ driver);
	
	//dunno if we're gonna use oncommand for this but eh
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params);
	
	void onAttach(CBlob@ blob, CBlob@ driver);
	
	void onDetach(CBlob@ blob, CBlob@ driver);
	
	bool canBeEquipped(string slot);
	
	void onCreateInventoryMenu(CBlob@ blob, CBlob@ driver, CGridMenu @gridmenu);
}

shared class CMechCore : IMechPart
{
	string attachedPoint;
	string shapeName;
	CMechCore(){}
	
	void onRender(CBlob@ blob, CBlob@ driver){}
	
	void onTick(CBlob@ blob, CBlob@ driver){}
	
	void onTick(CSprite@ sprite, CBlob@ driver){}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params){return bits;}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		/*//set sprite layers
		CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
		if(part !is null)
		{
			CSprite@ sprite = part.getSprite();
			CSprite@ coresprite = blob.getSprite();
			if(sprite !is null && coresprite !is null)
			{
				float corez = coresprite.getRelativeZ();
				
			}
		}*/
	}
	
	void onDetach(CBlob@ blob, CBlob@ part){}
	
	bool canBeEquipped(string slot){return true;}
	
	void addHeat(CBlob@ blob, float heat)
	{
		blob.set_f32("heat", heat + blob.get_f32("heat"));
	}
	
	void onCreateInventoryMenu(CBlob@ blob, CBlob@ driver, CGridMenu @gridmenu){}
}

IMechPart@ getMechPart(CBlob@ this)
{
	IMechPart@ part;
	this.get("partsys", @part);
	return @part;
}

void setMechPart(CBlob@ this, IMechPart@ part)
{
	this.set("partsys", @part);
}

void clearLeftoverBits(u32 bits, CBitStream@ params)
{
	if(bits & MechBitStreams::Nextbool == MechBitStreams::Tbool)
	{
		params.read_bool();
		bits &= ~MechBitStreams::Tbool;
	}
	if(bits & MechBitStreams::Nextu8 == MechBitStreams::Tu8)
	{
		params.read_u8();
		bits &= ~MechBitStreams::Tu8;
	}
	if(bits & MechBitStreams::Nexts8 == MechBitStreams::Ts8)
	{
		params.read_s8();
		bits &= ~MechBitStreams::Ts8;
	}
	if(bits & MechBitStreams::Nextu16 == MechBitStreams::Tu16)
	{
		params.read_u16();
		bits &= ~MechBitStreams::Tu16;
	}
	if(bits & MechBitStreams::Nexts16 == MechBitStreams::Ts16)
	{
		params.read_s16();
		bits &= ~MechBitStreams::Ts16;
	}
	if(bits & MechBitStreams::Nextu32 == MechBitStreams::Tu32)
	{
		params.read_u32();
		bits &= ~MechBitStreams::Tu32;
	}
	if(bits & MechBitStreams::Nexts32 == MechBitStreams::Ts32)
	{
		params.read_s32();
		bits &= ~MechBitStreams::Ts32;
	}
	if(bits & MechBitStreams::Nextf32 == MechBitStreams::Tf32)
	{
		params.read_f32();
		bits &= ~MechBitStreams::Tf32;
	}
	if(bits & MechBitStreams::Nextstring == MechBitStreams::Tstring)
	{
		params.read_string();
		bits &= ~MechBitStreams::Tstring;
	}
	if(bits & MechBitStreams::NextVec2f == MechBitStreams::TVec2f)
	{
		params.read_Vec2f();
		bits &= ~MechBitStreams::TVec2f;
	}
	if(bits & MechBitStreams::NextVec2f2 == MechBitStreams::TVec2f2)
	{
		params.read_Vec2f();
		bits &= ~MechBitStreams::TVec2f2;
	}
}

shared class CShapeManager
{
	array<string> shapenames;

	CShapeManager()
	{
		array<string> shapenames();
	}

	string addShape(CShape@ shape, Vec2f[] newshape, string name)
	{
		int number = 0;
		while(nameExists(name + formatInt(number, "")))
			number++;
		shape.AddShape(newshape);
		shapenames.push_back(name + formatInt(number, ""));
		return name + formatInt(number, "");
	}
	void clearAll(CShape@ shape)
	{
		while(shapenames.length > 0)
		{
			shape.RemoveShape(1);
			shapenames.removeAt(0);
		}
	}
	void removeShape(CShape@ shape, string name)
	{
		int id = shapenames.find(name);
		if(id >= 0)
		{
			shape.RemoveShape(id + 1);
			shapenames.removeAt(id);
		}
	}
	bool nameExists(string name)
	{
		if(shapenames.find(name) >= 0)
		{
			return true;
		}
		return false;
	}
}
