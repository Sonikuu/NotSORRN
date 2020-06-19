
//

#include "WorldRenderCommon.as";


//float spritesize = 8.0;
//ImageData@ spriteimage = Texture::data("WeaponProjectile.png");


/*{
	shared ImageData@ spriteimage = Texture::data("WeaponProjectile.png");
	spriteindx = spritesize / spriteimage.width();
	spriteindy = spritesize / spriteimage.height();
}*/

shared interface IRenderParticleCore
{
	bool onTick();//Returns false if projectile needs to die
	void appendVerts(array<Vertex>@ verts);
}

shared class CRenderParticleBase : IRenderParticleCore
{
	float scale;
	bool collides;
	bool dieoncollide;
	int timelimit;
	float gravity;

	bool rotates;
	SColor color;
	
	Vec2f position;
	Vec2f velocity;
	
	int deathtime;
	
	Random@ random;
	
	bool updatedeath;

	
	CRenderParticleBase(float scale, bool collides, bool dieoncollide, int timelimit, float gravity, SColor color, bool rotates, u32 randoseed)
	{
		this.scale = scale;
		this.collides = collides;
		this.dieoncollide = dieoncollide;
		this.timelimit = timelimit;
		this.gravity = gravity;
		this.color = color;
		this.rotates = rotates;
		@random = @Random(randoseed);
		
		deathtime = 0;
		updatedeath = false;
	}
	
	bool onTick()
	{
		if(deathtime > 0)
		{
			if(updatedeath)
			{
				velocity.y += gravity;
				position += velocity;
			}
			deathtime--;
			color.setAlpha(Maths::Max(color.getAlpha() - 30, 0));
			if(deathtime == 0)
				return false;
			return true;
		}
		CMap@ map = getMap();
		velocity.y += gravity;
		position += velocity;

		
		if(collides)
		{
			if(dieoncollide)
			{
				if(map.isTileSolid(position))
				{
					startDeath();
					return true;
				}
			}
			else
			{
				if(map.isTileSolid(position))
				{
					position.x -= velocity.x;
					velocity.x *= -0.75;
					return true;
				}
				if(map.isTileSolid(position + Vec2f(0, scale * 8)))
				{
					position.y = (Maths::Floor((position.y + scale * 8) / 8) * 8) - scale * 8;
					velocity.y = 0;
				}
			}
		}
		timelimit--;
		if(timelimit < 0)
			startDeath();
		return true;
	}
	
	//Append is the right word riighhttt?
	void appendVerts(array<Vertex>@ verts)
	{
		/*//Update these two manually if sprite size changes
		//...
		float spriteindx = 16.0 / 16.0;
		float spriteindy = 16.0 / 320.0;
		
		Vec2f tempvel = velocity;
		tempvel.y += gravity * getInterpolationFactor();
		
		Vec2f temppos = deathtime > 0 ? position : position + velocity * getInterpolationFactor();
		
		float rotation = rotates ? (tempvel.getAngle() / 180.0) * Maths::Pi : Maths::Pi / 2;
		rotation *= -1;
		rotation -= Maths::Pi / 4;
		//ul, ur, lr, and ll mean this
		//Upper left
		//Upper right
		//Lower right
		//Lower left
		//Makes this easier
		Vec2f sul = getSpritePointFromIndex(sprite);
		Vec2f sur = sul + Vec2f(spriteindx, 0);
		Vec2f slr = sul + Vec2f(spriteindx, spriteindy);
		Vec2f sll = sul + Vec2f(0, spriteindy);
		
		CMap@ map = getMap();
		SColor maplight = map.getColorLight((deathtime > 0 ? temppos - velocity : temppos));
		
		u32 colorint = (color.getAlpha() << 24) + ((color.getRed() * maplight.getRed()) / 255 << 16) + ((color.getGreen() * maplight.getGreen()) / 255 << 8) + ((color.getBlue() * maplight.getBlue()) / 255);
		
		Vec2f ul = Vec2f(temppos.x + Maths::Cos(rotation) * scale * 12, temppos.y + Maths::Sin(rotation) * scale * 12);
		rotation += Maths::Pi / 2;
		Vec2f ur = Vec2f(temppos.x + Maths::Cos(rotation) * scale * 12, temppos.y + Maths::Sin(rotation) * scale * 12);
		rotation += Maths::Pi / 2;
		Vec2f lr = Vec2f(temppos.x + Maths::Cos(rotation) * scale * 12, temppos.y + Maths::Sin(rotation) * scale * 12);
		rotation += Maths::Pi / 2;
		Vec2f ll = Vec2f(temppos.x + Maths::Cos(rotation) * scale * 12, temppos.y + Maths::Sin(rotation) * scale * 12);
		
		verts.push_back(Vertex(ul, 0, sul, colorint));
		verts.push_back(Vertex(ur, 0, sur, colorint));
		verts.push_back(Vertex(lr, 0, slr, colorint));
		verts.push_back(Vertex(ll, 0, sll, colorint));*/
	}
	
	void startDeath()
	{
		deathtime = 10;
	}
}

