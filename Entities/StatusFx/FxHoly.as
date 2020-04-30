//HOLY effect
string hoscriptname = "FxHolyTick";


void applyFxHoly(CBlob@ blob, int time, int power)
{
	if(!blob.hasScript("FxHook"))
		return;
	if(blob.get_u16("fxholytime") > 0)
	{
		if(blob.get_u16("fxholypower") <= power)
		{
			blob.set_u16("fxholytime", time);
			blob.set_u16("fxholypower", power);
		}
	}
	else
	{
		blob.set_u16("fxholytime", time);
		blob.set_u16("fxholypower", power);
		blob.AddScript(hoscriptname);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(hoscriptname);
	}
}

void removeFxHoly(CBlob@ blob)
{
	blob.RemoveScript(hoscriptname);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(hoscriptname);
}
