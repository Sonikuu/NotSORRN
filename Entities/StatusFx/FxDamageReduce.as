//Damage reduction status

string drscriptname = "FxDamageReduceTick";

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
		blob.set_u16("fxdamagereducetime", time);
		blob.set_u16("fxdamagereducepower", power);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(drscriptname);
	}
}

void removeFxDamageReduce(CBlob@ blob)
{
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(drscriptname);
}