void onInit(CBlob@ this)
{
	this.setPosition(getLocalPlayerBlob().getAimPos());

	this.set_f32("targetY", this.getPosition().y);

	if(isServer())
	{
		this.set_bool("direction",XORRandom(2) == 1);
		this.Sync("direction",true);
	}

	this.server_SetTimeToDie(60);
}

void onTick(CBlob@ this)
{
	f32 targetY = this.get_f32("targetY") + Maths::Sin(getGameTime()/5) * 12;

	targetY += XORRandom(25) - 12;


	this.setVelocity(Vec2f(this.get_bool("direction") ? 3 : -3,(targetY - this.getPosition().y) * 0.125));
}

void onCollision( CBlob@ this, CBlob@ blob, bool solid, Vec2f normal)
{
	if(solid)
	{
		print(normal + "");
		if(isServer())
		{
			if(normal.y == 1)
			{
				this.add_f32("targetY",24);
			}
			else if(normal.y == -1)
			{
				this.add_f32("targetY",-24);
			}

			if(normal.x == 1 || normal.x == -1)
			{
				this.set_bool("direction",!this.get_bool("direction"));
			}

			this.Sync("direction",true);
			this.Sync("targetY",true);
		}
	}
}