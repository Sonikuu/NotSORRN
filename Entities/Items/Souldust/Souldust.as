
void onInit(CBlob@ this)
{
  this.maxQuantity = 1;

  //this.getCurrentScript().runFlags |= Script::remove_after_this;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
  if (blob.hasTag('solid')) return true;

  if (blob.getShape().isStatic()) return true;

  return false;
}