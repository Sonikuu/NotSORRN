//Damage reduction status

//#include "FxRegenTick.as";

namespace FxRegen {

	shared string scriptname() {return "FxRegenTick";}

	shared void apply(CBlob@ blob, int time, int power)
	{
		if(blob.hasScript(scriptname()))
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
			blob.AddScript(scriptname());
			CSprite@ sprite = blob.getSprite();
			if(sprite !is null)
				sprite.AddScript(scriptname());
		}
	}

	void remove(CBlob@ blob)
	{
		if(!blob.hasScript(scriptname()))
			return;
		//CShape@ shape = blob.getShape();
		//if(blob.get_bool("ghostliketogglecoll") && shape !is null)
			//shape.getConsts().mapCollisions = true;
		blob.RemoveScript(scriptname());
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null)
			sprite.RemoveScript(scriptname());
		//removeFxLowGrav(blob);
	}

}