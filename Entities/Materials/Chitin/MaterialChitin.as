
void onInit(CBlob@ this)
{
  this.maxQuantity = 16;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
