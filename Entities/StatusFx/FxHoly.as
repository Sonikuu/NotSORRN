//HOLY effect

namespace FxHoly {

	shared string scriptname() {return "FxHolyTick";}


	shared void apply(CBlob@ blob, int time, int power)
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