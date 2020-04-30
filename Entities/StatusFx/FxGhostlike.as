//Damage reduction status

//#include "FxLowGrav.as";

string scriptnameghost = "FxGhostlikeTick";

void applyFxGhostlike(CBlob@ blob, int time, int power)
{
	CShape@ shape = blob.getShape();
	if(!blob.exists("ghostliketogglecoll") && shape !is null)
	{
		blob.set_bool("ghostliketogglecoll", shape.getConsts().mapCollisions);
	}
	if(blob.hasScript(scriptnameghost))
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
		blob.AddScript(scriptnameghost);
	}
}

void removeFxGhostlike(CBlob@ blob)
{
	if(!blob.hasScript(scriptnameghost))
		return;
	CShape@ shape = blob.getShape();
	if(blob.get_bool("ghostliketogglecoll") && shape !is null)
		shape.getConsts().mapCollisions = true;
	blob.RemoveScript(scriptnameghost);
	//removeFxLowGrav(blob);
}