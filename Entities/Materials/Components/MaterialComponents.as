
void onInit(CBlob@ this)
{
  this.maxQuantity = 64;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
