#include "MakeSeed.as";
#include "PlantLootCommon.as";
#include "PlantGrowthCommon.as";
#include "PlantGrowthData.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	array<CPlantLoot@> loot;
	this.set("plantloot", @loot);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

void onDie(CBlob@ this)
{
	if (getNet().isServer())
	{
		if (this.hasTag(grown_tag))
		{
			generateLoot(this);
		}
		//Always maek seed yeet
		CBlob@ seed = server_MakeSeed(this.getPosition() + Vec2f(0, -12), this.getConfig());
		if (seed !is null)
		{
			seed.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
		}
	}
}

void generateLoot(CBlob@ this)
{
	//Harvest
	array<CPlantLoot@>@ loot;
	this.get("plantloot", @loot);
	if(loot !is null)
	{
		Random rando(XORRandom(0x7FFFFFFF));
		for (int i = 0; i < loot.size(); i++)
		{
			if(rando.NextFloat() <= loot[i].chance)
			{
				CBlob@ newitem = server_CreateBlob(loot[i].lootname, this.getTeamNum(), this.getPosition() + Vec2f(0, -12));
				if (newitem !is null)
				{
					newitem.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
				}
			}
		}
	}
	//Seed - maybe move to being part of loot list?
	if(XORRandom(2) == 0)
	{
		CBlob@ seed = server_MakeSeed(this.getPosition() + Vec2f(0, -12), this.getConfig());
		if (seed !is null)
		{
			seed.setVelocity(Vec2f(XORRandom(5) - 2.5f, XORRandom(5) - 2.5f));
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == Hitters::builder && this.hasTag(grown_tag))
	{
		generateLoot(this);
		this.set_u8(grown_amount, this.get_u8("growth reset"));
		this.Untag(grown_tag);
	}
	return damage;
}

