
void setAllKeysPressed(CBlob@ blob, bool pressed)
{
	blob.setKeyPressed(key_action1,pressed);
	blob.setKeyPressed(key_action2,pressed);
	blob.setKeyPressed(key_action3,pressed);
	blob.setKeyPressed(key_left,pressed);
	blob.setKeyPressed(key_right,pressed);
	blob.setKeyPressed(key_up,pressed);
	blob.setKeyPressed(key_down,pressed);
	blob.setKeyPressed(key_crouch,pressed);
	blob.setKeyPressed(key_jump,pressed);
}