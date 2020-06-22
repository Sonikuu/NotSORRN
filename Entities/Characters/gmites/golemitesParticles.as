
void onInit(CBlob@ this)
{

}

void onTick(CBlob@ this)
{
    Vec2f Pos = this.getPosition();

	f32 golemiteCount = this.get_s32("golemiteCount");
	f32 maxGolemites = this.get_s32("golemiteMax");
	f32 percent = golemiteCount/maxGolemites;

    CParticle@[] particleList;
	this.get("ParticleList",particleList);
	for(int a = 1; a < 6 * percent + 3; a++)
	{	
		SColor color;
		u8 rnd = XORRandom(3);
		switch(rnd)
		{
			case 0:
				color = SColor(255,127,63,40);
			break;
			case 1:
				color = SColor(255,63,30,20);
			break;
			case 2:
				color = SColor(255,151,167,146);
			break;
		}
		CParticle@ p = ParticlePixelUnlimited(-getRandomVelocity(0,10,360) + Pos,getRandomVelocity(0,10,360) + this.getVelocity(),color ,true);
		if(p !is null)
		{
			p.fastcollision = true;
			p.gravity = Vec2f(0,0);
			p.bounce = 1;
			p.lighting = false;
			p.timeout = 90;
            p.damping = 0.75;

			particleList.push_back(p);
		}
	}

	for(int a = 0; a < particleList.size(); a++)
	{
        if(a < particleList.size() - 1)
        {
            particleList[a].position = Vec2f_lerp(particleList[a].position, particleList[a + 1].position, 0.25);
        }

		CParticle@ particle = particleList[a];
		//check
		if(particle.timeout < 1)
		{
			particleList.erase(a);
			a--;
			continue;
		}

		//Gravity
		Vec2f tempGrav = Vec2f(0,0);
		tempGrav.x = -(particle.position.x - Pos.x);
		tempGrav.y = -(particle.position.y - Pos.y);


		//set stuff
		particle.gravity = tempGrav / 10;
        particle.velocity += this.getVelocity() /4;
	}

	this.set("ParticleList",particleList);
}