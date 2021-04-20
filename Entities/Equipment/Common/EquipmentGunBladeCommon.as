#include "EquipmentSwordCommon.as";
#include "EquipmentGunCommon.as";
#include "Hitters.as";


class CGunBladeEquipment : CSwordEquipment
{
	CGunEquipment@ gun;

	CGunBladeEquipment(float damage, float range, float speed, float knockback, bool jabonly, int jabtime, int slashtime, float lungespeed)
	{
		super(damage, range, speed, knockback, jabonly, jabtime, slashtime, lungespeed);

		@gun = @CGunEquipment(0.8, 40, 1, 1.5);
		gun.attachedPoint = 1;
		
		gun.recoil = 30;
		gun.movespeed = 0.8;
		gun.range = 512;
		gun.semi = true;
		//gun.reloadtime = reloadspeed;
		gun.maxammo = 8;
		//gun.hittype = magpart.hittype;
		//gun.ammotype = magpart.ammotype;
		//gun.tiledamagechance = corepart.tiledamagechance * Maths::Max(damage / corepart.damage, 0.5);
		//gun.tracercolor = magpart.tracercolor;
		//gun.texture = true;
		//gun.tracerwidth *= Maths::Max(damage / corepart.damage, 0.5);
		//gun.homingrange = homingrange;
		gun.blobpiercing = 2;
		//@gun.blobfx = @blobfx;
		//@gun.tilefx = @tilefx;
		gun.ammoguifile = "AmmoGUIHeavy.png";
		gun.ammoguisize = Vec2f(7, 14);									
	}

	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		Vec2f pos = user.getPosition();
		const bool myplayer = user.isMyPlayer();
		CSprite@ sprite = user.getSprite();
		keys usekey = attachedPoint == 0 ? key_action1 :
						attachedPoint == 1 ? key_action2 :
						key_action1;
						
		gun.onTick(blob, user);
						
		if(chargetime < 0)
		{
			if(speed + chargetime < 7)
				useWeapon(blob, user, true);
			chargetime++;
			return;
		}
		else if(chargetime == 0)
		{
			hitblobs.clear();
		}
		
		
		if(user.isKeyPressed(usekey) && chargetime == 0)
		{
			disabled = false;
			timetocharge = speed;
		}
		if(user.isKeyPressed(usekey) && !jabonly)
		{
			if(!disabled)
			{
				chargetime++;
			}
			if(usekey == key_action2)
			{
				if(user.isKeyJustPressed(key_action1))
				{
					chargetime = 0;
					disabled = true;
					if(sprite !is null)
						sprite.PlaySound("PopIn.ogg");
				}
			}
			else
			{
				if(user.isKeyJustPressed(key_action2))
				{
					chargetime = 0;
					disabled = true;
					if(sprite !is null)
						sprite.PlaySound("PopIn.ogg");
				}
			}
		}
		if((!jabonly && chargetime != 0 && user.isKeyJustReleased(usekey) && timetocharge != 0) || (jabonly && user.isKeyJustPressed(usekey)))
		{
			//if(user is getLocalPlayerBlob())
			//{
				useWeapon(blob, user);
			//}
			//chargetime = 0;
			
			if(sprite !is null && chargetime >= timetocharge)
			{
				Sound::Play("/ArgLong", user.getPosition());
				Sound::Play("/SwordSlash", user.getPosition());
			}
			else if(sprite !is null)
			{
				Sound::Play("/SwordSlash", user.getPosition());
			}
			timetocharge = 0;
		}
		if(chargetime == 1 && !jabonly)
		{
			//Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
		}
		if(chargetime == timetocharge && sprite !is null && chargetime != 0)
		{
			Sound::Play("SwordSheath.ogg", pos, myplayer ? 1.3f : 0.7f);
		}
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		if(bits == firecmdbits || bits == 0)
			return gun.onCommand(blob, user, bits, params);
		CBlob@ target = null; 
		uint16 blobid = 0;
		if(blob is null || user is null)
			return bits;
		if(EquipmentBitStreams::Nextu16 & bits == EquipmentBitStreams::Tu16)
		{
			blobid = params.read_u16();
			bits &= ~EquipmentBitStreams::Tu16;
			@target = getBlobByNetworkID(blobid); 
		}
		float damagetemp = 0;
		if(EquipmentBitStreams::Nextf32 & bits == EquipmentBitStreams::Tf32)
		{
			damagetemp = params.read_f32();
			bits &= ~EquipmentBitStreams::Tf32;
		}
		if(target is null)
			return bits;
		
		Vec2f normal = target.getPosition() - user.getPosition();
		normal.Normalize();
		
		if(target !is null)
		{
			user.server_Hit(target, target.getPosition(), normal, calcAllDamageMods(user, target, damagetemp, hittype), hittype, false);
			target.setVelocity(target.getVelocity() + normal * knockback);
		}
		return bits;
	}
	void onRender(CBlob@ blob, CBlob@ user)
	{
		gun.onRender(blob, user);
		if(user.isMyPlayer())
		{
			if (getHUD().hasButtons())
			{
				getHUD().SetDefaultCursor();
			}
			else
			{
				getHUD().SetCursorImage("Entities/Characters/Archer/ArcherCursor.png", Vec2f(32, 32));
				getHUD().SetCursorOffset(Vec2f(-32, -32));
				
				int frame = 0;
				if(jabonly)
				{
					float currcoolratio = float(Maths::Abs(chargetime)) / float(jabtime);
					if(chargetime < jabtime)
						frame = 1 + currcoolratio * 7;
					if(chargetime == jabtime)
						frame = 9;
					if(chargetime == 0)
						frame = 0;
				}
				else
				{
					if(chargetime > 0 && timetocharge != 0)
						frame = 1 + float(chargetime) / float(timetocharge) * 7;
					if(chargetime >= timetocharge)
						frame = 9;
					if(chargetime == 0)
						frame = 0;
				}
				getHUD().SetCursorFrame(frame);
			}
		}
	}
}
