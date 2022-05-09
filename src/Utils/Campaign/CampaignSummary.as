class CampaignSummary
{
    int id;
    int clubid;
    string name;
    uint timestamp;
    int mapcount;

    CampaignSummary(const Json::Value &in json)
    {
        id = json["id"];
        clubid = json["clubid"];
        name = json["name"];
        timestamp = json["timestamp"];
        mapcount = json["mapcount"];
    }

    Json::Value ToJson()
    {
        Json::Value json = Json::Object();
        json["id"] = id;
        json["clubid"] = clubid;
        json["name"] = name;
        json["timestamp"] = timestamp;
        json["mapcount"] = mapcount;
        return json;
    }
}