//Basically this goes on top of script order to avoid issues
//Means effects added in this way wont be applied to entities without this
//Also inits damage mods
//TBH should just cave and have all effects handled here


//Then I could have it be object oriented
//And have it render a more reasonable way on screen
#include "FxDamageReduce.as";
#include "CHitters.as";
#include "DamageModCommon.as";
#include "FxCorrupt.as";
#include "FxPure.as";

void onInit(CBlob@ this)
{
	array<CDamageModCore@> mods;
	this.set("damagemods", @mods);
}

void onTick(CBlob@ this)
{
	//FxDamageReduce
	if(this.get_u16("fxdamagereducetime") != 0)
	{
		this.add_u16("fxdamagereducetime", -1);
		if(this.get_u16("fxdamagereducetime") == 0)
			removeFxDamageReduce(this);
	}
	
	//FxCorrupt
	if(this.get_u16("fxcorrupttime") != 0)
	{
		this.add_u16("fxcorrupttime", -1);
		if(this.get_u16("fxcorrupttime") == 0)
			removeFxCorrupt(this);
	}
	
	//FxPure
	if(this.get_u16("fxpuretime") != 0)
	{
		this.add_u16("fxpuretime", -1);
		if(this.get_u16("fxpuretime") == 0)
			removeFxPure(this);
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	//print("running onhit");
	if(this.get_u16("fxdamagereducetime") != 0)
	{
		damage /= float(this.get_u16("fxdamagereducepower") + 1);
	}
	
	if(this.get_u16("fxcorrupttime") != 0)
	{
		if(customData == CHitters::pure)
			damage *= float(this.get_u16("fxcorruptpower"));
	}
	
	if(this.get_u16("fxpuretime") != 0)
	{
		if(customData == CHitters::pure)
			damage /= float(this.get_u16("fxpurepower"));
		if(customData == CHitters::corrupt)
			damage = 0;//Complete corrupt damage immunity
	}
	
	if(this.get_u16("fxholytime") != 0)
	{
	//yeet every game uses this armor calc
		float damagemult = 2.5 / (2.5 + float(this.get_u16("fxholypower")));
		damage *= damagemult;
	}
	return damage;
}
