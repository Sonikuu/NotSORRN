

void onInit(CBlob@ this)
{
    CShape@ shape = this.getShape();
    shape.SetGravityScale(0);
    //shape.getConsts().mapCollisions = false;
    shape.getConsts().collidable = false;

    this.set_s32("golemiteMax",1000);
    this.set_s32("golemiteCount",200);

    this.Tag("invincible");
}

void onTick(CBlob@ this)
{
    
}

bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){return false;}
bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob ){return  false;}