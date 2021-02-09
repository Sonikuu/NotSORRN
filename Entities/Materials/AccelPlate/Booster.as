
void onInit(CBlob@ this)
{
  this.Tag("builder always hit");
  
  this.set_TileType("background tile", CMap::tile_castle_back);
 
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
  return false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
  if (blob is null) return;
  Vec2f addedvel = Vec2f(22, 0).RotateByDegrees(this.getAngleDegrees());
  blob.setVelocity((blob.getVelocity() * 3 + addedvel) / 4.0);
}


