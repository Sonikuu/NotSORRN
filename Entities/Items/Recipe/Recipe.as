
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if(isClient() && blob.getAttachmentPoint(0).getOccupied() is getLocalPlayerBlob() && getLocalPlayerBlob() !is null)
		GUI::DrawIcon(blob.get_string("recipe"), getLocalPlayerBlob().getInterpolatedScreenPos() + Vec2f(-64, -128));
}

void onInit(CBlob@ this)
{
	u8 id = this.get_u8("aux");
	this.set_string("recipe", "RecipeBlank.png");
	if(id == 0)//Diffuse
	{
		this.set_string("recipe", "RecipeDiffuser.png");
		this.setInventoryName("Diffuser Recipe");
	}
	else if(id == 1)//Furnace Construction
	{
		this.set_string("recipe", "RecipeFurnace.png");
		this.setInventoryName("Furnace Construction Recipe");
	}
	else if(id == 2)//Mixer
	{
		Random rand(this.getNetworkID());
		id = rand.NextRanged(6);
		if(id == 0)
		{
			this.set_string("recipe", "RecipeMixerLife.png");
			this.setInventoryName("Mixer Life Recipe");
		}
		else if(id == 1)
		{
			this.set_string("recipe", "RecipeMixerForce.png");
			this.setInventoryName("Mixer Force Recipe");
		}
		else if(id == 2)
		{
			this.set_string("recipe", "RecipeMixerNatura.png");
			this.setInventoryName("Mixer Natura Recipe");
		}
		else if(id == 3)
		{
			this.set_string("recipe", "RecipeMixerPurity.png");
			this.setInventoryName("Mixer Purity Recipe");
		}
		else if(id == 4)
		{
			this.set_string("recipe", "RecipeMixerCorruption.png");
			this.setInventoryName("Mixer Corruption Recipe");
		}
		else if(id == 5)
		{
			this.set_string("recipe", "RecipeMixerEcto.png");
			this.setInventoryName("Mixer Ecto Recipe");
		}
	}
	else if(id == 3)//Furnace Smelt Recipes
	{
		Random rand(this.getNetworkID());
		id = rand.NextRanged(3);
		if(id == 0)
		{
			this.set_string("recipe", "RecipeFurnaceCharcoal.png");
			this.setInventoryName("Furnace Charcoal Recipe");
		}
		else if(id == 1)
		{
			this.set_string("recipe", "RecipeFurnacePureDust.png");
			this.setInventoryName("Furnace Pure Dust Recipe");
		}
		else if(id == 2)
		{
			this.set_string("recipe", "RecipeFurnaceUnstableCore.png");
			this.setInventoryName("Furnace Unstable Core Recipe");
		}
	}
}

//collide with vehicles and structures	- hit stuff if thrown

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return (blob.getShape().isStatic() || (blob.isInWater() && blob.hasTag("vehicle")) || this.getConfig() == blob.getConfig()); // boat
}

