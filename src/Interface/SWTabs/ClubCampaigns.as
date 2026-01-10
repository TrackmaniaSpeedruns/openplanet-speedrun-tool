class ClubCampaignsSelectSWTab : CampaignListSWTab
{
    string t_search;
    uint64 t_typingStart;

    string GetLabel() override { return Icons::Cubes + " Club Campaigns"; }

    vec4 GetColor() override { return vec4(0.57, 0.61, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayPublicClubCampaign(); }

    void LoadCampaigns(int count, int offset) override {
        string requestedSearch = t_search;
        auto result = API::CallLiveApiPath("/api/token/club/campaign?length="+count+"&offset="+offset+"&name="+t_search);
        if (requestedSearch != t_search) {
            // Search term changed while we were loading
            return;
        }
        Json::Value items = result["clubCampaignList"];
        for (uint i = 0; i < items.Length; i++) {
            auto json = Json::Object();
            json["id"] = items[i]["id"];
            json["name"] = items[i]["name"];
            json["type"] = "Club";
            json["mapUids"] = Json::Array();
            auto playlist = items[i]["campaign"]["playlist"];
            for (uint j = 0; j < playlist.Length; j++) {
                json["mapUids"].Add(playlist[j]["mapUid"]);
            }
            CampaignSummary@ campaign = CampaignSummary(json);
            campaigns.InsertLast(campaign);
        }
    }

    void RenderHeader() override
    {
        UI::Text("Search:");
        UI::SameLine();
        bool changed = false;
        t_search = UI::InputText("###Search", t_search, changed);
        if (changed) {
            if (t_search.Length > 1 || t_search.Length == 0) {
                Clear();
                t_typingStart = Time::Now;
            }
        }
        UI::SameLine();
    }
}