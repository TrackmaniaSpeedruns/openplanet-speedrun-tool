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
        else typeStr = "Unknown";

        // Parse type from tmio API (depending of the club id)
        if (typeStr == "Unknown")
        {
            if (clubid == 0) typeStr = "Season";
            else typeStr = "Club";
        }

        // we need to convert string to enum
        if (typeStr == "Season") type = Campaigns::campaignType::Season;
        else if (typeStr == "Club") type = Campaigns::campaignType::Club;
        else if (typeStr == "Training") type = Campaigns::campaignType::Training;
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
        json["type"] = tostring(type);
        return json;
    }
}