#include "RenderParticleCommon.as";
#include "WorldRenderCommon.as";
#include "CHitters.as";
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	Random rand(this.getNetworkID());
	this.set("rand", @rand);
	this.SetLightColor(SColor(255, 50, 126, 252));
	this.SetLightRadius(8.0f);
	this.SetLight(true);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.hasTag("flesh") || !this.isOnGround())
		return true;
	return false;
}

void onTick(CBlob@ this)
{
	if(this.hasTag("dying"))
	{
		if(getGameTime() % 20 == 0)
		{
			this.add_u16("intensity", 2);//Intensity from 0 - 60, 60 should be pretty crazy
			this.SetLightRadius(8.0f + this.get_u16("intensity") / 2.0);
			this.server_Hit(this, this.getPosition(), Vec2f_zero, 0.5 / 3.0, 0, true);
		}
		Random@ rand;
		this.get("rand", @rand);
		
		if(this.get_u16("intensity") > rand.NextRanged(100))
		{
			float angle = rand.NextRanged(360);
			const int lightlength = 256;
			
			CMap@ map = getMap();
			HitInfo@[] hitInfos;
			
			Sound::Play("Lightning1.ogg", this.getPosition(), XORRandom(10) / 10.0 + 2, XORRandom(10) / 10.0 + 0.5);
			
			Vec2f endpoint = Vec2f_lengthdir_deg(lightlength, angle) + this.getPosition();
			if (map.getHitInfosFromRay(this.getPosition(), angle, lightlength, this, @hitInfos))
			{
				endpoint = hitInfos[0].hitpos;
				if(isServer())
				{
					if(hitInfos[0].blob !is null)
					{
						Vec2f vel = hitInfos[0].blob.getPosition() - this.getPosition();
						vel.Normalize();
						this.server_Hit(hitInfos[0].blob, endpoint, vel / 5, 1, CHitters::lightning, true);
					}
					else
					{
						map.server_DestroyTile(endpoint, 1.0f, this);
					}
				}
			}
			
			if(isClient())
			{
				CRenderParticleLightning light(0.5, false, false, 0, 0, SColor(255, 100, 186, 252), false, 0);
				light.frompos = this.getPosition();
				light.topos = endpoint;
				addParticleToList(light);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(this.getHealth() - damage < 0)
	{
		if(!this.hasTag("dying"))
		{
			this.Tag("dying");
			this.server_SetHealth(5);
			this.getShape().SetGravityScale(0);
			this.setVelocity(Vec2f(0, -0.5));
			return 0;
		}
	}
	if(customData == CHitters::lightning && this.hasTag("dying"))
	{
		damage = 0;
		this.setVelocity(this.getVelocity() + velocity);
	}
	return damage;
}
