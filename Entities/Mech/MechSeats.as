#include "SeatsCommon.as"

void onInit(CBlob@ this)
{

	this.Tag("seats");

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().runFlags |= Script::tick_hasattached;
}

void onTick(CBlob@ this)
{
	// set face direction

	const bool facing = this.isFacingLeft();
	const f32 angle = this.getAngleDegrees();

	AttachmentPoint@[] aps;
	if (this.getAttachmentPoints(@aps))
	{
		CBlob@ driver = this.getAttachments().getAttachedBlob("DRIVER");
		for (uint i = 0; i < aps.length; i++)
		{
			AttachmentPoint@ ap = aps[i];
			if (ap.socket && ((ap.name == "DRIVER" || ap.name == "LOCO") || driver is null))
			{
				CBlob@ occBlob = ap.getOccupied();
				if (occBlob !is null)
				{
					occBlob.SetFacingLeft(facing);
					occBlob.setAngleDegrees(angle);
				}
			}
		}
	}
}


void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attachedPoint.socket)
	{
		SetOccupied(attachedPoint, 1);
		attached.Tag("seated");
		Sound::Play("GetInVehicle.ogg", attached.getPosition());

		if (this.getDamageOwnerPlayer() is null) {
			this.SetDamageOwnerPlayer(attached.getPlayer());
		}
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	if (attachedPoint.socket)
	{
		SetOccupied(attachedPoint, 0);
		detached.Untag("seated");

		if (!detached.getShape().isRotationsAllowed())
		{
			detached.setAngleDegrees(0.0f);
		}

		if (detached.getPlayer() is this.getDamageOwnerPlayer()) {
			this.SetDamageOwnerPlayer(null);
		}
	}
}

