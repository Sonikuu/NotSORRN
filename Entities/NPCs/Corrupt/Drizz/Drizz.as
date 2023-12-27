
#include "CHitters.as";

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	this.Tag("corrupt");
	this.addCommandID("spit");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	this.set_Vec2f("patrol", this.getPosition());

	
	

	CAttachment@ att = this.getAttachments();
	for(int i = 0; i < 8; i++)
	{
		AttachmentPoint@ point = att.AddAttachmentPoint("LEG" + i, true);
		point.offset = legmounts[i];
		point.radius = 24;
		point.controller = true;
	}
	initLegs(this);
}

void onInit(CSprite@ this)
{

	this.addSpriteLayer("bod");
	this.SetVisible(false);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(blob.getAngleDegrees() >= 90 && blob.getAngleDegrees() <= 270)
	{
		if(blob.isKeyPressed(key_left))
			this.getSpriteLayer("bod").SetFacingLeft(false);
		else if(blob.isKeyPressed(key_right))
			this.getSpriteLayer("bod").SetFacingLeft(true);
	}
	else
	{
		if(blob.isKeyPressed(key_left))
			this.getSpriteLayer("bod").SetFacingLeft(true);
		else if(blob.isKeyPressed(key_right))
			this.getSpriteLayer("bod").SetFacingLeft(false);
	}
}

//Leggies
array<Vec2f> legmounts = 
{
	Vec2f(-14, 4),
	Vec2f(-10, 5),
	Vec2f(-6, 7),
	Vec2f(-2, 8),
	Vec2f(2, 8),
	Vec2f(6, 7),
	Vec2f(10, 5),
	Vec2f(14, 4)
};

float legmaxlen = 64;

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	CShape@ shape = blob.getShape();
	
	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);
	
	Vec2f vel = blob.getVelocity();
	Vec2f pos = blob.getPosition();
	
	const bool isonground = blob.isOnGround();
	
	float firsttiley = 8;
	CMap@ map = getMap();
	
	bool hasattachleg = anyLegAttached(blob);

	if(hasattachleg)
		shape.SetGravityScale(0);
	else
		shape.SetGravityScale(1);

	if(hasattachleg)
	{
		if(up)
		{
			vel.y += -0.4;
		}
		if(down)
		{
			vel.y += 0.4;
		}
		if(left)
		{
			vel.x += -0.4;
		}
		if(right)
		{
			vel.x += 0.4;
		}
		vel *= 0.95;
	}
	blob.setVelocity(vel);

	for(int i = 0; i < 8; i++)
	{
		updateLeg(blob, i);
	}
	blob.setAngleDegrees(getAverageLegRot(blob) - 90);
	calcJointAngle(blob, 0);
	
}

void initLegs(CBlob@ blob)
{
	//CAttachment@ att = blob.getAttachments();
	for(int i = 0; i < 8; i++)
	{
		//AttachmentPoint@ point = att.AddAttachmentPoint("leg" + i, true);
		//point.offset = legmounts[i];
		//point.radius = 24;
		if(isServer())
		{
			CBlob@ b = server_CreateBlob("leg_spider");
			AttachmentPoint@ p = b.getAttachments().AddAttachmentPoint("LEG" + i, false);
			p.offset = Vec2f(0, 0);
			blob.server_AttachTo(b, "LEG" + i);
		}
	}
}

void updateLeg(CBlob@ blob, int i)
{
	CMap@ map = getMap();
	if(isLegAttached(blob, i))
	{
		if((getLegPos(blob, i) - (getLegMount(blob, i))).Length() > legmaxlen)
		{
			detachLeg(blob, i);
		}

	}
	float legdist = (getLegPos(blob, i) - getLegMount(blob, i)).Length();
	if(!isLegAttached(blob, i) || (legdist > legmaxlen / 2.0)) 
	{
		float castdir = legmounts[i].AngleDegrees() * -1;
		castdir += blob.getAngleDegrees();
		/*if(blob.isKeyPressed(key_up) && XORRandom(2) == 0)
			castdir *= -1;*/
		castdir += XORRandom(90) - 45;
		if(blob.isKeyPressed(key_right))
			castdir -= 45;
		if(blob.isKeyPressed(key_left))
			castdir += 45;

	

		Vec2f endcast = Vec2f_lengthdir_deg(legmaxlen, castdir) + getLegMount(blob, i);
		Vec2f rayout = Vec2f_zero;
		if(map.rayCastSolid(getLegMount(blob, i), endcast, rayout))
		{
			if(legdist > legmaxlen / 2.0)
			{
				if((rayout - getLegMount(blob, i)).Length() < legdist)
					attachLeg(blob, i, rayout);
			}
			else
			{
				attachLeg(blob, i, rayout);
			}
		}
	}


	if(!isLegAttached(blob, i))
		return;
	//Updating leg sprites
	CBlob@ leg = null;
	if(blob.getAttachments().getAttachmentPointByID(i) !is null)
		@leg = blob.getAttachments().getAttachmentPointByID(i).getOccupied();

	if(leg !is null)
	{	//Hell
		leg.setAngleRadians(getLegRotationOffset(blob, i) * -1 - blob.getAngleRadians() + calcJointAngle(blob, i) * (i >= 4 ? -1 : 1));

		if(isClient())
		{
			CSpriteLayer@ lower = leg.getSprite().getSpriteLayer("lower");
			lower.ResetTransform();
			lower.SetOffset(Vec2f(0, 0));
			
			lower.TranslateBy(Vec2f(0, 55));
			lower.RotateByRadians(calcJointAngle(blob, i) * 2 * (i >= 4 ? 1 : -1), Vec2f(0, 35));
		}
		
	}
	

}

