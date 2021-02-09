void onInit(CBlob@ this)
{
	//these don't actually use it, they take the controls away
	this.push("names to activate", "lantern");
	this.push("names to activate", "crate");
	this.push("names to activate", "mat_accelplate");
	//it me, the dev, adding some activatables to all runners since only builders exist anyway :)
	this.push("names to activate", "mat_bombs");
	this.push("names to activate", "keg");
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
