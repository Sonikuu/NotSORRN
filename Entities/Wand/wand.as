
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

	for(int i = 0; i < lines.size(); i+= 2)
	{
		angles.push_back(closestValidAngle((lines[i] - lines[i+1]).Angle()));
	}

	if(isSpell(angles,ESpells::up))
	{
		holder.setVelocity(Vec2f(0,-8));
	}
	else if(isSpell(angles,ESpells::right))
	{
		holder.setVelocity(Vec2f(8,0));
	}
	else if(isSpell(angles,ESpells::teleport))
	{
		f32[] minmax = minimumMaximumVectorValues(lines);

		Vec2f rand = Vec2f(XORRandom(minmax[2] - minmax[0]) + minmax[0],XORRandom(minmax[3] - minmax[1]) + minmax[1]);
		holder.setPosition(getDriver().getWorldPosFromScreenPos(rand));
	}

}

f32[] minimumMaximumVectorValues(Vec2f[] vecs)
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
	return angles == spells[spellID];
}

enum ESpells
{
	up = 0,
	right = 1,
	teleport = 2
}

u32[][] spells = 
{
	{
		270,45
	},
	{
		180, 45
	},
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
		GUI::DrawLine2D(lines[i],lines[i+1], SColor(255,255,0,0));

		f32 angle = (lines[i] - lines[i+1]).Angle();
		f32 valid = closestValidAngle(angle);

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

CBlob@ getHolder(CBlob@ this)
{
	return getBlobByNetworkID(this.get_u16("holder"));
}

u32 angleDistance(f32 a, f32 b)
{
	u32 c = a - b;
	c = Maths::Abs(c);
	return Maths::Min(360 - c, c);
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