shared class CRenderParticleArrow : CRenderParticleBase
{
	CRenderParticleArrow(float scale, bool collides, bool dieoncollide, int timelimit, float gravity, SColor color, bool rotates, u32 randoseed)
	{
		super(scale, collides, dieoncollide, timelimit, gravity, color, rotates, randoseed);
		updatedeath = true;
	}

	void appendVerts(array<Vertex>@ verts)
	{
		Vec2f tempvel = velocity;
		tempvel.y += gravity * getInterpolationFactor();
		
		Vec2f temppos = deathtime > 0 ? position : position + velocity * getInterpolationFactor();
		
		float rotation = rotates ? (tempvel.getAngle() / 180.0) * Maths::Pi : Maths::Pi / 2;
		rotation *= -1;
		rotation -= Maths::Pi / 4;
		float rotdeg = (tempvel.getAngle() - 90) * -1;
		//ul, ur, lr, and ll mean this
		//Upper left
		//Upper right
		//Lower right
		//Lower left
		//Makes this easier
		Vec2f sul(0, 0);
		Vec2f sur(1, 0);
		Vec2f slr(1, 1);
		Vec2f sll(0, 1);
		
		
		CMap@ map = getMap();
		SColor maplight = map.getColorLight((deathtime > 0 ? temppos - velocity : temppos));
		
		u32 colorint = (color.getAlpha() << 24) + ((color.getRed() * maplight.getRed()) / 255 << 16) + ((color.getGreen() * maplight.getGreen()) / 255 << 8) + ((color.getBlue() * maplight.getBlue()) / 255);
		
		Vec2f ul = Vec2f(0, scale * -0.125 * velocity.Length()).RotateBy(rotdeg);
		ul += temppos;
		
		Vec2f ur = Vec2f(2 * scale, scale * 0.25 * velocity.Length()).RotateBy(rotdeg);
		ur += temppos;
		
		Vec2f lr = Vec2f(0, 0).RotateBy(rotdeg);
		lr += temppos;
		
		Vec2f ll = Vec2f(-2 * scale, scale * 0.25 * velocity.Length()).RotateBy(rotdeg);
		ll += temppos;
		
		verts.push_back(Vertex(ul, 0, sul, colorint));
		verts.push_back(Vertex(ur, 0, sur, colorint));
		verts.push_back(Vertex(lr, 0, slr, colorint));
		verts.push_back(Vertex(ll, 0, sll, colorint));
	}
}

