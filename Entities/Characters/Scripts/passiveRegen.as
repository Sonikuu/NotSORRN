


void onTick(CBlob@ this)
{
    if(getGameTime() % (60 * 30) == 0)
    {
        this.server_SetHealth(Maths::Min(this.getHealth() + 0.25,this.getInitialHealth()));
    }
}