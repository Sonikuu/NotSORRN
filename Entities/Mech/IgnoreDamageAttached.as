
f32 onHit( CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData )
{
	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			CBlob@ blob = ap.getOccupied();

			if (blob !is null && !ap.socket && ap.name != "PICKUP")
			{
				damage = 0;
			}  
		}   
	}
	return damage;
}