shared class CRenderParticleBlazing : CRenderParticleBase
{
	Vec2f topos;
	array<Vec2f> partposes;
	array<Vec2f> partvel;
	array<int> parttimes;
	CRenderParticleBlazing(float scale, bool collides, bool dieoncollide, int timelimit, float gravity, SColor color, bool rotates, u32 randoseed)
	{
		super(scale, collides, dieoncollide, timelimit, gravity, color, rotates, randoseed);
		updatedeath = true;
		topos = Vec2f_zero;
	}

	bool onTick()
	{
		if(deathtime > 0)
		{
			//if(updatedeath)
			{
			//	velocity.y += gravity;
			//	position += velocity;
			}
			deathtime--;
			//color.setAlpha(Maths::Max(color.getAlpha() - 30, 0));
			if(deathtime == 0)
				return false;
			//return true;
		}
		else
		{
			velocity = Vec2f_lengthdir(2, (topos - position).Angle() * -1);
			position += velocity;
			if((position - topos).Length() < 4)
				startDeath();

			//if(XORRandom(2) == 0)
			{
				partposes.push_back(position + Vec2f(XORRandom(10) - 5, XORRandom(10) - 5) / 3.0);
				parttimes.push_back(15 + XORRandom(15));
				partvel.push_back(Vec2f(XORRandom(100) - 50, XORRandom(100) - 50) / 500.0);
			}
		}

		for(int i = 0; i < parttimes.length; i++)
		{
			parttimes[i]--;
			partposes[i] += partvel[i];
			if(parttimes[i] == 0)
			{
				parttimes.removeAt(i);
				partposes.removeAt(i);
				partvel.removeAt(i);
				i--;
			}
		}

		if(deathtime <= 0)
		{
			timelimit--;
			if(timelimit < 0)
				startDeath();
		}
		return true;
	}

	void startDeath()
	{
		for(int i = 0; i < 16; i++)
		{
			partposes.push_back(position + Vec2f(XORRandom(10) - 5, XORRandom(10) - 5) / 3.0);
			parttimes.push_back(15 + XORRandom(15));
			partvel.push_back(Vec2f(XORRandom(100) - 50, XORRandom(100) - 50) / 150.0);
		}
		deathtime = 30;
	}

	void appendVerts(array<Vertex>@ verts)
	{
		//Vec2f tempvel = velocity;
		//tempvel.y += gravity * getInterpolationFactor();
		
		//Vec2f temppos = deathtime > 0 ? position : position + velocity * getInterpolationFactor();
		
		//float rotation = rotates ? (tempvel.getAngle() / 180.0) * Maths::Pi : Maths::Pi / 2;
		//rotation *= -1;
		//rotation -= Maths::Pi / 4;
		//float rotdeg = (tempvel.getAngle() - 90) * -1;
		//ul, ur, lr, and ll mean this
		//Upper left
		//Upper right
		//Lower right
		//Lower left
		//Makes this easier
		Vec2f sul(0, 0);
		Vec2f sur(1, 0);
		Vec2f slr(1, 1);
		Vec2f sll(0, 1);

		for(int i = 0; i < partposes.length; i++)
		{
			Vec2f temppos = partposes[i];
			Vec2f ul = Vec2f(-scale, -scale);
			ul += temppos;
			
			Vec2f ur = Vec2f(scale, -scale);
			ur += temppos;
			
			Vec2f lr = Vec2f(scale, scale);
			lr += temppos;
			
			Vec2f ll = Vec2f(-scale, scale);
			ll += temppos;

			verts.push_back(Vertex(ul, 0, sul, color));
			verts.push_back(Vertex(ur, 0, sur, color));
			verts.push_back(Vertex(lr, 0, slr, color));
			verts.push_back(Vertex(ll, 0, sll, color));
		}
		
		
		//CMap@ map = getMap();
		//SColor maplight = map.getColorLight((deathtime > 0 ? temppos - velocity : temppos));
		
		//u32 colorint = (color.getAlpha() << 24) + ((color.getRed() * maplight.getRed()) / 255 << 16) + ((color.getGreen() * maplight.getGreen()) / 255 << 8) + ((color.getBlue() * maplight.getBlue()) / 255);
		
		/*Vec2f ul = Vec2f(0, scale * -0.125 * velocity.Length()).RotateBy(rotdeg);
		ul += temppos;
		
		Vec2f ur = Vec2f(2 * scale, scale * 0.25 * velocity.Length()).RotateBy(rotdeg);
		ur += temppos;
		
		Vec2f lr = Vec2f(0, 0).RotateBy(rotdeg);
		lr += temppos;
		
		Vec2f ll = Vec2f(-2 * scale, scale * 0.25 * velocity.Length()).RotateBy(rotdeg);
		ll += temppos;
		
		verts.push_back(Vertex(ul, 0, sul, colorint));
		verts.push_back(Vertex(ur, 0, sur, colorint));
		verts.push_back(Vertex(lr, 0, slr, colorint));
		verts.push_back(Vertex(ll, 0, sll, colorint));*/
	}
}

