
void onInit(CBlob@ this)
{
    this.getShape().SetGravityScale(0);
    this.addCommandID('bad delta');
}

void onTick(CBlob@ this)
{

    if(this.getTickSinceCreated() == 10)
    {
        CBitStream params;
        params.write_u16(0);
        this.SendCommand(this.getCommandID('bad delta'), params);
    }
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
    if(cmd == this.getCommandID('bad delta'))
    {
        params.read_u32();
    }
}

bool doesCollideWithBlob( CBlob@ this, CBlob@ blob )
{
    return false;
}
