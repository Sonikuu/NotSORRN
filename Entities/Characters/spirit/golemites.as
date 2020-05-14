

void onInit(CBlob@ this)
{
    CShape@ shape = this.getShape();
    shape.SetGravityScale(0);
    //shape.getConsts().mapCollisions = false;
    shape.getConsts().collidable = false;
}
bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){return false;}
bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob ){return  false;}