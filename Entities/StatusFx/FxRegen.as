//Damage reduction status

//#include "FxRegenTick.as";

const string scriptnameregen = "FxRegenTick";

void applyFxRegen(CBlob@ blob, int time, int power)
{
	if(blob.hasScript(scriptnameregen))
	{
		if(blob.get_u16("fxregenpower") <= power)
		{
			blob.set_u16("fxregentime", time);
			blob.set_u16("fxregenpower", power);
			//applyFxLowGrav(blob, time + 100, 100);
		}
	}
	else
	{
		blob.set_u16("fxregentime", time);
		blob.set_u16("fxregenpower", power);
		//applyFxLowGrav(blob, time + 100, 100);
		//if(blob.get_bool("ghostliketogglecoll"))
			//shape.getConsts().mapCollisions = false;
		blob.AddScript(scriptnameregen);
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.AddScript(scriptnameregen);
	}
}

void removeFxRegen(CBlob@ blob)
{
	if(!blob.hasScript(scriptnameregen))
		return;
	//CShape@ shape = blob.getShape();
	//if(blob.get_bool("ghostliketogglecoll") && shape !is null)
		//shape.getConsts().mapCollisions = true;
	blob.RemoveScript(scriptnameregen);
	CSprite@ sprite = blob.getSprite();
	if(sprite !is null)
		sprite.RemoveScript(scriptnameregen);
	//removeFxLowGrav(blob);
}