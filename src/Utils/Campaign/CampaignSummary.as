class CampaignSummary
{
    int id;
    int clubid;
    string name;
    uint timestamp;
    int mapcount;
    string typeStr;
    Campaigns::campaignType type;

    CampaignSummary(const Json::Value &in json)
    {
        id = json["id"];
        clubid = json["clubid"];
        name = json["name"];
        timestamp = json["timestamp"];
        mapcount = json["mapcount"];
        if (json.HasKey("type") && json["type"].GetType() != Json::Type::Null) typeStr = json["type"];
        else typeStr = "unknown";

        // Parse type from tmio API (depending of the club id)
        if (typeStr == "unknown")
        {
            if (clubid == 0) typeStr = "season";
            else typeStr = "club";
        }

        // we need to convert string to enum
        if (typeStr == "season") type = Campaigns::campaignType::Season;
        else if (typeStr == "club") type = Campaigns::campaignType::Club;
        else if (typeStr == "training") type = Campaigns::campaignType::Training;
        else if (typeStr == "TOTD") type = Campaigns::campaignType::TOTD;
        else type = Campaigns::campaignType::Unknown;
    }

    Json::Value ToJson()
    {
        Json::Value json = Json::Object();
        json["id"] = id;
        json["clubid"] = clubid;
        json["name"] = name;
        json["timestamp"] = timestamp;
        json["mapcount"] = mapcount;
        json["type"] = type;
        json["type_string"] = typeStr;
        return json;
    }
}