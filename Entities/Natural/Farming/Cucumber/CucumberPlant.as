// Grain logic

#include "PlantGrowthCommon.as";
#include "PlantLootCommon.as";
#include "PlantGrowthData.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0);

	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);

	this.Tag("builder always hit");
	
	this.set_u8("growth max", 30);
	this.set_u8(growth_time, 75 + 30);
	this.set_u8("growth reset", 18);
	
	array<CPlantLoot@>@ loot;
	this.get("plantloot", @loot);
	if(loot !is null)
	{
		loot.push_back(@CPlantLoot("cucumber", 1, 1));
		loot.push_back(@CPlantLoot("cucumber", 0.5, 1));
		//loot.push_back(@CPlantLoot("lantern", 0.5, 1));
	}

	//this.set("growthdata", @CPlantGrowthData("lettuce_plant", 300, 9, 4));
}

