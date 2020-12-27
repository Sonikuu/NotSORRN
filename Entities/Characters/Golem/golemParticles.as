
void doParticleInit(CBlob@ this){
}

void doParticlesPassive(CBlob@ this){
	if(getGameTime() %2 != 0){
		return;
	}

	Vec2f particlePos = this.getPosition() + Vec2f(XORRandom(8) - 4, XORRandom(8) - 4) * 2;
	Vec2f thisPos = this.getPosition();
	Vec2f norm = (particlePos - thisPos);
	norm.Normalize();


	CParticle@ p = ParticleAnimated("lum.png",particlePos, Vec2f(XORRandom(10) - 5 * norm.x, XORRandom(10) - 10 *norm.y) / 60.0, 0, 1.0 / 16.0, 0, 0, Vec2f(64, 64), 1, -0.002, true);

	if(p !is null)
	{
		p.damping = 0.98;
		p.animated = 40;
		p.growth = -0.0005;
		p.colour = SColor(255,255,255,255);

		p.setRenderStyle(RenderStyle::light);

	}
}