void onRender(CSprite@ this)
{
	/*
	CBlob@ blob = this.getBlob();
	Driver@ driv = getDriver();
	for(int i = 0; i < 8; i++)
	{
		if(isLegAttached(blob, i))
		{
			Vec2f midpoint = Vec2f_lengthdir_rad(legmaxlen / 2.0, ((getLegPos(blob, i) - (getLegMount(blob, i))).getAngleRadians() * -1) + (calcJointAngle(blob, i) * (i >= 4 ? -1 : 1))) + (getLegMount(blob, i));
			GUI::DrawLine2D(driv.getScreenPosFromWorldPos(getLegMount(blob, i)), driv.getScreenPosFromWorldPos(midpoint), SColor(255, 100, 255, 100));
			GUI::DrawLine2D(driv.getScreenPosFromWorldPos(getLegPos(blob, i)), driv.getScreenPosFromWorldPos(midpoint), SColor(255, 100, 255, 100));
		}
		else 
			GUI::DrawLine2D(driv.getScreenPosFromWorldPos(getLegMount(blob, i)), driv.getScreenPosFromWorldPos(getLegPos(blob, i)), SColor(255, 255, 100, 100));


	}
	*/
}

float getLegRotationOffset(CBlob@ blob, int i)
{
	float rot = (getLegPos(blob, i) - getLegMount(blob, i)).getAngleRadians() + Maths::Pi / 2.0 - blob.getAngleRadians();
	//print("" + (getLegMount(blob, i) - getLegPos(blob, i)).getAngleRadians());
	//print("" + blob.getAngleRadians() * -1 );
	//print("" + rot);
	return rot;
}

bool isLegAttached(CBlob@ blob, int i)
{
	return blob.get_bool("legattached" + i);
}

Vec2f getLegPos(CBlob@ blob, int i)
{
	return blob.get_Vec2f("legattachedpos" + i);
}

Vec2f getLegMount(CBlob@ blob, int i)
{
	Vec2f tempvec = legmounts[i];
	return tempvec.RotateByDegrees(blob.getAngleDegrees()) + blob.getPosition();
}

void detachLeg(CBlob@ blob, int i)
{
	blob.set_bool("legattached" + i, false);
}
void attachLeg(CBlob@ blob, int i, Vec2f pos)
{
	blob.set_bool("legattached" + i, true);
	blob.set_Vec2f("legattachedpos" + i, pos);
}

bool anyLegAttached(CBlob@ blob)
{
	for(int i = 0; i < 8; i++)
	{
		if(isLegAttached(blob, i))
			return true;
	}
	return false;
}

float getAverageLegRot(CBlob@ blob)
{
	Vec2f posavg = Vec2f_zero;
	for(int i = 0; i < 8; i++)
	{
		if(isLegAttached(blob, i))
			posavg += getLegPos(blob, i) - blob.getPosition();
	}
	if(posavg == Vec2f_zero)
		return blob.getAngleDegrees() + 90;
	return posavg.getAngleDegrees() * -1;
}

