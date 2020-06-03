
#include "PlantGrowthCommon.as";
#include "canGrow.as";

void plantGrowthTick(CBlob@ this)
{
	if (getNet().isServer())
	{
		Vec2f pos = this.getPosition();

		u8 amount = this.get_u8(grown_amount);

		if (amount >= this.get_u8("growth max") && !this.hasTag(grown_tag))
		{
			this.Tag(grown_tag);
			this.server_SetHealth(this.getInitialHealth());
		}
		else if (canGrowAt(this, (pos + Vec2f(0.0f, 6.0f))))
		{
			if (XORRandom(this.get_u8(growth_chance)) == 0)
			{
				amount++;
				this.set_u8(grown_amount, amount);
				this.Sync(grown_amount, true);
			}
		}
		else //have been unrooted and not grown! ungrow!
		{
			this.set_u8(grown_amount, 0); //TODO maybe remove, griefable
		}
	}
	this.Sync(grown_tag, true);
}

void onInit(CBlob@ this)
{
	if (!this.exists(grown_amount))
		this.set_u8(grown_amount, 0);
	if (!this.exists(growth_chance))
		this.set_u8(growth_chance, default_growth_chance);
	if (!this.exists(growth_time))
		this.set_u8(growth_time, default_growth_time);
	if(!this.exists("growth max"))
		this.set_u8("growth max", growth_max);

	if (this.hasTag("instant_grow"))
		this.set_u8(grown_amount, growth_max);

	this.set("growthtick", @plantGrowthTick);
}



void onTick(CBlob@ this)
{
	plantGrowthTick(this);
	u8 time = this.get_u8(growth_time);
	//time = 1;
	this.getCurrentScript().tickFrequency = time;
}
