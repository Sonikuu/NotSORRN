#include "VehicleCommon.as"

// Boat logic

void onInit(CBlob@ this)
{

	Vec2f pos_off(0, 0);

	this.getShape().SetOffset(Vec2f(-6, 16));
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().transports = true;
	this.getShape().SetRotationsAllowed(false);
	this.getShape().SetGravityScale(0.0);

	// additional shapes


	//front bits

	{
		Vec2f[] shape = { Vec2f(52.0f,  9.0f) - pos_off,
		                  Vec2f(73.0f,  9.0f) - pos_off,
		                  Vec2f(93.0f,  36.0f) - pos_off,
		                  Vec2f(48.0f,  14.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}

	//{
	//	Vec2f[] shape = { Vec2f( 69.0f,  23.0f ) -pos_off,
	//					  Vec2f( 93.0f,  31.0f ) -pos_off,
	//					  Vec2f( 79.0f,  43.0f ) -pos_off,
	//					  Vec2f( 69.0f,  45.0f ) -pos_off };
	//	this.getShape().AddShape( shape );
	//}

	//back bit
	{
		Vec2f[] shape = { Vec2f(8.0f,  25.5f) - pos_off,
		                  Vec2f(14.0f, 25.5f) - pos_off,
		                  Vec2f(14.0f, 36.0f) - pos_off,
		                  Vec2f(11.0f, 36.0f) - pos_off
		                };
		this.getShape().AddShape(shape);
	}

	CSprite@ sprite = this.getSprite();

	if(sprite !is null)
	{

		CSpriteLayer@ front = sprite.addSpriteLayer("front layer", sprite.getConsts().filename, 96, 56);
		if (front !is null)
		{
			front.addAnimation("default", 0, false);
			int[] frames = { 0, 4, 5 };
			front.animation.AddFrames(frames);
			front.SetRelativeZ(55.0f);
		}
		
		CSpriteLayer@ balloon = sprite.addSpriteLayer("balloon", sprite.getConsts().filename, 96, 56); //balloon :)
		if (balloon !is null)
		{
			balloon.addAnimation("default", 0, false);
			int[] frames = { 3, 3, 3 };
			balloon.animation.AddFrames(frames);
			balloon.SetRelativeZ(30.0f);
			balloon.SetOffset(Vec2f(0, -26));
		}
	}
	//TODO, add captain trader who sells rare and fun stuff, maybe unstable cores and other oddities
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(!this.get_bool("stopped"))
	{
		
		Vec2f pos = this.getPosition();
		int xpos = pos.x / 8;
		bool keepgoing = true;
		for(int x = xpos - 8; x < xpos + 8; x++)
		{
			if(map.isTileSolid(Vec2f(x, pos.y / 8 + 8) * 8))
			{
				keepgoing = false;
				break;
			}
		}
		if(!keepgoing)
		{
			this.setVelocity(Vec2f_zero);
			this.set_bool("stopped", true);
			this.set_u32("departtime", getGameTime() + 30000);
			
			if(isServer())
			{
				for(int y = 0; y < 30; y++)
				{
					if(!map.isTileSolid(Vec2f(-56, y * 8) + pos))
					{
						map.server_SetTile(Vec2f(-56, y * 8) + pos, 205);
					}
					else
						break;
				}
				Vec2f roundpos = Vec2f(int(pos.x / 8), int(pos.y / 8));
				server_CreateBlob("ladder", 254, Vec2f(-52, 0) + roundpos * 8).getShape().SetStatic(true);
				server_CreateBlob("ladder", 254, Vec2f(-52, 16) + roundpos * 8).getShape().SetStatic(true);
				server_CreateBlob("ladder", 254, Vec2f(-52, 32) + roundpos * 8).getShape().SetStatic(true);
				server_CreateBlob("ladder", 254, Vec2f(-52, 48) + roundpos * 8).getShape().SetStatic(true);
				server_CreateBlob("ladder", 254, Vec2f(-52, 64) + roundpos * 8).getShape().SetStatic(true);
				server_CreateBlob("ladder", 254, Vec2f(-52, 80) + roundpos * 8).getShape().SetStatic(true);
			}
		}
		else
			this.setVelocity(Vec2f(0, 1));
	}
	else
	{
		if(this.get_u32("departtime") < getGameTime())
		{
			this.setVelocity(Vec2f(0, -1));
			if(this.getPosition().y < 64)
				this.server_Die();
		}
		else
		{
			this.setVelocity(Vec2f_zero);
		}
	}
}

void Vehicle_onFire(CBlob@ this, VehicleInfo@ v, CBlob@ bullet, const u8 charge) {}
bool Vehicle_canFire(CBlob@ this, VehicleInfo@ v, bool isActionPressed, bool wasActionPressed, u8 &out chargeValue) {return false;}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return Vehicle_doesCollideWithBlob_boat(this, blob);
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

// SPRITE

void onInit(CSprite@ this)
{
}

void onTick(CSprite@ this)
{
	this.SetZ(-50.0f);
	CBlob@ blob = this.getBlob();
	this.animation.setFrameFromRatio(1.0f - (blob.getHealth() / blob.getInitialHealth()));		// OPT: in warboat too
}
