//Purity effect
#include "DamageModCommon.as";
#include "CHitters.as";

string puscriptname = "FxPureTick";

class CPureDamageMod : CDamageModCore
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

CPureDamageMod puremod(puscriptname);

void applyFxPure(CBlob@ blob, int time, int power)
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
		addDamageMod(blob, @puremod);
		blob.set_u16("fxpuretime", time);
		blob.set_u16("fxpurepower", power);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(puscriptname);
	}
}

void removeFxPure(CBlob@ blob)
{
	removeDamageMod(blob, @puremod);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(puscriptname);
}
