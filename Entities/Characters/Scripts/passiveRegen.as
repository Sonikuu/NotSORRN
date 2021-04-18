#include "CHealth.as";


void onTick(CBlob@ this)
{
    if(this.getTickSinceCreated() % (60 * 30) == 0)
    {
        this.server_SetHealth(Maths::Min(this.getHealth() + 0.25, getMaxHealth(this)));
    }
}