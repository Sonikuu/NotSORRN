
void onInit(CBlob@ this)
{
	this.set_Vec2f("lastaim",this.getAimPos());
	this.set_Vec2f("startaim",Vec2f_zero);
	this.set_bool("newlineready",true);

	Vec2f[] lines;
	this.set("lines",@lines);
}

void onReload( CBlob@ this )
{
	Vec2f[] lines;
	this.set("lines",@lines);
}


void onTick(CBlob@ this)
{
	Vec2f[]@ lines;
	this.get("lines",@lines);

	CControls@ c = getControls();

	CBlob@ holder = getHolder(this);
	if(holder is null || holder !is getLocalPlayerBlob())
	{
		return;
	}

	this.SetFacingLeft(holder.isFacingLeft());

	if(!getControls().isKeyPressed(KEY_LBUTTON) && !getControls().isKeyJustReleased(KEY_LBUTTON))
	{

		lines.clear();
		return;
	}

	Vec2f aim = c.getMouseScreenPos();
	Vec2f lastaim = this.get_Vec2f("lastaim");

	if(getControls().isKeyJustPressed(KEY_LBUTTON))
	{
		this.set_Vec2f("startaim",aim);
	}

	Vec2f startaim = this.get_Vec2f("startaim");
	if((aim == lastaim && aim != startaim))//mouse still and not in starting spot?
	{
		line(this,startaim,aim);//process line
		this.set_bool("newlineready",true);
	}
	if(this.get_bool("newlineready"))
	{
		this.set_Vec2f("startaim",aim);
		this.set_bool("newlineready",false);
	}

	if(getControls().isKeyJustReleased(KEY_LBUTTON))
	{
		shape(this,holder);
	}


	this.set_Vec2f("lastaim",aim);
}

void line(CBlob@ this, Vec2f start, Vec2f end)
{	
	if((start - end).Length() < 25)
	{
		return;
	}


	Vec2f[]@ lines;
	this.get("lines",@lines);

	lines.push_back(start);
	lines.push_back(end);
}

void shape(CBlob@ this, CBlob@ holder)
{
	Vec2f[]@ lines;
	this.get("lines",@lines);

	u32[] angles;

	f32 drainAmount = 0;
	f32 powerLevel = getPowerLevel(this);
	for(int i = 0; i < lines.size(); i+= 2)
	{
		angles.push_back(closestValidAngle((lines[i] - lines[i+1]).Angle()));
	}

	if(angles.size() == 2 && powerLevel >= 10)
	{
		f32 angleDist = angleDistance(angles[0], angles[1]);
		if(angleDist > (135 - 30) && angleDist < (135 + 30))
		{
			Vec2f vec = Vec2f(8,0).RotateBy(angles[0]);
			vec.x *= -1; //for some reason the x is reversed so fixing it here.
			holder.setVelocity(vec);

			drainAmount = 10;
		}
	}
	else if(isSpell(angles,ESpells::teleport) && powerLevel >= 50)
	{
		f32[] minmax = getMinMaxVectorValues(lines);

		Vec2f rand = Vec2f(XORRandom(minmax[2] - minmax[0]) + minmax[0],XORRandom(minmax[3] - minmax[1]) + minmax[1]);
		holder.setPosition(getDriver().getWorldPosFromScreenPos(rand));

		drainAmount = 50;
	}

	drainPower(this, drainAmount);

	if(drainAmount > 0)
	{
		//--Particles--
	for(int i = 0; i < lines.size(); i+=2)
	{
		Vec2f start = lines[i];
		Vec2f end = lines[i + 1];

		Driver@ d = getDriver();
		Vec2f worldStart = d.getWorldPosFromScreenPos(start);
		Vec2f worldEnd = d.getWorldPosFromScreenPos(end);

		for(uint j = 0; j <= 10; j+= XORRandom(3))
		{
			Vec2f pos = Vec2f_lerp(worldStart, worldEnd, j/10.0f); 
			CParticle@ p = ParticlePixelUnlimited(
			pos,
			getRandomVelocity(0,3,360) * ((XORRandom(2) == 1) ? 0 : 1),
			SColor(255,50,175,200),
			true);
			if(p !is null)
			{
				p.collides = false;
				p.gravity = Vec2f(0,0.1);
			}
		}
	}
	//--Particles End--
	}

}

f32[] getMinMaxVectorValues(Vec2f[] vecs)
{
	f32 minX = 9999999999, minY = 9999999999, maxX = 0, maxY = 0;

	for(int i = 0; i < vecs.size(); i++)
	{
		Vec2f vec = vecs[i];
		if(vec.x < minX){minX = vec.x;}
		if(vec.y < minY){minY = vec.y;}

		if(vec.x > maxX){maxX = vec.x;}
		if(vec.y > maxY){maxY = vec.y;}
	}

	f32[] f = {minX,minY,maxX,maxY};
	return f;
}

