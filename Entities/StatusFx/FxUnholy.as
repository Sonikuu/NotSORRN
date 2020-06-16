//UNHOLY effect

namespace FxUnholy {

	shared string scriptname() {return "FxUnholyTick";}
	shared void apply(CBlob@ blob, int time, int power)
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