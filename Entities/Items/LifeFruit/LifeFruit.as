#include "ElementalCore.as"

void onInit(CBlob@ this)
{
	this.addCommandID("consume");
	
	AddIconToken("$consume$", "InteractionIcons.png", Vec2f(32, 32), 22);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if(getCore(caller) is null)
		return;
	CBitStream params;
	params.write_u16(caller.getNetworkID());
	CButton@ button = caller.CreateGenericButton("$consume$", Vec2f(0, 0), this, this.getCommandID("consume"), "Eat Lifefruit", params);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if(!blob.hasTag("flesh") || !this.isOnGround())
		return true;
	return false;
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if(this.getCommandID("consume") == cmd)
	{
		CBlob@ blob = getBlobByNetworkID(params.read_u16());
		if(this !is null && blob !is null && !this.hasTag("used"))
		{
			addElement(blob, "life", 20);
			this.Tag("used");
			this.server_Die();
		}
	}
}


