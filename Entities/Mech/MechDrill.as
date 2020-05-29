#include "MechCommon.as";
#include "Hitters.as";
#include "MaterialCommon.as";
#include "ParticleSparks.as";

const f32 speed_thresh = 2.4f;
const f32 speed_hard_thresh = 2.6f;

const string buzz_prop = "drill timer";

const string heat_prop = "drill heat";
const u8 heat_max = 150;

const u8 heat_add = 4;
const u8 heat_add_constructed = 4;
const u8 heat_add_blob = heat_add * 2;



class CMechDrill : CMechCore
{
	
	CMechDrill()
	{
		//lel
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		if(driver !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? driver.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyPressed(key_action2) :
							false;
			CBlob@ drill = blob.getAttachments().getAttachedBlob(attachedPoint);
			
			if(drill !is null)
			{
				//This doesnt seem to work properly for client :V
				//Fixed by setting SetMouseTaken to false on driver attachmentpoint
				float angle = (((driver.getAimPos() - drill.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
				if(angle >= 90 && angle < 270)// should just test for positive or negative X on difference vector but eh
				{
					drill.SetFacingLeft(true);
					angle += 180;
				}
				else
				{
					drill.SetFacingLeft(false);
				}
				drill.setAngleDegrees(angle);
				//printFloat("Angle: ", (driver.getAimPos() - driver.getPosition()).Angle());
			}
			
			if(actionkey && drill !is null)
			{
				//This code copy pasta'd from Drill.as
				//with some changes
				int gametime = getGameTime();
				const u8 delay_amount = drill.isInWater() ? 20 : 8;
				bool skip = ((gametime + drill.getNetworkID()) % delay_amount) != 0;

				if (skip) return;

				// delay drill
				{
					CSprite@ sprite = drill.getSprite();
					const bool facingleft = drill.isFacingLeft();
					Vec2f direction = Vec2f(1, 0).RotateBy(drill.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
					const f32 sign = (facingleft ? -1.0f : 1.0f);

					const f32 attack_distance = 6.0f;
					Vec2f attackVel = direction * attack_distance;

					const f32 distance = 40.0f;

					bool hitsomething = false;
					bool hitblob = false;
					
					int heat = blob.get_f32("heat");

					CMap@ map = getMap();
					if (map !is null)
					{
						HitInfo@[] hitInfos;
						if (map.getHitInfosFromArc((drill.getPosition() - attackVel), -attackVel.Angle(), 30, distance, drill, false, @hitInfos))
						{
							bool hit_ground = false;
							for (uint i = 0; i < hitInfos.length; i++)
							{
								f32 attack_dam = 1.0f;
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

									if (hi.blob.getTeamNum() == driver.getTeamNum() ||
											hit_ground && !is_ground)
									{
										continue;
									}

									//

									if (getNet().isServer())
									{
										// Deal extra damage if hot
										if (int(heat) > heat_max * 0.5f)
										{
											attack_dam += 1.0f;
										}

										drill.server_Hit(hi.blob, hi.hitpos, attackVel, attack_dam, Hitters::drill);

										// Yield half
										Material::fromBlob(blob, hi.blob, attack_dam * 1.0f);
									}

									hitsomething = true;
									hitblob = true;
								}
								else // map
								{
									if (map.getSectorAtPosition(hi.hitpos, "no build") !is null)
										continue;

									TileType tile = hi.tile;

									if (getNet().isServer())
									{
										map.server_DestroyTile(hi.hitpos, 1.0f, drill);
										map.server_DestroyTile(hi.hitpos, 1.0f, drill);

										Material::fromTile(blob, tile, 2.0f);
									}

									if (getNet().isClient())
									{
										if (map.isTileBedrock(tile))
										{
											sprite.PlaySound("/metal_stone.ogg");
											sparks(hi.hitpos, attackVel.Angle(), 1.0f);
										}
									}

									//only counts as hitting something if its not mats, so you can drill out veins quickly
									if (!map.isTileStone(tile) || !map.isTileGold(tile))
									{
										hitsomething = true;
										if (map.isTileCastle(tile) || map.isTileWood(tile))
										{
											hit_constructed = true;
										}
										else
										{
											hit_ground = true;
										}
									}

								}
								if (hitsomething)
								{
									if (hit_constructed)
									{
										heat += heat_add_constructed;
									}
									else if (hitblob)
									{
										heat += heat_add_blob;
									}
									else
									{
										heat += heat_add;
									}
									hitsomething = false;
									hitblob = false;
								}
							}
						}
					}
					blob.set_f32("heat", heat);
				}
			}
		}
	}
	
	void onTick(CSprite@ sprite, CBlob@ driver)
	{
	
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params)
	{
		return bits;
	}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		CMechCore::onAttach(blob, part);
	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{
	
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "BACK_ARM" || slot == "FRONT_ARM")
			return true;
		return false;
	}
	
	void onCreateInventoryMenu(CBlob@ blob, CBlob@ driver, CGridMenu @gridmenu)
	{
		//print("POTATE");
	}
}


void onInit(CBlob@ this)
{
	CMechDrill part();
	setMechPart(this, @part);
}

void onTick(CBlob@ this)
{
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
}

