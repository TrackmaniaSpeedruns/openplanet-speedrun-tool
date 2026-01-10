class OfficialCampaignsSelectSWTab : CampaignListSWTab
{
    string GetLabel() override { return Icons::Globe + " Seasonal Campaigns"; }

    vec4 GetColor() override { return vec4(0.6, 0.43, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialQuarterlyCampaign(); }

    void LoadCampaigns(int count, int offset) override {
        auto result = API::CallLiveApiPath("/api/campaign/official?length="+count+"&offset="+offset);
        Json::Value items = result["campaignList"];
        for (uint i = 0; i < items.Length; i++) {
            auto json = Json::Object();
            json["id"] = items[i]["id"];
            json["name"] = items[i]["name"];
            json["type"] = "Season";
            json["mapUids"] = Json::Array();
            for (uint j = 0; j < items[i]["playlist"].Length; j++) {
                json["mapUids"].Add(items[i]["playlist"][j]["mapUid"]);
            }
            CampaignSummary@ campaign = CampaignSummary(json);
            if (campaign.type == Campaigns::campaignType::Season) {
                // Show past campaigns if the user has permissions
                if (i > 0 && Permissions::PlayPastOfficialQuarterlyCampaign())
                    campaigns.InsertLast(campaign);
                else if (i == 0)
                    campaigns.InsertLast(campaign);
            }
        }
    }
}