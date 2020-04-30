// For crate autopickups

bool crateTake(CBlob@ this, CBlob@ blob)
{
    if (this.exists("packed"))
    {
        return false;
    }

    const string blobName = blob.getName();

    if (   blobName.find("mat_") >= 0
        //|| blobName == "mat_stone"
        //|| blobName == "mat_wood"
        //|| blobName == "mat_bombs"
        //|| blobName == "mat_waterbombs"
        //|| blobName == "mat_arrows"
        //|| blobName == "mat_firearrows"
        //|| blobName == "mat_bombarrows"
        //|| blobName == "mat_waterarrows"
        || blobName == "log"
        || blobName == "fishy"
        || blobName == "grain"
        || blobName == "food"
        || blobName == "egg"
		|| blobName == "lifefruit"
        )
    {
        return this.server_PutInInventory(blob);
    }
    return false;
}
