

void onInit(CBlob@ this)
{
    CShape@ shape = this.getShape();
    shape.SetGravityScale(0);
}

void onSetPlayer( CBlob@ this, CPlayer@ player )
{
    if(player !is null)
    {
        this.setInventoryName(player.getCharacterName() + "'s Soul");
    }
}



bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){return false;}
bool canBePutInInventory( CBlob@ this, CBlob@ inventoryBlob ){return  false;}