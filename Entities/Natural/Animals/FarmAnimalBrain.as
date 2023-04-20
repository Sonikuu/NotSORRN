// Trader brain


void onInit(CBrain@ this)
{
	CBlob@ blob = this.getBlob();
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	if(getNet().isServer())
	{
		this.server_SetActive(true);
	}
}

void onTick(CBrain@ this)
{	
	CBlob@ blob = this.getBlob();
	CMap@ map = getMap();
	if(blob.getPlayer() is null && isServer())
	{
		//u32 gametime = ((getGameTime() / this.getCurrentScript().tickFrequency) + blob.getNetworkID()); //!
		int wanderstate = blob.get_u8("wanderstate");
		if(getGameTime() % 60 == 0)
		{
			blob.set_u8("wanderstate", 2);
			if(XORRandom(6) == 0)
			{
				wanderstate = XORRandom(3);
				blob.set_u8("wanderstate", wanderstate);
			}
		}
		
		this.getCurrentScript().tickFrequency = 1;
		//if(gametime % 15 == 0)
		{
			//getTarget(this);
			CBlob@ target = this.getTarget();
			CMap@ map = getMap();
			if(wanderstate == 0)
			{
				blob.setKeyPressed(key_left, true);
				if(map.isTileSolid(blob.getPosition() + Vec2f(0, blob.getHeight() / 2 - 4) + Vec2f(-20, 0)))
					blob.setKeyPressed(key_up, true);
			}
			else if(wanderstate == 1)
			{
				blob.setKeyPressed(key_right, true);
				if(map.isTileSolid(blob.getPosition() + Vec2f(0, blob.getHeight() / 2 - 4) + Vec2f(20, 0)))
					blob.setKeyPressed(key_up, true);
			}
			
			if(target !is null)
			{
				blob.setAimPos(target.getPosition());
				Vec2f diff = blob.getPosition() - target.getPosition();
				if(diff.x < 0)
					blob.setKeyPressed(key_right, true);
				else
					blob.setKeyPressed(key_left, true);
					
				if(map.isTileSolid(map.getTile(blob.getPosition() + Vec2f(blob.isFacingLeft() ? -10 : 10, 0))))
					blob.setKeyPressed(key_up, true);
				
				/*if(64.0 > (blob.getPosition() - target.getPosition()).Length())
				{
					if(Maths::Abs(diff.y) < 16 && getGameTime() % 2 == 0)
					{
						blob.setKeyPressed(key_action2, true);
					}
					else if(Maths::Abs(diff.x) < 8)
					{
						blob.setKeyPressed(key_up, true);
					}
				}*/
				if(Maths::Abs(diff.x) / 2 < diff.y)
					blob.setKeyPressed(key_up, true);
			}
			/*else if(target !is null && (blob.getPosition() - target.getPosition()).Length() > 128)
			{
				this.SetTarget(null);
			}
			if(target is null)
			{
				this.getCurrentScript().tickFrequency = 15;
			}*/
			/*blob.Sync("mright", true);
			blob.Sync("mleft", true);
			blob.Sync("mup", true);
			blob.Sync("action1", true);*/
		}
	}
}

Vec2f offsetToVec2f(int offset, CMap@ map)
{	
	return Vec2f(offset % map.tilemapwidth, Maths::Floor(offset / map.tilemapwidth));
}



