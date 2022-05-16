namespace DataManager
{

    void Init(bool save = true)
    {
        trace("Initilizing Data");
        DataJson = Json::Object();
        DataJson["favoriteCampaigns"] = Json::Array();
        DataJson["favoritePlaylists"] = Json::Array();

        if (save) Save();
    }

    void Save()
    {
        if (isJsonUpdated()) return;
        trace("Saving JSON file");
        Json::ToFile(DATA_JSON_LOCATION, DataJson);
    }

    bool isJsonUpdated()
    {
        Json::Value DataTemp = Json::FromFile(DATA_JSON_LOCATION);
        if (DataTemp.GetType() != Json::Type::Object) return false;
        return Json::Write(DataTemp) == Json::Write(DataJson);
    }
}