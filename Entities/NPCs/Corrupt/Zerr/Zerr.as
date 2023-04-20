
#include "CHitters.as";

void onInit(CBlob@ this)
{
	this.Tag("flesh");
	this.Tag("corrupt");
	this.addCommandID("spit");
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	this.set_Vec2f("patrol", this.getPosition());
}

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
	bool loopsie = true;
	while (loopsie)
	{
		if(map.isTileSolid(Vec2f(0, firsttiley) + pos) || firsttiley + pos.y > map.tilesize * map.tilemapheight)
			loopsie = false;
		else
			firsttiley += map.tilesize;
	}
	if(up)
	{
		vel.y += Maths::Max(-30.0 / firsttiley, -0.9);
	}
	if(left)
	{
		if(!down)
			vel.x += -0.14;
		else
			vel.x += -0.07;
	}
	if(right)
	{
		if(!down)
			vel.x += 0.14;
		else
			vel.x += 0.07;
	}
	blob.setVelocity(vel);
}

void onTick(CBlob@ this)
{
	if(this.getPlayer() !is null && this.getBrain() !is null)
		this.getBrain().server_SetActive(false);
	else if(this.getBrain() !is null)
		this.getBrain().server_SetActive(true);

	if(this.isKeyPressed(key_left))
		this.SetFacingLeft(true);
	else if(this.isKeyPressed(key_right))
		this.SetFacingLeft(false);
	if(this.get_u8("spitcoold") != 0)
		this.sub_u8("spitcoold", 1);
	
	if(isServer() && this.isKeyJustPressed(key_action2) && this.get_u8("spitcoold") == 0)
	{
		this.set_u8("spitcoold", 60);
		CBlob@ b = server_CreateBlob("spit", this.getTeamNum(), this.getPosition());
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
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if(customData == CHitters::pure)
		damage *= 4;
	return damage;
}





