//Damage reduction status
#include "DamageModCommon.as";
string drscriptname = "FxDamageReduceTick";

/*class CReduceDamageMod : CDamageModCore
{
	CReduceDamageMod(string name)
	{super(name);}
	
	f32 damageMod(CBlob@ this, CBlob@ hitblob, f32 damage, u8 customdata)
	{
		print("ran");
		//if(this.get_u16("fxdamagereducepower") == 0)
			//return damage;
		return damage / float(this.get_u16("fxdamagereducepower") + 1);
	}	
}*/

//CReduceDamageMod reducemod(drscriptname);

void applyFxDamageReduce(CBlob@ blob, int time, int power)
{
	if(!blob.hasScript("FxHook"))
		return;
	if(blob.get_u16("fxdamagereducetime") > 0)
	{
		if(blob.get_u16("fxdamagereducepower") <= power)
		{
			blob.set_u16("fxdamagereducetime", time);
			blob.set_u16("fxdamagereducepower", power);
		}
	}
	else
	{
		//addDamageMod(blob, @reducemod);
		blob.set_u16("fxdamagereducetime", time);
		blob.set_u16("fxdamagereducepower", power);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(drscriptname);
	}
}

void removeFxDamageReduce(CBlob@ blob)
{
	//removeDamageMod(blob, @reducemod);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(drscriptname);
}