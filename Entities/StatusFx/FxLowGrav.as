//Gravity Status effect
namespace FxLowGrav {

	shared void apply(CBlob@ blob, int time, int power)
	{
		CShape@ shape = blob.getShape();
		CMovement@ movement = blob.getMovement();
		if(!blob.exists("basegrav") && shape !is null)
			blob.set_f32("basegrav", shape.getGravityScale());
		if(blob.hasTag("fxgravactive"))
		{
			if(blob.get_u16("fxgravpower") <= power)
			{
				remove(blob, true);
				blob.Tag("fxgravactive");
				blob.set_u16("fxgravtime", time);
				blob.set_u16("fxgravpower", power);
				
				//if(movement !is null && movement.hasScript("RunnerMovement"))
					blob.set_f32("basegrav", blob.get_f32("basegrav") / (2.0 * float(power)));
					shape.SetGravityScale(blob.get_f32("basegrav"));
				//blob.AddScript("FxLowGravTick");
			}
		}
		else
		{
			blob.Tag("fxgravactive");
			blob.set_u16("fxgravtime", time);
			blob.set_u16("fxgravpower", power);
			//if(movement !is null && movement.hasScript("RunnerMovement"))
				blob.set_f32("basegrav", blob.get_f32("basegrav") / (2.0 * float(power)));
				shape.SetGravityScale(blob.get_f32("basegrav"));
			blob.AddScript("FxLowGravTick");
			CSprite@ sprite = blob.getSprite();
			if(sprite !is null)
				sprite.AddScript("FxLowGravTick");
		}
	}

	void refresh(CBlob@ blob)
	{
		CShape@ shape = blob.getShape();
		shape.SetGravityScale(shape.getGravityScale() / (2.0 * float(blob.get_u16("fxgravpower"))));
	}

	shared void remove(CBlob@ blob, bool calconly = false)
	{
		if(!blob.hasTag("fxgravactive"))
			return;
		CShape@ shape = blob.getShape();
		CMovement@ movement = blob.getMovement();
		
		blob.Untag("fxgravactive");
		
		//if(movement !is null && movement.hasScript("RunnerMovement"))
		blob.set_f32("basegrav", blob.get_f32("basegrav") * (2.0 * float(blob.get_u16("fxgravpower"))));
		shape.SetGravityScale(blob.get_f32("basegrav"));
		if(!calconly)
			blob.RemoveScript("FxLowGravTick");
		CSprite@ sprite = blob.getSprite();
		if(sprite !is null && !calconly)
			sprite.AddScript("FxLowGravTick");
	}

}