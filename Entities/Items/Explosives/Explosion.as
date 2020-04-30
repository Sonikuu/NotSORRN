//Explode.as - Explosions

/**
 *
 * used mainly for void Explode ( CBlob@ this, f32 radius, f32 damage )
 *
 * the effect of the explosion can be customised with properties:
 *
 * f32 map_damage_radius        - the radius to damage the map in
 * f32 map_damage_ratio         - the ratio of part-damage to full-damage of the map
 *                                  0.0 is all part-damage, 1.0 is all full-damage
 * bool map_damage_raycast      - whether to damage through terrain, or just the surface blocks;
 *
 * string custom_explosion_sound - the sound played when the explosion happens
 *
 * u8 custom_hitter             - the hitter from Hitters.as to use
 */


#include "Hitters.as";
#include "ShieldCommon.as";
#include "SplashWater.as";
#include "ExplosionCommon.as";

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::bomb || customData == Hitters::water)
	{
		hitBlob.AddForce(velocity);
	}
}

/**
 * Perform a linear explosion (a-la bomberman if in the cardinal directions)
 */




