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
	//2 = chest, 3 = boots, 4 = helm

	
	CEquipmentArmor(float healthbonus, string spritename, string shrtname)
	{
		super();
		this.healthbonus = healthbonus;
		this.spritename = spritename;
		this.shrtname = shrtname;
		notexor = false;
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
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{
		notexor = true;
		LoadSpritesBuilder(user.getSprite());
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
	
	string modifyTexture(CBlob@ blob, CBlob@ user, string texname, ImageData@ image)
	{
		if(notexor)
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
				if(c.getAlpha() == 255)
					image.put(x, y, c);
			}
		}
		return texname + shrtname;
	}
	
	string appendTexName(string texname)
	{
		if(notexor)
			return texname;
		return texname + shrtname;
	}
}
