class TOTDSelectSWTab : CampaignListSWTab
{
    string GetLabel() override { return Icons::Calendar + " Tracks of The Day"; }

    vec4 GetColor() override { return vec4(0.217, 0.569, 0.61, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialMonthlyCampaign(); }

    array<string> monthStrings = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

    string GetMonthName(int month)
    {
        if (month == 0 || month > 12)
            return "Invalid month";

        return monthStrings[month - 1];
    }

    void LoadCampaigns(int count, int offset) override {
        auto result = API::CallLiveApiPath("/api/token/campaign/month?length="+count+"&offset="+(offset+1)); //offset+1 to skip current month
        auto items = result["monthList"];
        for(int i = 0; i < items.Length; i++) {
            auto json = Json::Object();
            json["id"] = (items[i]["year"] - 2020) * 12 + items[i]["month"];
            json["name"] = GetMonthName(items[i]["month"]) + " " + Json::Write(items[i]["year"]);
            json["type"] = "TOTD";
            json["mapUids"] = Json::Array();
            for (uint j = 0; j < items[i]["days"].Length; j++) {
                json["mapUids"].Add(items[i]["days"][j]["mapUid"]);
            }
            CampaignSummary@ totd = CampaignSummary(json);
            if ((i > 0 && Permissions::PlayPastOfficialMonthlyCampaign()) || i == 0)
                campaigns.InsertLast(totd);
        }
    }
}