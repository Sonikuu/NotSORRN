//armor common

#include "EquipmentCore.as";
#include "RunnerTextures.as";

class CEquipmentArmor : CEquipmentCore
{
	float healthbonus;
	string spritename;
	string shrtname;
	bool notexor;
	int thisslot = 2;
	bool head;
	//2 = chest, 3 = boots, 4 = helm

	
	CEquipmentArmor(float healthbonus, string spritename, string shrtname)
	{
		super();
		this.healthbonus = healthbonus;
		this.spritename = spritename;
		this.shrtname = shrtname;
		notexor = false;
		head = false;
	}
	
	
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		
	}
	
	
	float modifyHealth(CBlob@ blob, CBlob@ user, float health)
	{
		return health + healthbonus;
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		return bits;
	}
	
	void onEquip(CBlob@ blob, CBlob@ user)
	{
		notexor = false;
		LoadSpritesBuilder(user.getSprite());
		if(head)
			user.Tag("queueheadremake");
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{
		notexor = true;
		LoadSpritesBuilder(user.getSprite());
		if(head)
			user.Tag("queueheadremake");
	}
	
	bool canBeEquipped(int slot)
	{
		if(slot == thisslot)
			return true;
		return false;
	}
	
	string getDescription()
	{
		return "Armor";
	}
	
	string modifyTexture(CBlob@ blob, CBlob@ user, string texname, ImageData@ image, bool head)
	{
		if(notexor || this.head != head)
			return texname;
		if (!Texture::exists(spritename))
			if(!Texture::createFromFile(spritename, spritename + ".png"))
				return texname;
		ImageData@ equip = Texture::data(spritename);
		
		for(int x = 0; x < image.width(); x++)
		{
			for(int y = 0; y < image.height(); y++)
			{
				SColor c = equip.get(x, y);
				if(c.getAlpha() == 255 || (head && y < 8))
					image.put(x, y, c);
			}
		}
		return texname + shrtname;
	}
	
	string appendTexName(string texname, bool head)
	{
		if(notexor || this.head != head)// yes, i did head != head
			return texname;
		return texname + shrtname;
	}
}
