//armor common

#include "EquipmentCore.as";

class CEquipmentArmor : CEquipmentCore
{
	float healthbonus;

	
	CEquipmentArmor(int healthbonus)
	{
		super();
		this.healthbonus = healthbonus;
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
	
	bool canBeEquipped(CBlob@ blob, int slot)
	{
		if(slot == 2)
			return true;
		return false;
	}
	
	string getDescription()
	{
		return "Armor";
	}
}
