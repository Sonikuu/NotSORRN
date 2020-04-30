

void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	string texname = this.getTextureName();
	
	ImageData@ data = Texture::data(texname);
	if(data is null)
	{
		Texture::createFromFile(blob.getConfig() + "d", this.getFilename());
		texname = blob.getConfig() + "d";
		@data = Texture::data(texname);
		
		//Still null? might as well die
		if(data is null)
		{
			print("ANGERY in Disintegrate.as");
			return;
		}
	}
	//Texture::createFromCopy(texname + "d", texname);
	
	Texture::createFromData(texname + "d", data);
	this.SetTexture(texname + "d"/*, this.getFrameWidth(), this.getFrameHeight()*/);
	//array<array<int>> imagesize(data.width())(data.height());
	//blob.set("disintegration", @imagesize);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	//array<array<int>>@ imagesize;
	//blob.get("disintegration", @imagesize);
	string texname = this.getTextureName();
	ImageData@ data = Texture::data(texname);
	if(data is null)
		return;
	for(int i = 0; i < 10; i++)
	{
		int framesx = data.width() / this.getFrameWidth();
		Vec2f spritepos = Vec2f((this.getFrame() % framesx) * this.getFrameWidth(), Maths::Floor(this.getFrame() / float(framesx)) * this.getFrameHeight());
		Vec2f pos(XORRandom(this.getFrameWidth()), XORRandom(this.getFrameHeight()));
		
		Vec2f actualpos = spritepos + pos;
		
		Vec2f halfsize(this.getFrameWidth() / 2, this.getFrameHeight() / 2);
		if(data.get(actualpos.x, actualpos.y).getAlpha() == 0)
			continue;
		CParticle@ particle = ParticlePixel(blob.getPosition() + (pos - halfsize), Vec2f(-0.2, -0.1), data.get(actualpos.x, actualpos.y), false);
		if(particle !is null)
		{
			particle.gravity =  Vec2f_zero;
		}
		data.put(actualpos.x, actualpos.y, SColor(0, 0, 0, 0));
	}
	Texture::update(texname, data);
}





















