//Light Fall effect
//Just handled in FallDamage.as

string lfscriptname = "FxLightFallTick";

void applyFxLightFall(CBlob@ blob, int time, int power)
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
		blob.AddScript(lfscriptname);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(lfscriptname);
	}
}

void removeFxLightFall(CBlob@ blob)
{
	blob.RemoveScript(lfscriptname);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(lfscriptname);
}
