//Purity effect
#include "DamageModCommon.as";
#include "CHitters.as";

namespace FxPure {	

	shared string scriptname() {return "FxPureTick";}

	shared class CPureDamageMod : CDamageModCore
	{
		CPureDamageMod(string name)
		{super(name);}
		
		f32 damageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
		{
			if(this.get_u16("fxpurepower") == 0)
				return damage;
			if(customdata == CHitters::corrupt)
				return damage / float(this.get_u16("fxpurepower"));
			return damage;
		}	
	}

	shared CPureDamageMod @getDamageMod() {
		CRules @rules = getRules();
		CPureDamageMod @dm;

		if (!rules.get("puremod @", @dm)) {
			@dm = @CPureDamageMod(scriptname());
			rules.set("puremod @", @dm);
		}
		return @dm;
	}

	shared void apply(CBlob@ blob, int time, int power)
	{
		if(!blob.hasScript("FxHook"))
			return;
		if(blob.get_u16("fxpuretime") > 0)
		{
			if(blob.get_u16("fxpurepower") <= power)
			{
				blob.set_u16("fxpuretime", time);
				blob.set_u16("fxpurepower", power);
			}
		}
		else
		{
			addDamageMod(blob, @getDamageMod());
			blob.set_u16("fxpuretime", time);
			blob.set_u16("fxpurepower", power);
			CSprite@ sprite = blob.getSprite();
			if(sprite !is null)
				sprite.AddScript(scriptname());
		}
	}

	void remove(CBlob@ blob)
	{
		removeDamageMod(blob, @getDamageMod());
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.RemoveScript(scriptname());
	}

}