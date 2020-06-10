

f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
    CPlayer@ p = this.getPlayer();
    if(p is null){return damage;}

    if(p.freeze){return 0;}
    else {return damage;}
}