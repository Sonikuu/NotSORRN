//Core for all mech stuff
//Similar to system used in kagranger
//Some it copy pasta'd from there

//Had a realization, each command can have a constant holding a completed bitstream bit thing
//Instead of checking every time we're about to read another var
//Should replace the system in KAGRanger with similar

//TBH this probably isnt needed for this mod because equipment is an actual blob instead of data attached to the player
//Yeah, might as well remove it

//All the above are comments from the mech mod
//Because I stole this from the mech mod
//Is it stealing if I also made the mech mod? :V

//I'm back again in this file, 4/16/2021
//Lets see when i'm back again
//I really should go through and clean everything up

namespace EquipmentBitStreams
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


shared interface IEquipment
{
	//All of these only apply once attached
	//Blob should be the equip
	//User is also an arg for convenience
	void onRender(CBlob@ blob, CBlob@ user);
	
	void onTick(CBlob@ blob, CBlob@ user);
	
	void onTick(CSprite@ sprite, CBlob@ user);
	
	//dunno if we're gonna use oncommand for this but eh
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params);
	
	void onEquip(CBlob@ blob, CBlob@ user);
	
	void onUnequip(CBlob@ blob, CBlob@ user);
	
	bool canBeEquipped(int slot);
	
	void onCreateInventoryMenu(CBlob@ blob, CBlob@ user, CGridMenu @gridmenu);

	float modifyHealth(CBlob@ blob, CBlob@ user, float health);

	f32 onHit(CBlob@ blob, CBlob@ user, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData);

	void setAttachPoint(int index);

	bool isTwoHand();
}

shared class CEquipmentCore : IEquipment
{
	int attachedPoint;
	string shapeName;
	float spritescale;
	Vec2f spriteoffset;
	string cmdstr;
	bool twohand;
	
	CEquipmentCore()
	{
		spritescale = 1;
		spriteoffset = Vec2f_zero;
		cmdstr = "partcmd";
		twohand = false;
	} 
	
	void onRender(CBlob@ blob, CBlob@ user){}
	
	void onTick(CBlob@ blob, CBlob@ user){}
	
	void onTick(CSprite@ sprite, CBlob@ user){}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params){return bits;}
	
	void onEquip(CBlob@ blob, CBlob@ user){}
	
	void onUnequip(CBlob@ blob, CBlob@ user){}
	
	bool canBeEquipped(int slot){return true;}
	
	void onCreateInventoryMenu(CBlob@ blob, CBlob@ user, CGridMenu @gridmenu){}

	float modifyHealth(CBlob@ blob, CBlob@ user, float health){return health;}

	f32 onHit(CBlob@ blob, CBlob@ user, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData){return damage;}

	void setAttachPoint(int index){attachedPoint = index;}
	
	bool isTwoHand(){return twohand;}
}

IEquipment@ getEquipment(CBlob@ this)
{
	IEquipment@ equip;
	this.get("equipsys", @equip);
	return @equip;
}

void setEquipment(CBlob@ this, IEquipment@ equip)
{
	this.set("equipsys", @equip);
}

void clearLeftoverBits(u32 bits, CBitStream@ params)
{
	if(bits & EquipmentBitStreams::Nextbool == EquipmentBitStreams::Tbool)
	{
		params.read_bool();
		bits &= ~EquipmentBitStreams::Tbool;
	}
	if(bits & EquipmentBitStreams::Nextu8 == EquipmentBitStreams::Tu8)
	{
		params.read_u8();
		bits &= ~EquipmentBitStreams::Tu8;
	}
	if(bits & EquipmentBitStreams::Nexts8 == EquipmentBitStreams::Ts8)
	{
		params.read_s8();
		bits &= ~EquipmentBitStreams::Ts8;
	}
	if(bits & EquipmentBitStreams::Nextu16 == EquipmentBitStreams::Tu16)
	{
		params.read_u16();
		bits &= ~EquipmentBitStreams::Tu16;
	}
	if(bits & EquipmentBitStreams::Nexts16 == EquipmentBitStreams::Ts16)
	{
		params.read_s16();
		bits &= ~EquipmentBitStreams::Ts16;
	}
	if(bits & EquipmentBitStreams::Nextu32 == EquipmentBitStreams::Tu32)
	{
		params.read_u32();
		bits &= ~EquipmentBitStreams::Tu32;
	}
	if(bits & EquipmentBitStreams::Nexts32 == EquipmentBitStreams::Ts32)
	{
		params.read_s32();
		bits &= ~EquipmentBitStreams::Ts32;
	}
	if(bits & EquipmentBitStreams::Nextf32 == EquipmentBitStreams::Tf32)
	{
		params.read_f32();
		bits &= ~EquipmentBitStreams::Tf32;
	}
	if(bits & EquipmentBitStreams::Nextstring == EquipmentBitStreams::Tstring)
	{
		params.read_string();
		bits &= ~EquipmentBitStreams::Tstring;
	}
	if(bits & EquipmentBitStreams::NextVec2f == EquipmentBitStreams::TVec2f)
	{
		params.read_Vec2f();
		bits &= ~EquipmentBitStreams::TVec2f;
	}
	if(bits & EquipmentBitStreams::NextVec2f2 == EquipmentBitStreams::TVec2f2)
	{
		params.read_Vec2f();
		bits &= ~EquipmentBitStreams::TVec2f2;
	}
}

bool equipmentBlocked(CBlob@ this)
{
	CBlob@ holding = this.getCarriedBlob();
	return this.get_bool("menustate") || (holding !is null && (holding.getConfig().find("drill") >= 0 || holding.isSnapToGrid())) || this.get_TileType("buildtile") != 0 || this.get_u8("wiringmode") != 0;
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
