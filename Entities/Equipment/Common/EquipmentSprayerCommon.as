#include "EquipmentCore.as";
#include "Hitters.as";
#include "MaterialCommon.as";
#include "ParticleSparks.as";
#include "AlchemyCommon.as";

const u32 sprayersyncbits = EquipmentBitStreams::Tu32;

class CSprayerEquipment : CEquipmentCore
{
	
	float power;
	float drain;
	float draindec;
	float range;
	float spread;
	
	float angle;
	
	float lastshotrotation;
	bool fixedsprite;
	float kick;
	
	//Vec2f spriteoffset;
	//float tracerwidth;
	//SColor tracercolor;
	
	CSprayerEquipment(float power, float drain, float spread, float range)
	{
		super();
		this.drain = drain;
		this.power = power;
		this.range = range;
		this.spread = spread;
		
		lastshotrotation = 0;
		fixedsprite = false;
		
		//spriteoffset = Vec2f_zero;
		
		kick = 0;
		draindec = 0;
	}
	
	void onRender(CBlob@ blob, CBlob@ user)
	{
		GUI::SetFont("snes");
		CControls@ controls = getControls();
		if(user is getLocalPlayerBlob() && controls !is null)
			renderElementsRight(getTank(blob, 0).storage.elements, controls.getMouseScreenPos());
	}
	
	void onTick(CBlob@ blob, CBlob@ user)
	{
		
		
		if(user !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1);

			if(blob !is null)
			{
				angle = (((user.getAimPos() - user.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
				
				if(actionkey && blob !is null)
					fireWeapon(blob, user);
			}
		}
	}
	
	void fireWeapon(CBlob@ blob, CBlob@ user)
	{
		lastshotrotation = angle;
		fixedsprite = false;
		//if(this.get_bool("active"))
		{
			CAlchemyTank@ tank = getTank(blob, 0);
			if(tank is null)
				return;
			for (int i = 0; i < elementlist.length; i++)
			{
				if(tank.storage.elements[i] >= drain && tank.storage.elements[i] != 0)
				{
					float minout = blob.get_f32("leftovers");
					minout += elementlist[i].spraybehavior(power, angle, spread, range, blob, user);
					
					//draindec += drain;
					
					//if(draindec >= 1.0)
					{
						tank.storage.elements[i] -= int(minout);
						blob.set_f32("leftovers", minout - int(minout));
					}
					break;
				}
			}
		}
	/*
		CBitStream params;

		params.write_u32(firecmdbits);
		
		params.write_u32(seed);
		
		blob.SendCommand(blob.getCommandID("partcmd"), params);
		
		cooldown = firerate;*/
	}
	
	void onTick(CSprite@ sprite, CBlob@ user)
	{
		bool actionkey = attachedPoint == "FRONT_ARM" ? user.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? user.isKeyPressed(key_action2) :
							user.isKeyPressed(key_action1);
	
	
		if(!actionkey)
		{
			CSprite@ usersprite = user.getSprite();
			if(usersprite !is null && usersprite.getSpriteLayer("equipgunfx") !is null)
			{
				usersprite.RemoveSpriteLayer("equipgunfx");
			}
		}
		else
		{
			CSprite@ usersprite = user.getSprite();
			if(usersprite !is null && usersprite.getSpriteLayer("equipgunfx") is null)
			{
				CSpriteLayer@ layer = usersprite.addSpriteLayer("equipgunfx", sprite.getFilename(), sprite.getFrameWidth(), sprite.getFrameHeight());
				layer.TranslateBy(spriteoffset);
				layer.ScaleBy(Vec2f(1, 1) * spritescale);
				
				
				layer.SetIgnoreParentFacing(true);
				if(lastshotrotation >= 90 && lastshotrotation < 270)
				{
					layer.SetFacingLeft(true);
					lastshotrotation += 180;
				}
				else
				{
					layer.SetFacingLeft(false);
				}
				layer.RotateBy(lastshotrotation, Vec2f_zero);
				layer.SetRelativeZ(5);
				fixedsprite = true;
			}
			else if(!fixedsprite)
			{
				CSpriteLayer@ layer = usersprite.getSpriteLayer("equipgunfx");
				layer.ResetTransform();
				//layer.ScaleBy(Vec2f(0.5, 0.5));
				
				layer.TranslateBy(spriteoffset);
				
				if(lastshotrotation >= 90 && lastshotrotation < 270)
				{
					layer.SetFacingLeft(true);
					lastshotrotation += 180;
				}
				else
				{
					layer.SetFacingLeft(false);
				}
				layer.RotateBy(lastshotrotation, Vec2f_zero);
				
				u8 spoolframes = sprite.getBlob().get_u8("spoolframecount");
				if(spoolframes > 0)
				{
					layer.SetFrame(1 + (getGameTime() / 2) % spoolframes);
				}
				fixedsprite = true;
			}
			
		}
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ user, u32 bits, CBitStream@ params)
	{
		if(bits == sprayersyncbits && user !is null)
		{

			bits &= ~sprayersyncbits;
			u32 tank = params.read_u32();
			
		}
		return bits;
	}
	
	void onEquip(CBlob@ blob, CBlob@ user)
	{
		//CMechCore::onAttach(blob, user);
	}
	
	void onUnequip(CBlob@ blob, CBlob@ user)
	{		
		if(user is null) return;
		
		CSprite@ usersprite = user.getSprite();
		if(usersprite !is null && usersprite.getSpriteLayer("equipgunfx") !is null)
		{
			usersprite.RemoveSpriteLayer("equipgunfx");
		}
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "BACK_ARM" || slot == "FRONT_ARM")
			return true;
		return false;
	}
}