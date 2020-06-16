//Light Fall effect
//Just handled in FallDamage.as

namespace FxLightFall {	

	shared string scriptname() {return "FxLightFallTick";}

	shared void apply(CBlob@ blob, int time, int power)
	{
		if(!blob.hasScript("FxHook"))
			return;
		if(blob.get_u16("fxlightfalltime") > 0)
		{
			if(blob.get_u16("fxlightfallpower") <= power)
			{
				blob.set_u16("fxlightfalltime", time);
				blob.set_u16("fxlightfallpower", power);
			}
		}
		else
		{
			blob.set_u16("fxlightfalltime", time);
			blob.set_u16("fxlightfallpower", power);
			blob.AddScript(scriptname());
			CSprite@ sprite = blob.getSprite();
			if(sprite !is null)
				sprite.AddScript(scriptname());
		}
	}

	void remove(CBlob@ blob)
	{
		blob.RemoveScript(scriptname());
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.RemoveScript(scriptname());
	}

}