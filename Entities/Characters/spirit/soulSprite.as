
void onSetPlayer( CBlob@ this, CPlayer@ player )
{
    if(player !is null)
    {
        this.setInventoryName(player.getCharacterName() + "'s Soul");
    }
}