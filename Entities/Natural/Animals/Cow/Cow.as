

void onInit(CSprite@ this)
{
	
}

void onTick(CSprite@ this)
{
	
}

//blob

void onInit(CBlob@ this)
{
	this.Tag("bison");
	this.getShape().SetOffset(Vec2f(0, 7.5));
	this.addCommandID("milk");
}


void onTick(CBlob@ this)
{
	CMap@ map = getMap();
	if(map !is null)
	{
		if(getGameTime() % 150 == 0 && XORRandom(10) == 0)
		{
			if(this.get_u16("pregnancytime") == 0)
			{
				array<CBlob@> blobs;
				map.getBlobsInRadius(this.getPosition(), 64, @blobs);
				bool foundmale = false;
				int bisons = 0;
				for(int i = 0; i < blobs.size(); i++)
				{
					if(blobs[i].hasTag("bison"))
						bisons++;
					if(blobs[i].getConfig() == "bison")
					{
						foundmale = true;
						
					}
				}
				if(foundmale && bisons < 4)
				{
					this.set_u16("pregnancytime", 60 * 5);
					this.setInventoryName("Bison Cow (Gregnant)");
				}
			}
		}
	}
	if(getGameTime() % 30 == 0)
	{
		if(this.get_u16("pregnancytime") > 0)
		{
			this.sub_u16("pregnancytime", 1);
			if(this.get_u16("pregnancytime") == 0)
			{
				//Make baby
				if(isServer())
					server_CreateBlob("foal", this.getTeamNum(), this.getPosition());
				this.setInventoryName("Bison Cow");
			}
		}

		if(this.get_u16("milkcool") > 0)
		{
			this.sub_u16("milkcool", 1);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if(cmd == this.getCommandID("milk"))
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		if(blob !is null && blob.getCarriedBlob() !is null && blob.getCarriedBlob().getConfig() == "bucket")
		{
			blob.getCarriedBlob().server_Die();
			CBlob@ new = server_CreateBlob("milkbucket", blob.getTeamNum(), blob.getPosition());
			blob.server_Pickup(new);
			this.set_u16("milkcool", 120);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(this.get_u16("milkcool") == 0 && caller.getCarriedBlob() !is null && caller.getCarriedBlob().getConfig() == "bucket")
	{
		CBitStream params;
		params.write_u16(caller.getNetworkID());
		caller.CreateGenericButton("$gun_menu$", Vec2f(0, 0), this, this.getCommandID("milk"), "Milk", params);
	}
}