Vec2f getAverageVector(Vec2f[] vectors)
{
	Vec2f average;
	for(int i = 0; i < vectors.size(); i ++)
	{
		average.x += vectors[i].x;
		average.y += vectors[i].y;
	}

	average.x /= vectors.size();
	average.y /= vectors.size();

	return average;

}

void printSpell(u32[] s)
{
	for(int i = 0; i < s.size(); i++)
	{
		print(s[i] + '');
	}
}

bool isSpell(u32[] angles, int spellID)
{
	if(angles.size() != spells[spellID].size())
	{
		return false;
	}
	for(int i = 0; i < angles.size(); i++)
	{
		if(angleDistance(angles[i],spells[spellID][i]) > 30)
		{
			return false;
		}
	}
	return true;
}

f32 getPowerLevel(CBlob@ this)
{
	CInventory@ inv = getHolder(this).getInventory();
	f32 powerlevel = 0;
	for(u32 i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ b = inv.getItem(i);
		if(b.getName() == "powercrystal")
		{
			powerlevel += b.get_f32("powerlevel");
		}
	}

	return powerlevel;
}

bool drainPower(CBlob@ this, f32 amount)
{
	CInventory@ inv = getHolder(this).getInventory();

	for(u32 i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ b = inv.getItem(i);

		if(b.getName() == "powercrystal")
		{
			f32 power = b.get_f32("powerlevel");
			if(amount > power                   )//spacing fixed thanks to numan spotting it for me
			{
				amount -= power;
				b.set_f32("powerlevel", 0);
				b.SendCommand(b.getCommandID("powerlevelchanged"));
			}
			else
			{
				power -= amount;
				b.set_f32("powerlevel", power);
				b.SendCommand(b.getCommandID("powerlevelchanged"));
				return true;
			}
		}
	}

	return false;
}

enum ESpells
{
	teleport = 0
}
u32[][] spells = 
{
	{
		180, 90, 0, 270
	}
};

void onRender(CSprite@ this)
{	
	CBlob@ b = this.getBlob();

	CBlob@ holder = getHolder(b);
	if(holder is null || holder !is getLocalPlayerBlob())
	{
		return;
	}

	//--GUI Start--
	f32 p;
	p = getPowerLevel(b)/100.0f;
	GUI::DrawIcon("PixelWhite.png", 0, Vec2f(1,1), Vec2f(190,9 + 37 * 2),20,-(37 * p), SColor(255,50,175,200));
	GUI::DrawIcon("ManaMeter.png", 0, Vec2f(8,16),Vec2f(190,4),2.5);
	//--GUI End--

	Vec2f pos = b.getPosition();
	Vec2f other = holder.getAimPos();

	Vec2f norm = pos - other;
	norm.Normalize();

	this.ResetTransform();
	this.RotateBy(((-norm.Angle() -270) % 180) + (holder.isFacingLeft() ? 0 : 180), Vec2f(holder.isFacingLeft() ? -2 : 2,7));

	Vec2f[]@ lines;
	b.get("lines",@lines);
	
	for(int i = 0; i < lines.size(); i+= 2)
	{
		f32 angle = (lines[i] - lines[i+1]).Angle();
		f32 valid = closestValidAngle(angle);


		Vec2f start = lines[i];
		Vec2f end = lines[i + 1];
		//Uncomment this to see values when making new spells
		 GUI::DrawLine2D(lines[i],lines[i+1], SColor(255,255,0,0));
		 GUI::DrawTextCentered(angle + "\n\n" + valid, (lines[i] + lines[i+1])/2, SColor(255,255,255,255));
	}
}

u32[] validAngles =  
{
	0, 45, 90, 135, 180, 225, 270, 315
};

u32 closestValidAngle(f32 a)
{
	u32 valid;
	u32 dist = 999999;

	for(int i = 0; i < validAngles.size(); i++)
	{
		u32 angle = validAngles[i];
		u32 newDist = angleDistance(a,angle);
		if(newDist < dist)
		{
			dist = newDist;
			valid = angle;
		}
	}

	return valid;
}

u32 angleDistance(f32 a, f32 b)
{
	u32 c = a - b;
	c = Maths::Abs(c);
	return Maths::Min(360 - c, c);
}

CBlob@ getHolder(CBlob@ this)
{
	return getBlobByNetworkID(this.get_u16("holder"));
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.set_u16("holder", attached.getNetworkID());

	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		this.setPosition(attached.getPosition()); // required to stop the first tick to be out of position

		shape.SetGravityScale(0); // this stops the shape from 'falling' when its attached to something
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
	this.set_u16("holder", 0);

	CShape@ shape = this.getShape();
	if (shape !is null)
	{
		shape.SetGravityScale(1);
	}
}