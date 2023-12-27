


void onInit(CBlob@ this)
{
	this.getShape().getConsts().collideWhenAttached = false;
}

void onInit(CSprite@ this)
{
	this.SetFrame(3);
	this.SetOffset(Vec2f(0, 20));
	CSpriteLayer@ layer = this.addSpriteLayer("lower");
	layer.SetOffset(Vec2f(0, 40));
	layer.SetFrame(4);
}

void onTick(CSprite@ this)
{
	
}

void onTick(CMovement@ this)
{
	
}

void onTick(CBlob@ this)
{
	if(!this.isAttached())
		this.server_Die();
}

void onDie(CBlob@ this)
{
	float range = this.getShape().getConsts().radius;
	for (f32 count = 0.0f ; count < this.getInitialHealth(); count += 0.5f)
	{
		ParticleBloodSplat(Vec2f(XORRandom(range) - range / 2.0, XORRandom(range) - range / 2.0) + getRandomVelocity(0, 0.75f + 1.0 * 2.0f * XORRandom(2), 360.0f), false);
	}
}



