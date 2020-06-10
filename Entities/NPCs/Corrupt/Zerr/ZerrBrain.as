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

		this.getCurrentScript().tickFrequency = 1;
		//if(gametime % 15 == 0)
		{
			blob.setKeyPressed(key_up, true);
			getTarget(this);
			CBlob@ target = this.getTarget();
			
			if(target !is null)
			{
				blob.setAimPos(target.getPosition() + target.getVelocity());
				Vec2f diff = blob.getPosition() - target.getPosition();
				if(diff.x < 0)
					blob.setKeyPressed(key_right, true);
				else
					blob.setKeyPressed(key_left, true);
					
				if(map.isTileSolid(map.getTile(blob.getPosition() + Vec2f(blob.isFacingLeft() ? -10 : 10, 0))) && diff.y < 0)
					blob.setKeyPressed(key_up, false);
				
				if(64.0 > (blob.getPosition() - target.getPosition()).Length())
				{
					if(/*Maths::Abs(diff.y) < 16 && */getGameTime() % 2 == 0)
					{
						blob.setKeyPressed(key_action2, true);
					}
					//else if(Maths::Abs(diff.x) < 8)
					//{
					//	blob.setKeyPressed(key_up, true);
					//}
				}
			}
			if(target !is null && ((blob.getPosition() - target.getPosition()).Length() > 256 || target.hasTag("dead") || (target.getPosition() - blob.get_Vec2f("patrol")).Length() > 1024))
			{
				this.SetTarget(null);
			}
			if(target is null)
			{
				//this.getCurrentScript().tickFrequency = 15;
				blob.setKeyPressed(key_down, true);
				Vec2f diff = blob.getPosition() - blob.get_Vec2f("patrol");
				if(Maths::Abs(diff.x) < 128)
				{
					if((blob.isFacingLeft() && XORRandom(400) != 0) || XORRandom(400) == 0)
						blob.setKeyPressed(key_left, true);
					else
						blob.setKeyPressed(key_right, true);
				}
				else
				{
					if(diff.x > 0)
						blob.setKeyPressed(key_left, true);
					else
						blob.setKeyPressed(key_right, true);
				}
					
			}
			/*blob.Sync("mright", true);
			blob.Sync("mleft", true);
			blob.Sync("mup", true);
			blob.Sync("action1", true);*/
		}
	}
}

void getTarget(CBrain@ this)
{
	f32 closestDistance = 128;
	CBlob@ closest;
	
	CBlob@ blob = this.getBlob();
	
	CMap@ map = getMap();

	Vec2f pos = blob.getPosition();
	
	for (uint i = 0; i < getPlayerCount(); i++)
	{
		CBlob@ b = getPlayer(i).getBlob();
		if (b !is null && !b.hasTag("dead") && b.getTeamNum() != blob.getTeamNum() && (b.getPosition() - blob.get_Vec2f("patrol")).Length() < 1024) //this search should be fairly quick
		{
			Vec2f bpos = b.getPosition();
			f32 dist = (bpos - pos).Length();
			if (dist < closestDistance && !map.rayCastSolid(pos, bpos))
			{
				@closest = b;
				closestDistance = dist;
			}
		}
	}
	
	if (closest !is null) // FOUND TARGET TO SHOOT!
	{
		this.SetTarget(closest);
		//print("GOT TARGET");
	}
}

Vec2f offsetToVec2f(int offset, CMap@ map)
{	
	return Vec2f(offset % map.tilemapwidth, Maths::Floor(offset / map.tilemapwidth));
}



