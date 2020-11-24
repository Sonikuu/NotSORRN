
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