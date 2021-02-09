
void onInit(CBlob@ this)
{
  this.maxQuantity = 16;

  this.Tag("place norotate");
  this.Tag("dont deactivate");

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}
