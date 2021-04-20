

void onRender(CSprite@ this)
{
	//inventory
	CBlob@ blob = this.getBlob();
	CInventory@ inv = blob.getInventory();
	if(blob.getPlayer() !is getLocalPlayer()){return;}

	CBlob@[] blobs;

	for(int i = 0; i < inv.getItemsCount(); i++){
		blobs.push_back(inv.getItem(i));
	}
	f32 kagScale = 1;
	f32 scale = kagScale/0.5; //kag scale is 2 when you put in 1 because kag hates you

	Vec2f startPos = Vec2f(5,68 + (3 * scale));

	array<Vec2f> iconPositons;
	Vec2f lastItemPos = startPos;

	f32 tallest = -1;

	int[] duplicates;
	int[] toDraw;

	for(int i = 0; i < blobs.size(); i++){
		CBlob@ b = blobs[i];

		if(duplicates.find(b.getName().getHash()) == -1)
		{
			Vec2f newPos = lastItemPos + Vec2f(3 * scale,0);
			iconPositons.push_back(newPos);
			lastItemPos = newPos + Vec2f(b.inventoryFrameDimension.x * scale,0);

			if(tallest < b.inventoryFrameDimension.y){
				tallest = b.inventoryFrameDimension.y;
			}

			toDraw.push_back(i);
			duplicates.push_back(b.getName().getHash());
		}
	}

	

	if(blobs.size() > 0)
	{
		GUI::DrawRectangle(startPos + Vec2f(0,10), iconPositons[iconPositons.size() - 1] + Vec2f(blobs[blobs.size() - 1].inventoryFrameDimension.x * scale + 6,(tallest + 9) * scale));
	}

	for(int i = 0; i < toDraw.size(); i++){
		CBlob@ b = blobs[toDraw[i]];
		int x = b.inventoryFrameDimension.x;
		GUI::DrawIcon(b.inventoryIconName , b.inventoryIconFrame , b.inventoryFrameDimension,iconPositons[i] + Vec2f(0,x < 16 ? scale *(x/2 + 6) : 12), kagScale);

		f32 ammount = blob.getBlobCount(b.getName());

		f32 r = Maths::Min(ammount, b.maxQuantity)/b.maxQuantity;
		GUI::SetFont("snes");
		Vec2f txtStart = Vec2f(iconPositons[i].x,startPos.y +  scale * tallest + 3 * scale);
		GUI::DrawText( ammount + '',txtStart, txtStart + Vec2f(scale * 16, scale * 16), colorLerp(SColor(255,255,0,0),color_white,r), false, false, false);
	}


	//health bar
	f32 ph = blob.getHealth()/getMaxHealth(blob);
	Vec2f hpPos = startPos + Vec2f(0, (tallest > 0 ? tallest + 9 : 4) * scale);
	GUI::DrawIcon("HealthBar.png", 1, Vec2f(16,64), hpPos,kagScale);

	int smoothFactor = 10;
	for(int i = smoothFactor; i > 0; i--){
		int a = i * 1;

		SColor color = colorLerp(SColor(255,127 - (i * 10),0,0),SColor(255,0,200 - (i * 10),0),ph);
		GUI::DrawIcon("PixelWhite.png",0, Vec2f(1,1), hpPos + Vec2f(a,0), 16 - a , (64 - smoothFactor + a) * ph, color);
	}
	GUI::DrawIcon("HealthBar.png", 0, Vec2f(16,64), hpPos,kagScale);


	
}

SColor colorLerp(SColor cola, SColor colb, f32 s){
	SColor colc;
	colc.setRed(Maths::Lerp(cola.getRed(),colb.getRed(),s));
	colc.setBlue(Maths::Lerp(cola.getBlue(),colb.getBlue(),s));
	colc.setGreen(Maths::Lerp(cola.getGreen(),colb.getGreen(),s));

	return colc;
}