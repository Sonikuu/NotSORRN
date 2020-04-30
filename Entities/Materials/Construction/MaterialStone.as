
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8('decay step', 14);
  }

  this.maxQuantity = 250;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
}

void onTick(CBlob@ this)
{
	//CBlob@ holder = this.getAttachments().getAttachedBlob("PICKUP");
	//if(holder is null) {return;}

	
}