shared class CRenderParticleDrop : CRenderParticleBase
{
	Vec2f ul;
	Vec2f ur;
	Vec2f lr;
	Vec2f ll;
	
	Vertex vul;
	Vertex vur;
	Vertex vlr;
	Vertex vll;
	
	Vec2f lastpos;
	
	bool defvert;
	int dieat;
	
	array<int>@ heightdata;

	CRenderParticleDrop(float scale, bool collides, bool dieoncollide, int timelimit, float gravity, SColor color, bool rotates, u32 randoseed)
	{
		super(scale, collides, dieoncollide, timelimit, gravity, color, rotates, randoseed);
		updatedeath = true;
		defvert = false;
		lastpos = Vec2f_zero;
	}
	
	bool onTick()
	{
		if(deathtime > 0)
		{
			deathtime--;
			if(deathtime == 0)
			{
				//if(XORRandom(3) == 0)
					//ParticlePixel(position + Vec2f(XORRandom(5) - 2, XORRandom(5) - 2), Vec2f(XORRandom(16) - 8, XORRandom(16) - 16) / 16.0, color, false, 5);
				return false;
			}
			return true;
		}
	
		CMap@ map = getMap();
		//velocity.y += gravity;
		position += velocity;

		
	//	if(collides)
		{
			//if(dieoncollide)
			{
				if(heightdata is null || position.x < 0 || position.x / 8 > heightdata.size() - 1 || (position.y + velocity.y) / 8 > heightdata[position.x / 8])
				{
					startDeath();
					return true;
				}
			}
		}
		timelimit--;
		if(timelimit < 0)
			startDeath();
		return true;
	}

	void appendVerts(array<Vertex>@ verts)
	{
		CCamera@ cam = getCamera();
		Vec2f campos = cam.getPosition();
		//if(XORRandom(100) == 0) print("" + (cam.getPosition().y - getScreenHeight() / 4.0 / cam.targetDistance) + ":" + (cam.getPosition().y + getScreenHeight() / 4.0 / cam.targetDistance));
		if(campos.y - getScreenHeight() / 4.0 / cam.targetDistance > position.y || campos.y + getScreenHeight() / 4.0 / cam.targetDistance < position.y ||
		campos.x - getScreenWidth() / 4.0 / cam.targetDistance > position.x || campos.x + getScreenWidth() / 4.0 / cam.targetDistance < position.x)
			return;
		Vec2f temppos = deathtime > 0 ? position : position + velocity * getInterpolationFactor();
		if(lastpos == Vec2f_zero)
			lastpos = temppos;
			
		Vec2f diffpos = temppos - lastpos;
		lastpos = temppos;
		//ul, ur, lr, and ll mean this
		//Upper left
		//Upper right
		//Lower right
		//Lower left
		//Makes this easier
		Vec2f sul(0, 0);
		Vec2f sur(1, 0);
		Vec2f slr(1, 1);
		Vec2f sll(0, 1);
		
		if(!defvert)
		{
			vul.x = position.x + ul.x;
			vul.y = position.y + ul.y;
			vur.x = position.x + ur.x;
			vur.y = position.y + ur.y;
			vlr.x = position.x + lr.x;
			vlr.y = position.y + lr.y;
			vll.x = position.x + ll.x;
			vll.y = position.y + ll.y;
			defvert = true;
		}
		else
		{
			float dvelx = diffpos.x;
			float dvely = diffpos.y;
			vul.x += dvelx;
			vul.y += dvely;
			vur.x += dvelx;
			vur.y += dvely;
			vlr.x += dvelx;
			vlr.y += dvely;
			vll.x += dvelx;
			vll.y += dvely;
		}
		
		CMap@ map = getMap();
		SColor maplight = map.getColorLight((deathtime > 0 ? temppos - velocity : temppos));
		
		//u32 colorint = (color.getAlpha() << 24) + ((color.getRed() * maplight.getRed()) / 255 << 16) + ((color.getGreen() * maplight.getGreen()) / 255 << 8) + ((color.getBlue() * maplight.getBlue()) / 255);\
		
		SColor resc = color;
		vul.col = resc;
		vur.col = resc;
		vlr.col = resc;
		vll.col = resc;
		
		verts.push_back(vul);
		verts.push_back(vur);
		verts.push_back(vlr);
		verts.push_back(vll);
	}
	
	void startDeath()
	{
		deathtime = 1;
	}
}

