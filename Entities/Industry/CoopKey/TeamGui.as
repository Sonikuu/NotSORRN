

void onTick(CSprite@ this){
	CBlob@ blob = this.getBlob();
	if(!blob.isMyPlayer()){return;}
	CPlayer@ p = blob.getPlayer();
	if(p is null){ return;}


	Vec2f s = Vec2f(getScreenWidth(),getScreenHeight());
	Vec2f w = Vec2f(128,32);
	Vec2f d = Vec2f(s.x - w.x,w.y);

	CBlob@[] blobs;

	getBlobsByName('coopkey',@blobs);

	CBlob@ coopKey;

	for(int i = 0; i < blobs.size(); i++){
		CBlob@ b = blobs[i];

		if(blob.getTeamNum() == b.getTeamNum()){
			@coopKey = @b;
		}
	}

	if(coopKey is null || getMap().get_string("team" + blob.getTeamNum() + "leader") != p.getUsername() ){
		blob.set_bool("DrawTeamMenu",false);
		return;
	}
	blob.set_bool("DrawTeamMenu",true);

	Vec2f mp = getControls().getMouseScreenPos();
	Vec2f end = d + w;


	if(blob.isKeyJustReleased(keys::key_action1) &&
	mp.x > d.x && mp.x < end.x &&
	mp.y > d.y && mp.y < end.y	){
		CBitStream params;
		params.write_netid(p.getNetworkID());

		coopKey.SendCommand(coopKey.getCommandID("manage"), params);

	}
}

void onRender(CSprite@ this){

	if(!this.getBlob().get_bool("DrawTeamMenu")){return;}
	Vec2f s = Vec2f(getScreenWidth(),getScreenHeight());
	Vec2f w = Vec2f(128,32);
	Vec2f d = Vec2f(s.x - w.x,w.y);
	
	//GUI::DrawPane(d,d + w);
	GUI::SetFont("MENU");
	GUI::DrawIcon("TeamManagement.png", 0, w,d,0.5, this.getBlob().getTeamNum());


}