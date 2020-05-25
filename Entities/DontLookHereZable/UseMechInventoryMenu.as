
#include "MechCommon.as";
void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu @gridmenu)
{
	
	CBlob@ blob = this.getAttachments().getAttachedBlob("DRIVER");

	if (blob !is null && this.isMyPlayer())
	{
		AttachmentPoint@[] aps;
		if (blob.getAttachmentPoints(@aps))
		{
			for (uint i = 0; i < aps.length; i++)
			{
				AttachmentPoint@ ap = aps[i];
				CBlob@ pblob = ap.getOccupied();

				if (pblob !is null && ap.socket && ap.name != "DRIVER" && !blob.hasTag("immobile"))
				{
					IMechPart@ part = @getMechPart(pblob);
					if(part !is null)
					{
						//Remember to clear inv menu :V
						part.onCreateInventoryMenu(blob, this, @gridmenu);
					}
				}  
			}   
		}
	}
}
























