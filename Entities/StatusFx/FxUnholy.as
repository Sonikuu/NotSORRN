//UNHOLY effect
/*string uhscriptname = "FxUnholyTick";


void applyFxUnholy(CBlob@ blob, int time, int power)
{
	if(!blob.hasScript("FxHook"))
		return;
	if(blob.get_u16("fxunholytime") > 0)
	{
		if(blob.get_u16("fxunholypower") <= power)
		{
			blob.set_u16("fxunholytime", time);
			blob.set_u16("fxunholypower", power);
		}
	}
	else
	{
		blob.set_u16("fxunholytime", time);
		blob.set_u16("fxunholypower", power);
		blob.AddScript(uhscriptname);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(uhscriptname);
	}
}

void removeFxUnholy(CBlob@ blob)
{
	blob.RemoveScript(uhscriptname);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(uhscriptname);
}*/
