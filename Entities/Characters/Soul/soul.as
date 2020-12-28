
void onInit(CBlob@ this){
    this.setInventoryName(this.get_string("owner") + "'s soul");
    this.addCommandID("snuff");

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
    CButton@ b = caller.CreateGenericButton(9, Vec2f_zero,this, this.getCommandID("snuff"), "Snuff out "+this.get_string("charname")+"'s soul...");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params){
    if(cmd == this.getCommandID("snuff"))
    {
        this.server_Die();
        CBlob@ b = getBlobByNetworkID(this.get_u16("owner_netid"));
        if(b is null){return;}

        b.server_SetActive(true);

        b.getSprite().PlaySound("man_scream.ogg", 1, 1);

        b.server_Die();
    }
}