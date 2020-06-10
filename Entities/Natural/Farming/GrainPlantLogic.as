// Grain logic

#include "PlantGrowthCommon.as";
#include "PlantLootCommon.as";
#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(2) == 0);

	this.getCurrentScript().tickFrequency = 45;
	this.getSprite().SetZ(10.0f);

	this.Tag("builder always hit");
	this.Tag("nature");
	this.set_u8("growth max", 30);
	this.set_u8(growth_time, 75 + 30);
	this.set_u8("growth reset", 18);

	array<CPlantLoot@>@ loot;
	this.get("plantloot", @loot);
	if(loot !is null)
	{
		loot.push_back(@CPlantLoot("grain", 1, 1));
		loot.push_back(@CPlantLoot("grain", 0.5, 1));
	}
	// this script gets removed so onTick won't be run on client on server join, just onInit
	//haha nope
	if (this.hasTag("instant_grow"))
	{
		GrowGrain(this);
	}
}


void onTick(CBlob@ this)
{
	if (this.hasTag(grown_tag) && !this.hasTag("grainstuff"))
	{
		GrowGrain(this);
	}
}

void removeGrain(CBlob@ this)
{
	this.Untag("grainstuff");
	if(isClient())
	{
		CSprite@ s = this.getSprite();
		s.RemoveSpriteLayer("grain0");
		s.RemoveSpriteLayer("grain1");
		s.RemoveSpriteLayer("grain2");
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == Hitters::builder && this.hasTag("grainstuff"))
	{
		removeGrain(this);
	}
	return damage;
}

void GrowGrain(CBlob @this)
{
	this.Tag("grainstuff");
	for (int i = 0; i < 3; i++)
	{
		Vec2f offset;
		int v = this.isFacingLeft() ? 0 : 1;
		switch (i)
		{
			case 0: offset = Vec2f(-1 + v, -16); break;
			case 1: offset = Vec2f(2 + v, -10); break;
			case 2: offset = Vec2f(-4 + v, -5); break;
		}

		CSpriteLayer@ grain = this.getSprite().addSpriteLayer("grain" + i, "Entities/Natural/Farming/Grain.png" , 8, 8);

		if (grain !is null)
		{
			Animation@ anim = grain.addAnimation("default", 0, false);
			anim.AddFrame(0);
			grain.SetAnimation("default");
			grain.SetOffset(offset);
			grain.SetRelativeZ(0.01f * (XORRandom(3) == 0 ? -1 : 1));
		}
	}

	this.Tag("has grain");
	//this.getCurrentScript().runFlags |= Script::remove_after_this;
}
