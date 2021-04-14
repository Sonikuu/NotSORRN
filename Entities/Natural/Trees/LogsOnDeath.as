//tree making logs on death script

#include "TreeCommon.as"

void onDie(CBlob@ this)
{
	if(this.hasTag("nodrops"))
	{
		return;
	}

	Vec2f pos = this.getPosition();
	f32 fall_angle = 0.0f;

	if (this.exists("tree_fall_angle"))
	{
		fall_angle = this.get_f32("tree_fall_angle");
	}

	TreeSegment[]@ segments;
	this.get("TreeSegments", @segments);
	if (segments is null)
		return;

	if(isServer() && getMap().getTile(this.getPosition()).type == 0 && (XORRandom(10) == 0 || true))
	{ 
		server_CreateBlob("birb",-1,this.getPosition() - Vec2f(0,5 * segments.size()));
	}

	for (uint i = 0; i < segments.length; i++)
	{
		TreeSegment@ segment = segments[i];

		if (getNet().isServer())
		{
			pos = this.getPosition() + (segment.start_pos + segment.end_pos) / 2.0f;
			pos.y -= 4.0f; // TODO: fix logs spawning in ground
			CBlob@ log = server_CreateBlob("log", this.getTeamNum(), pos);
			if (log !is null)
			{
				log.setAngleDegrees(fall_angle);
			}
		}
	}

	//TODO LEAVES PARTICLES
	//ParticleAnimated( "Entities/Effects/leaves", pos, Vec2f(0,-0.5f), 0.0f, 1.0f, 2+XORRandom(4), 0.2f, false );
	//for (int i = 0; i < this.getSprite().getSpriteLayerCount(); i++) { // crashes
	//    ParticlesFromSprite( this.getSprite().getSpriteLayer(i) );
	//}
	// effects
	Sound::Play("Sounds/branches" + (XORRandom(2) + 1) + ".ogg", this.getPosition());
}
