// Drill.as

#include "Hitters.as";
#include "BuilderHittable.as";
#include "ParticleSparks.as";
#include "MaterialCommon.as";
#include "AlchemyCommon.as";

const f32 speed_thresh = 2.4f;
const f32 speed_hard_thresh = 2.6f;

const string buzz_prop = "drill timer";

const string required_class = "builder";

const f32 consume_amount = 0.2;

void onInit(CSprite@ this)
{
	this.SetEmitSound("/Drill.ogg");
	this.SetEmitSoundVolume(0.1);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	bool buzz = blob.get_bool(buzz_prop);
	if (buzz)
	{
		this.SetAnimation("buzz");
	}
	else if (this.isAnimationEnded())
	{
		this.SetAnimation("default");
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!getNet().isClient()) return;

	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void makeSteamPuff(CBlob@ this, const f32 velocity = 1.0f, const int smallparticles = 10, const bool sound = true)
{
	if (sound)
	{
		this.getSprite().PlaySound("Steam.ogg");
	}

	makeSteamParticle(this, Vec2f(), "MediumSteam");
	for (int i = 0; i < smallparticles; i++)
	{
		f32 randomness = (XORRandom(32) + 32) * 0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity(-90, velocity * randomness, 360.0f);
		makeSteamParticle(this, vel);
	}
}

void onInit(CBlob@ this)
{
	this.addCommandID("rotatethis");
	AddIconToken("$rotate_butt$", "TechnologyIcons.png", Vec2f(16, 16), 12);
	
	this.set_u32("hittime", 0);
	this.Tag("place45");
	this.set_s8("place45 distance", 1);
	this.Tag("place45 perp");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	caller.CreateGenericButton("$rotate_butt$", Vec2f(0, 0), this, this.getCommandID("rotatethis"), "Set Rotation", params);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("rotatethis"))
	{
		u16 callerID;
		if (!params.saferead_u16(callerID))
			return;
		this.set_u16("rotaterid", callerID);
	}
}

void handleRotation(CBlob@ this)
{
	if(this.get_u16("rotaterid") == 0xFFFF)
		return;
	CBlob@ rotater = getBlobByNetworkID(this.get_u16("rotaterid"));
	if(rotater !is null)
	{
		float angle = (((rotater.getAimPos() - this.getPosition()).Angle() * -1) + 360) % 360;
		angle /= 45;
		angle = Maths::Round(angle);
		angle *= 45;
		if(angle > 90 && angle < 270)
		{
			angle -= 180;
			this.SetFacingLeft(true);
		}
		else
			this.SetFacingLeft(false);
		this.setAngleDegrees(angle);
		if(rotater.isKeyPressed(key_action1))
			this.set_u16("rotaterid", 0xFFFF);
	}
}

void onTick(CBlob@ this)
{
	handleRotation(this);
	const u32 gametime = getGameTime();
	bool inwater = this.isInWater();

	CSprite@ sprite = this.getSprite();
	
	
	sprite.SetEmitSoundPaused(true);
	if (this.get_bool("riding"))
	{
		//this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		//AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		//CBlob@ holder = point.getOccupied();

		//if (holder is null) return;

		this.getShape().SetRotationsAllowed(false);
		this.setAngularVelocity(0);

		//if (holder.getName() == required_class || sv_gamemode == "TDM")
		{		
			

			//set funny sound under water
			if (inwater)
			{
				sprite.SetEmitSoundSpeed(0.8f + (getGameTime() % 13) * 0.01f);
			}
			else
			{
				sprite.SetEmitSoundSpeed(1.0f);
			}

			sprite.SetEmitSoundPaused(false);
			this.set_bool(buzz_prop, true);

			
			const u8 delay_amount = inwater ? 40 : 16;
			bool skip = ((gametime + this.getNetworkID()) % delay_amount) != 0;

			if (skip) return;

			// delay drill
			{
				const bool facingleft = this.isFacingLeft();
				Vec2f direction = Vec2f(1, 0).RotateBy(this.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
				const f32 sign = (facingleft ? -1.0f : 1.0f);

				const f32 attack_distance = 6.0f;
				Vec2f attackVel = direction * attack_distance;

				const f32 distance = 20.0f;
				bool hitsomething = false;

				CMap@ map = getMap();
				if (map !is null)
				{
					HitInfo@[] hitInfos;
					if (map.getHitInfosFromArc((this.getPosition() - attackVel), -attackVel.Angle(), 30, distance, this, true, @hitInfos))
					{
						bool hit_ground = false;
						for (uint i = 0; i < hitInfos.length; i++)
						{
							f32 attack_dam = 0.5f;
							HitInfo@ hi = hitInfos[i];
							bool hit_constructed = false;
							if (hi.blob !is null) // blob
							{
								//detect
								const bool is_ground = hi.blob.hasTag("blocks sword") && !hi.blob.isAttached() && hi.blob.isCollidable();
								if (is_ground)
								{
									hit_ground = true;
								}

								if (hi.blob.getTeamNum() == this.getTeamNum() ||
								        hit_ground && !is_ground)
								{
									continue;
								}

								//
								hitsomething = true;
								if (getNet().isServer())
								{
									if(hi.blob.hasTag("flesh"))
										attack_dam *= 0.5;
									this.server_Hit(hi.blob, hi.hitpos, attackVel, attack_dam, Hitters::drill);

									// Yield half
									Material::fromBlob(this, hi.blob, attack_dam);
								}
							}
							else // map
							{
								if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
									continue;

								TileType tile = hi.tile;
								hitsomething = true;
								if (getNet().isServer())
								{
									map.server_DestroyTile(hi.hitpos, 1.0f, this);
									//map.server_DestroyTile(hi.hitpos, 1.0f, this);

									Material::fromTile(this, tile, 1.0f);
								}

								if (getNet().isClient())
								{
									if (map.isTileBedrock(tile))
									{
										sprite.PlaySound("/metal_stone.ogg");
										sparks(hi.hitpos, attackVel.Angle(), 1.0f);
									}
								}
							}
						}
					}
				}
				if(hitsomething)
					this.set_f32("railmult", 0.25);
				else
					this.set_f32("railmult", 1);
			}
		}
	}
	else
	{
		this.getShape().SetRotationsAllowed(true);
		this.set_bool(buzz_prop, false);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	/*if (customData == Hitters::fire)
	{
		makeSteamPuff(this);
	}

	if (customData == Hitters::water)
	{
		makeSteamPuff(this);
	}*/

	return damage;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}

void onThisAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().SetEmitSoundPaused(true);
}