void onTick(CBlob@ this)
{
	//if(this.getTickSinceCreated() == 1)
		//initLegs(this);
	if(getGameTime() % 30 == 0)
		this.server_Heal(0.25);


	if(this.getPlayer() !is null && this.getBrain() !is null)
		this.getBrain().server_SetActive(false);
	else if(this.getBrain() !is null)
		this.getBrain().server_SetActive(true);


	if(this.get_u16("ramcoold") != 0)
		this.sub_u16("ramcoold", 1);

	if(this.get_u8("ramtime") != 0)
		this.sub_u8("ramtime", 1);
	
	if(this.isKeyPressed(key_action1) && this.get_u16("ramcoold") == 0 && anyLegAttached(this))
	{
		this.set_u16("ramcoold", 30 * 1); //3 sec
		Vec2f norm = this.getAimPos() - this.getPosition();
		norm.Normalize();

		this.setVelocity(this.getVelocity() + norm * 10);

		this.set_u8("ramtime", 30);

		this.getShape().checkCollisionsAgain = true;
	}


	if(this.get_u8("spitcoold") != 0)
		this.sub_u8("spitcoold", 1);
	
	if(isServer() && this.isKeyPressed(key_action2) && this.get_u8("spitcoold") == 0)
	{
		this.set_u8("spitcoold", 15);
		CBlob@ b = server_CreateBlob("webshot", this.getTeamNum(), this.getPosition());
		Vec2f norm = this.getAimPos() - this.getPosition();
		norm.Normalize();
		b.setVelocity(norm * 8);
	}
}

void onDie(CBlob@ this)
{
	//Spurt blood or something lel
	if(isServer() && XORRandom(100) > 80)
	{
		CBlob@ blob = server_CreateBlobNoInit("mat_chitin");
		blob.setPosition(this.getPosition());
		blob.Tag("custom quantity");
		blob.server_SetQuantity(1);
		blob.Init();
	}


	float range = this.getShape().getConsts().radius;
	for (f32 count = 0.0f ; count < this.getInitialHealth(); count += 0.5f)
	{
		ParticleBloodSplat(Vec2f(XORRandom(range) - range / 2.0, XORRandom(range) - range / 2.0) + getRandomVelocity(0, 0.75f + 1.0 * 2.0f * XORRandom(2), 360.0f), false);
	}
}

float calcJointAngle(CBlob@ blob, int i)
{
	//Reverse kinematics time
	Vec2f startpoint = getLegMount(blob, i);
	Vec2f endpoint = getLegPos(blob, i);
	//a + b2 = maxleglen
	// ^ Nonsense
	float leglen = (startpoint - endpoint).Length();
	if(leglen == 0) return 0;
	//(b^2)*2 = maxleglen - leglen * leglen
	// ^ Thats the stuff
	//float result = Maths::Sqrt((legmaxlen) / 2.0) - Maths::Sqrt((leglen * leglen) / 2.0);
	/*print("Boof1: " + result);
	result /= 2;
	print("Boof2: " + result);
	result = Maths::Sqrt(Maths::Abs(result));//Side lengths
	print("Boof3: " + result);*/

	//Nvm its this simple
	float offsangle = Maths::ACos((leglen * leglen) / (2 * (legmaxlen / 2.0) * leglen));
	//print("Side length: " + leglen + " Angle: " + offsangle);
	if(offsangle >= 999999 || offsangle <= - 999999) return 0;
	return offsangle;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	bool output = true;
	if(blob.hasTag("flesh") && blob.getTeamNum() == this.getTeamNum())
		output = false;
	return output;
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	/*if(blob !is null && solid)
	{
		if(this.hasTag("attacking") && !this.hasTag("unprimed"))
		{
			Vec2f hitvel = blob.getPosition() - this.getPosition();
			hitvel.Normalize();
			//CBitStream params;
			//params.write_Vec2f(hitvel);
			//params.write_u16(blob.getNetworkID());
			//this.SendCommand(this.getCommandID("hitram"), params);
			
			this.server_Hit(blob, blob.getPosition(), hitvel, 0.25, CHitters::corrupt, false);
			blob.setVelocity(blob.getVelocity() + hitvel * 2.5);
			this.setVelocity(hitvel * -4);
			this.Untag("attacking");
		}
	}*/

	if(this.get_u8("ramtime") > 0 && this.getOldVelocity().Length() >= 0)
	{
		if(blob !is null)
			if(solid || blob.hasTag("flesh"))
				this.server_Hit(blob, (blob.getPosition() + this.getPosition()) / 2.0, this.getOldVelocity(), 3, 10);
			else
				return;
		else
		{
			Vec2f norm = this.getOldVelocity();
			norm.Normalize();
			Vec2f endpoint = norm * 16.0 + this.getPosition();

			CMap@ map = getMap();
			if(map !is null)
			{
				for(int x = -3; x <= 3; x++)
				{
					for(int y = -3; y <= 3; y++)
					{
						int count = XORRandom(3) + 1;
						for(int i = 0; i < count; i++)
							map.server_DestroyTile(endpoint + Vec2f(x, y) * 8, 1, this);
					}
				}
			}
		}
		Vec2f norm = this.getOldVelocity();
		norm.Normalize();
		norm *= -1;
		this.set_u8("ramtime", 0);
		this.setVelocity(this.getOldVelocity() + norm * 8);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == CHitters::pure)
		damage *= 4;
	return damage;
}





