//Damage reduction status

//#include "FxLowGrav.as";
namespace FxGhostlike {

	shared string scriptname() {return "FxGhostlikeTick";}

	shared void apply(CBlob@ blob, int time, int power)
	{
		CShape@ shape = blob.getShape();
		if(!blob.exists("ghostliketogglecoll") && shape !is null)
		{
			blob.set_bool("ghostliketogglecoll", shape.getConsts().mapCollisions);
		}
		if(blob.hasScript(scriptname()))
		{
			if(blob.get_u16("fxghostlikepower") <= power)
			{
				blob.set_u16("fxghostliketime", time);
				blob.set_u16("fxghostlikepower", power);
				//applyFxLowGrav(blob, time + 100, 100);
			}
		}
		else
		{
			blob.set_u16("fxghostliketime", time);
			blob.set_u16("fxghostlikepower", power);
			//applyFxLowGrav(blob, time + 100, 100);
			if(blob.get_bool("ghostliketogglecoll"))
				shape.getConsts().mapCollisions = false;
			blob.AddScript(scriptname());
		}
	}

	void remove(CBlob@ blob)
	{
		if(!blob.hasScript(scriptname()))
			return;
		CShape@ shape = blob.getShape();
		if(blob.get_bool("ghostliketogglecoll") && shape !is null)
			shape.getConsts().mapCollisions = true;
		blob.RemoveScript(scriptname());
		//removeFxLowGrav(blob);
	}

}