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

        // create json signature
        string jsonHash = Json::Write(DataJson);
        jsonHash = Hash::Sha256(jsonHash);
        IO::File file(DATA_JSON_SIG_LOCATION);
        file.Open(IO::FileMode::Write);
        file.WriteLine(jsonHash);
        file.Close();
    }

    bool compareJsonSignature()
    {
        IO::File file(DATA_JSON_SIG_LOCATION);
        file.Open(IO::FileMode::Read);
        string baseSign = file.ReadLine();
        file.Close();

        string jsonHash = Hash::Sha256(Json::Write(DataJson));

        return baseSign == jsonHash;
    }

    bool isJsonUpdated()
    {
        Json::Value DataTemp = Json::FromFile(DATA_JSON_LOCATION);
        if (DataTemp.GetType() != Json::Type::Object) return false;
        return Json::Write(DataTemp) == Json::Write(DataJson);
    }
}