shared class CRenderParticleString : CRenderParticleBase
{

	int length;
	array<Vec2f>@ lochist;
	array<float>@ rothist;
	CRenderParticleString(float scale, bool collides, bool dieoncollide, int timelimit, float gravity, SColor color, bool rotates, u32 randoseed, int length)
	{
		super(scale, collides, dieoncollide, timelimit, gravity, color, rotates, randoseed);
		this.length = length;
		@lochist = @array<Vec2f>(length);
		@rothist = @array<float>(length);
	}
	
	bool onTick()
	{
		if(lochist.size() > 0)
		{
			lochist.removeAt(0);
			rothist.removeAt(0);
		}
		
		if(deathtime <= 0)
		{
			lochist.insertLast(position);
			rothist.insertLast(velocity.Angle());
		}
		
		return CRenderParticleBase::onTick();
	}

	void appendVerts(array<Vertex>@ verts)
	{	
		for(int i = 0; i < lochist.size() - 1; i++)
		{
			if(lochist[i] == Vec2f_zero)
				continue;
			float width = Maths::Cos((((float(i) + getInterpolationFactor()) / float(lochist.size())) * Maths::Pi) + Maths::Pi / 2) * scale;
			float widthl = Maths::Cos((((float(i + 1) + getInterpolationFactor()) / float(lochist.size())) * Maths::Pi) + Maths::Pi / 2) * scale;
			
			Vec2f temppos = lochist[i];
			Vec2f tempposl = lochist[i + 1];
			
			float rotdeg = (rothist[i] - 90) * -1;
			float rotdegl = (rothist[i + 1] - 90) * -1;
			//ul, ur, lr, and ll mean this
			//Upper left
			//Upper right
			//Lower right
			//Lower left
			//Makes this easier
			Vec2f sul(0, 0);
			Vec2f sur(1, 0);
			Vec2f slr(1, 1);
			Vec2f sll(0, 1);
			
			
			CMap@ map = getMap();
			SColor maplight = map.getColorLight((deathtime > 0 ? temppos - velocity : temppos));
			
			u32 colorint = (color.getAlpha() << 24) + ((color.getRed() * maplight.getRed()) / 255 << 16) + ((color.getGreen() * maplight.getGreen()) / 255 << 8) + ((color.getBlue() * maplight.getBlue()) / 255);
			
			Vec2f ul = Vec2f(-width, 0).RotateBy(rotdeg);
			ul += temppos;
			
			Vec2f ur = Vec2f(width, 0).RotateBy(rotdeg);
			ur += temppos;
			
			Vec2f lr = Vec2f(widthl, 0).RotateBy(rotdegl);
			lr += tempposl;
			
			Vec2f ll = Vec2f(-widthl, 0).RotateBy(rotdegl);
			ll += tempposl;
			
			verts.push_back(Vertex(ul, 0, sul, colorint));
			verts.push_back(Vertex(ur, 0, sur, colorint));
			verts.push_back(Vertex(lr, 0, slr, colorint));
			verts.push_back(Vertex(ll, 0, sll, colorint));
		}
	}
}

shared Vec2f getSpritePointFromIndex(int index)
{
	float spriteindx = 16.0 / 16.0;
	float spriteindy = 16.0 / 320.0;
	return Vec2f(0, index * spriteindy);
}

shared void addParticleToList(IRenderParticleCore@ proj)
{
	array<IRenderParticleCore@>@ list;
	CRules@ rules = getRules();
	rules.get("PRlist", @list);
	list.insertLast(@proj);
}




