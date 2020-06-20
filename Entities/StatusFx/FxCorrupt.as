//Corruption effect
#include "DamageModCommon.as";

string cscriptname = "FxCorruptTick";

/*class CCorruptDamageMod : CDamageModCore
{
	CCorruptDamageMod(string name)
	{super(name);}
	
	f32 damageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
	{
		return damage * this.get_u16("fxcorruptpower");
	}	
}

CCorruptDamageMod corruptmod(cscriptname);

void applyFxCorrupt(CBlob@ blob, int time, int power)
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
		addDamageMod(blob, @corruptmod);
		blob.set_u16("fxcorrupttime", time);
		blob.set_u16("fxcorruptpower", power);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(cscriptname);
	}
}

void removeFxCorrupt(CBlob@ blob)
{
	removeDamageMod(blob, @corruptmod);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(cscriptname);
}

shared f32 corruptDamageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
{
	return damage * this.get_u16("fxcorruptpower");
}*/