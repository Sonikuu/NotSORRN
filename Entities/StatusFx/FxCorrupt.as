//Corruption effect
#include "DamageModCommon.as";

namespace FxCorrupt {
	shared string scriptname() {return "FxCorruptTick";}

	shared class CCorruptDamageMod : CDamageModCore
	{
		CCorruptDamageMod(string name)
		{super(name);}
		
		f32 damageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
		{
			return damage * this.get_u16("fxcorruptpower");
		}	
	}

	shared CCorruptDamageMod @getDamageMod() {
		CRules @rules = getRules();
		CCorruptDamageMod @dm;

		if (!rules.get("corruptmod @", @dm)) {
			@dm = @CCorruptDamageMod(scriptname());
			rules.set("corruptmod @", @dm);
		}
		return @dm;
	}

	shared void apply(CBlob@ blob, int time, int power)
	{
		if(!blob.hasScript("FxHook"))
			return;
		if(blob.get_u16("fxcorrupttime") > 0)
		{
			if(blob.get_u16("fxcorruptpower") <= power)
			{
				blob.set_u16("fxcorrupttime", time);
				blob.set_u16("fxcorruptpower", power);
			}
		}
		else
		{
			addDamageMod(blob, @getDamageMod());
			blob.set_u16("fxcorrupttime", time);
			blob.set_u16("fxcorruptpower", power);
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

	f32 DamageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
	{
		return damage * this.get_u16("fxcorruptpower");
	}
}