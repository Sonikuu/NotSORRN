#define SERVER_ONLY

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

void Take(CBlob@ this, CBlob@ blob)
{

	if (isMatch(this,blob))
	{
		if ((this.getDamageOwnerPlayer() is blob.getPlayer()) || getGameTime() > blob.get_u32("autopick time"))
		{
			if (!this.server_PutInInventory(blob))
			{
				// we couldn't fit it in
				//thats what she said
			}
		}
	}
}

bool isMatch(CBlob@ this, CBlob@ blob)
{
	const string blobName = blob.getName();
	CPlayer@ p = this.getPlayer();
	if(true || p !is null && getRules().get_bool(p.getUsername() + "_NewPickupOn")) //todo fix settings
	{
		CInventory@ inv = this.getInventory();
		for(int i = 0; i < inv.getItemsCount(); i++)
		{
			if(inv.getItem(i).getConfig() == blob.getConfig())
			{
				return true;
			}
		}
		return false;
	}
	else
	{
			return blobName == "mat_gold" || blobName == "mat_stone" ||
	        blobName == "mat_wood" || /*blobName == "grain" ||*/
			blobName == "mat_sand" || blobName == "mat_charcoal" ||
			blobName == "mat_glass" || blobName == "mat_gunpowder" ||
			blobName == "mat_metal" || blobName == "mat_marble" ||
			blobName == "mat_basalt";
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;

	if (this.getOverlapping(@overlapping))
	{
		for (uint i = 0; i < overlapping.length; i++)
		{
			CBlob@ blob = overlapping[i];
			{
				if (blob.getShape().vellen > 1.0f)
				{
					continue;
				}

				Take(this, blob);
			}
		}
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead"))
	{
		return;
	}

	const string blobName = blob.getName();

	if (isMatch(this,blob))
	{
		blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
		blob.SetDamageOwnerPlayer(blob.getPlayer());
	}
}


void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}
