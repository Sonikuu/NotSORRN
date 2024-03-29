
void onInit(CBlob@ this)
{
  this.Tag("builder always hit");
  
  this.set_TileType("background tile", CMap::tile_castle_back);
  if(isClient())
    this.getSprite().SetZ(-10);
 
}

void onTick(CBlob@ this)
{
  array<CBlob@> blobs;
  this.getOverlapping(blobs);
  for(int i = 0; i < blobs.size(); i++)
  {
    Vec2f addedvel = Vec2f(22, 0).RotateByDegrees(this.getAngleDegrees() - 90);
    blobs[i].setVelocity((blobs[i].getVelocity() * 30 + addedvel) / 31.0);
  }
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
  return false;
}

/*void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
  if (blob is null) return;
  Vec2f addedvel = Vec2f(22, 0).RotateByDegrees(this.getAngleDegrees() - 90);
  blob.setVelocity((blob.getVelocity() * 3 + addedvel) / 4.0);
}*/

void onDie(CBlob@ this)
{
  if(isServer())
  {
    CBlob@ output = server_CreateBlobNoInit("mat_accelplate");
		output.Tag("custom quantity");
		output.setPosition(this.getPosition());
		output.server_SetQuantity(1);
		output.Init();
  }
}

