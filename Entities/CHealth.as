

float getMaxHealth(CBlob@ this)
{
	if(this.exists("chealth"))
		return this.get_f32("chealth");
	return this.getInitialHealth();
}

void server_Heal(CBlob@ this, float heal)
{
	this.server_SetHealth(Maths::Min(getMaxHealth(this), this.getHealth() + heal));
}