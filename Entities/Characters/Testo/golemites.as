void onInit(CBlob@ this)
{
    CShape@ shape = this.getShape();
    shape.SetGravityScale(0);
    //shape.getConsts().mapCollisions = false;
    shape.getConsts().collidable = false;

    this.set_s32("golemiteMax",1000);
    this.set_s32("golemiteCount",200);

    this.Tag("invincible");

	this.addCommandID("absorbMaterial");
}

void onTick(CBlob@ this)
{
    if(this.get_s32("golemiteCount") <= 0)
	{
		this.server_Die();
	}
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	this.add_s32("golemiteCount",-damage * 100);

	return 0;
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){return false;}
bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob ){return  false;}