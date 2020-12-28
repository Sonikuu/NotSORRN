
void onInit(CBlob@ this){
    this.setInventoryName(this.get_string("owner") + "'s soul");

    this.getShape().SetStatic(true);
}

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData ){
    return 0;
}
bool canBePickedUp( CBlob@ this, CBlob@ byBlob ){
    return false;
}
bool doesCollideWithBlob( CBlob@ this, CBlob@ blob ){
    return false;
}
void GetButtonsFor( CBlob@ this, CBlob@ caller ){
    CButton@ b = caller.CreateGenericButton(9, Vec2f_zero,this, @onButtonPress, "Snuff out "+this.get_string("charname")+"'s soul...");
}

void onButtonPress(CBlob@ this, CBlob@ caller){
    this.server_Die();
    CBlob@ b = getBlobByNetworkID(this.get_u16("owner_netid"));
    if(b is null){return;}

    b.server_SetActive(true);

    b.getSprite().PlaySound("man_scream.ogg", 1, 1);

    b.server_Die();
}