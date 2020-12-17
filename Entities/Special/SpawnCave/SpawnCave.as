void onInit(CBlob@ this)
{
	CSprite@ sp = this.getSprite();
	if(sp !is null)
	{
		sp.SetZ(-50.0f);
		CSpriteLayer@ layer = sp.addSpriteLayer("pushy", "PusheBoi.png", 40, 20);
		Animation@ def = layer.addAnimation("default", 0, false);
		Animation@ anim = layer.addAnimation("effect", 1, false);
		anim.AddFrame(0);
		anim.AddFrame(1);
		anim.AddFrame(2);
		anim.AddFrame(3);
		anim.AddFrame(4);
		
		def.AddFrame(4);
		
		layer.SetAnimation(anim);
		layer.SetFrame(4);
		//layer.ScaleBy(Vec2f(0.5, 0.5));
	}
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		CBlob@[] blobs;
		if(map.getBlobsInRadius(this.getPosition(), 80, @blobs))
		{
			CSprite@ sp = this.getSprite();
			for(int i = 0; i < blobs.size(); i++)
			{
				if(blobs[i].hasTag("corrupt") || blobs[i].hasTag("spawn_protect"))
				{
					float ang = (blobs[i].getPosition() - this.getPosition()).Angle() * -1;
					Vec2f newvel = Vec2f_lengthdir(5, ang);
					blobs[i].setVelocity(newvel);
					this.server_Hit(blobs[i], blobs[i].getPosition(), newvel, 0.25, 0);
					
					if(sp !is null)
					{
						CSpriteLayer@ layer = sp.getSpriteLayer("pushy");
						layer.ResetTransform();
						//layer.SetFrame(0);
						//layer.SetAnimation("effect");
						layer.animation.frame = 0;
						
						
						
						layer.TranslateBy(Vec2f(60, 0));
						layer.RotateBy(ang, Vec2f_zero);
					}
				}	
			}
		}
	}
}