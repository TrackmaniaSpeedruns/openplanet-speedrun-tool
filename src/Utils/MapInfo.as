class MapInfo {
	int campaignId;
	string author;
	string name;
	string filename;
	string uid;
	string file_url;
	int exchange_id;

    void ToJson()
    {
        Json::Value json = Json::Object();
        json["campaignId"] = campaignId;
        json["author"] = author;
        json["name"] = name;
        json["filename"] = filename;
        json["uid"] = uid;
        json["file_url"] = file_url;
        json["exchange_id"] = exchange_id;
    }
}