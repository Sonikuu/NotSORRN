#include "MechCommon.as";
#include "Hitters.as";

const int chargemax = 60;
const float distance = 48;

class CMechThumper : CMechCore
{
	int chargetime;
	CMechThumper()
	{
		chargetime = 0;
	}
	
	void onRender(CBlob@ blob, CBlob@ driver)
	{
		if(driver is getLocalPlayerBlob() && chargetime != 0)
		{
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			
			if(part !is null)
			{
				u32 color = 0xFFFFFFFF;
				
				float chargeratio = float(chargetime) / float(chargemax);
			
				color = (0xFF << 24) | (u32(0xFF - 0xFF * chargeratio) << 16) | (u32(0xFF * chargeratio) << 8);
				
				array<Vertex> vertlist(0);
				Vec2f pos = part.getPosition();
				pos.y -= 10;
				
				Vec2f barstart = pos;
				barstart.x -= 8;
				
				//Charge bar BG
				vertlist.push_back(Vertex(pos.x - 8, pos.y - 1, 0, 0, 0, 0xFF000000));
				vertlist.push_back(Vertex(pos.x + 8, pos.y - 1, 0, 1, 0, 0xFF000000));
				vertlist.push_back(Vertex(pos.x + 8, pos.y + 1, 0, 1, 1, 0xFF000000));
				vertlist.push_back(Vertex(pos.x - 8, pos.y + 1, 0, 0, 1, 0xFF000000));
				
				//Charge bar
				vertlist.push_back(Vertex(barstart.x, pos.y - 1, 30, 0, 0, color));
				vertlist.push_back(Vertex(barstart.x + 16 * chargeratio, pos.y - 1, 30, 1, 0, color));
				vertlist.push_back(Vertex(barstart.x + 16 * chargeratio, pos.y + 1, 30, 1, 1, color));
				vertlist.push_back(Vertex(barstart.x, pos.y + 1, 30, 0, 1, color));
				
				Render::RawQuads("PixelWhite.png", vertlist);
			}
		}
	}
	
	void onTick(CBlob@ blob, CBlob@ driver)
	{
		
		if(driver !is null)
		{
			bool actionkey = attachedPoint == "FRONT_ARM" ? driver.isKeyPressed(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyPressed(key_action2) :
							false;
			bool actionrelease = attachedPoint == "FRONT_ARM" ? driver.isKeyJustReleased(key_action1) :
							attachedPoint == "BACK_ARM" ? driver.isKeyJustReleased(key_action2) :
							false;
			CBlob@ part = blob.getAttachments().getAttachedBlob(attachedPoint);
			
			if(part !is null)
			{
				float angle = (((driver.getAimPos() - part.getPosition()).Angle() * -1 ) + 360.0) % 360.0;
				if(angle >= 90 && angle < 270)// should just test for positive or negative X on difference vector but eh
				{
					part.SetFacingLeft(true);
					angle += 180;
				}
				else
				{
					part.SetFacingLeft(false);
				}
				part.setAngleDegrees(angle);

				if(actionkey)
				{
					chargetime++;
					chargetime = Maths::Min(chargetime, chargemax);
					addHeat(blob, 0.5);//Fairly low heat, because not reallly a weapon
				}
				
				if(actionrelease)
				{
					CMap@ map = getMap();
					float chargeratio = float(chargetime) / float(chargemax);
					const bool facingleft = part.isFacingLeft();
					Vec2f direction = Vec2f(1, 0).RotateBy(part.getAngleDegrees() + (facingleft ? 180.0f : 0.0f));
					if (map !is null)
					{
						HitInfo@[] hitInfos;
						if (map.getHitInfosFromArc((part.getPosition()), -direction.Angle(), 30, distance, part, false, @hitInfos))
						{
							for (uint i = 0; i < hitInfos.length; i++)
							{
								HitInfo@ hi = hitInfos[i];
								if (hi.blob !is null) // blob
								{
									hi.blob.AddForce(direction * chargeratio * 10 * hi.blob.getMass());
								}
							}
						}
					}
					chargetime = 0;
				}
			}
		}
	}
	
	void onTick(CSprite@ sprite, CBlob@ driver)
	{
		CBlob@ part = sprite.getBlob().getAttachments().getAttachedBlob(attachedPoint);
		
		if(part !is null)
		{
			CSprite@ psprite = part.getSprite();
			if(psprite !is null)
			{
				float chargeratio = float(chargetime) / float(chargemax);
				CSpriteLayer@ layer = psprite.getSpriteLayer("head");
				layer.ResetTransform();
				layer.TranslateBy((Vec2f(-13, 0) + Vec2f(6, 0) * chargeratio) * (part.isFacingLeft() ? 1 : -1));
				layer.SetRelativeZ(-1);
			}
		}
	}
	
	u32 onCommand(CBlob@ blob, CBlob@ driver, u32 bits, CBitStream@ params)
	{
		return bits;
	}
	
	void onAttach(CBlob@ blob, CBlob@ part)
	{
		
	}
	
	void onDetach(CBlob@ blob, CBlob@ part)
	{
		
	}
	
	bool canBeEquipped(string slot)
	{
		if(slot == "FRONT_ARM" || slot == "BACK_ARM")
			return true;
		return false;
	}
}

void onInit(CBlob@ this)
{
	CMechThumper part();
	setMechPart(this, @part);
	
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ layer = this.addSpriteLayer("head");
	layer.SetFrame(1);
	layer.TranslateBy(Vec2f(13, 0));
	layer.SetRelativeZ(-1);
}

void onTick(CBlob@ this)
{

}

void onTick(CSprite@ this)
{
	
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
	if(blob.hasTag("flesh"))
		return false;
	return true;
}
