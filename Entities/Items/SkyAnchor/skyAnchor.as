void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0);

	this.addCommandID("Anchor");
}

void onTick(CBlob@ this)
{
	if(this.getPosition().y < 24)
	{
		this.server_Hit(this,this.getPosition(), Vec2f(0,0),0.5,0);
		this.setVelocity(this.getVelocity() + Vec2f(0,8));
	}
}

void GetButtonsFor( CBlob@ this, CBlob@ caller )
{
	if(!this.getShape().isStatic() && !this.isAttached())
	{
		bool anchorable = canAnchor(this);
		CButton@ button = caller.CreateGenericButton(15, Vec2f_zero,this, this.getCommandID("Anchor"), anchorable ? "Anchor" : "Can't anchor unless tile is empty");
		button.SetEnabled(anchorable);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(cmd == this.getCommandID("Anchor"))
	{
		Vec2f pos = this.getPosition();
		pos = Vec2f(Maths::Round(pos.x/8)*8,Maths::Round(pos.y/8)*8);
		pos += Vec2f(4,4);
		this.setPosition(pos);
		CShape@ s = this.getShape();
		s.getConsts().support = 10;
		this.setAngleDegrees(180);
		s.SetStatic(true);
	}
}

bool canAnchor(CBlob@ this)
{
	CMap@ map = getMap();
	Tile t = map.getTile(this.getPosition());
	return t.type == 0;
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return; 
	this.getSprite().PlaySound("/metal_stone.ogg");
}