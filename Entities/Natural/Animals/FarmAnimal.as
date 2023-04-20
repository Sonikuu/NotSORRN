
//script for a bison

#include "AnimalConsts.as";

const u8 DEFAULT_PERSONALITY = TAMABLE_BIT | DONT_GO_DOWN_BIT;
const s16 MAD_TIME = 600;
const float angryspeed = 2.0;
const float passivespeed = 1.0;
const float angryacc = 2.0;
const float passiveacc = 1.0;

//sprite

void onInit(CSprite@ this)
{
	this.ReloadSprites(0, 0); //always blue

}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		f32 x = blob.getVelocity().x;
		if (Maths::Abs(x) > 0.2f)
		{
			this.SetAnimation("walk");
		}
		else
		{
			this.SetAnimation("idle");
		}
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}

//blob

void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player", "flesh"};
	this.set("tags to eat", tags);

	this.set_f32("bite damage", 1.5f);

	//for steaks
	this.set_u8("number of steaks", 8);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.Tag("flesh");

	this.set_s16("angrytime", 0);

	

	this.getCurrentScript().removeIfTag = "dead";

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			ap.offsetZ = 10.0f;
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false; //maybe make a knocked out state? for loading to cata?
}

void onTick(CBlob@ this)
{
	f32 x = this.getVelocity().x;
	if(this.get_u8("jumpcool") > 0)
		this.sub_u8("jumpcool", 1);

	if (Maths::Abs(x) > angryspeed || (!this.hasTag("angry") && Maths::Abs(x) > passivespeed))
	{
		this.SetFacingLeft(x < 0);
	}
	
	{
		if (this.isKeyPressed(key_left) && (x > (this.hasTag("angry") ? -angryspeed : -passivespeed)))
		{
			this.SetFacingLeft(true);
			this.setVelocity(this.getVelocity() + Vec2f(this.hasTag("angry") ? -angryacc : -passiveacc, 0));
		}
		if (this.isKeyPressed(key_right) && (x < (this.hasTag("angry") ? angryspeed : passivespeed)))
		{
			this.SetFacingLeft(false);
			this.setVelocity(this.getVelocity() + Vec2f(this.hasTag("angry") ? angryacc : passiveacc, 0));
		}
		if(this.isKeyPressed(key_up))
		{
			if(this.isOnGround() && this.get_u8("jumpcool") == 0)
			{
				this.setVelocity(this.getVelocity() + Vec2f(0, -5));
				this.set_u8("jumpcool", 10);
			}
		}
	}

	// relax the madness
	{
		s16 mad = this.get_s16("angrytime");
		if (mad > 0)
		{
			this.Tag("angry");
			mad -= 1;
			if (mad <= 0)
			{
				this.getSprite().PlaySound("/BisonBoo");
			}
			this.set_s16("angrytime", mad);
		}
		else
		{
			this.Untag("angry");
			this.getBrain().SetTarget(null);
		}

		
		if(getGameTime() % 65 == 0)
			if (XORRandom(mad > 0 ? 3 : 12) == 0)
				this.getSprite().PlaySound("/BisonBoo");
	}

	// footsteps

	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
	{
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			f32 volume = Maths::Min(0.1f + Maths::Abs(this.getVelocity().x) * 0.1f, 1.0f);
			TileType tile = this.getMap().getTile(this.getPosition() + Vec2f(0.0f, this.getRadius() + 4.0f)).type;

			if (this.getMap().isTileGroundStuff(tile))
			{
				this.getSprite().PlaySound("/EarthStep", volume, 0.75f);
			}
			else
			{
				this.getSprite().PlaySound("/StoneStep", volume, 0.75f);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(hitterBlob.hasTag("flesh"))
	{
		this.getBrain().SetTarget(hitterBlob);
		this.set_s16("angrytime", 30 * 30);
	}
	if(this.getHealth() - damage / 2.0 <= 0)
	{
		CMap@ map = getMap();
		if(map !is null)
		{
			array<CBlob@> blobs;
			map.getBlobsInRadius(this.getPosition(), 256, @blobs);
			for(int i = 0; i < blobs.size(); i++)
			{

				if(this.hasTag("bison") && blobs[i].hasTag("bison"))
				{
					blobs[i].getBrain().SetTarget(hitterBlob);
					blobs[i].set_s16("angrytime", 30 * 60);
				}
			}
		}
	}
	return damage;
}

#include "Hitters.as";

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (blob.hasTag("dead") || blob.hasTag("bison"))
		return false;
	if (blob.hasTag("flesh") && this.isOnGround() && !this.hasTag("angry"))
		return false;
	return true;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null || !solid)
		return;

	if (blob.hasTag("flesh"))
	{
		const f32 vellen = this.getShape().vellen;
		if (vellen > 0.1f)
		{
			Vec2f pos = this.getPosition();
			Vec2f vel = this.getVelocity();
			Vec2f other_pos = blob.getPosition();
			Vec2f direction = other_pos - pos;
			direction.Normalize();
			vel.Normalize();
			if (vel * direction > 0.33f)
			{
				f32 power = Maths::Max(0.25f, 1.0f * vellen);
				this.server_Hit(blob, point1, vel, power, Hitters::flying, false);
			}
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob !is null && customData == Hitters::flying)
	{
		Vec2f force = velocity * this.getMass() * 0.35f ;
		force.y -= 100.0f;
		hitBlob.AddForce(force);
	}
}