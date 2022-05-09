class ClubCampaignsSelectSWTab : CampaignListSWTab
{
    string t_search;
    uint64 t_typingStart;

    string GetLabel() override { return Icons::Boxes + " Club Campaigns"; }

    vec4 GetColor() override { return vec4(0.57, 0.61, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayPublicClubCampaign(); }

    void GetRequestParams(dictionary@ params) override
    {
        if (t_search.Length > 1) params.Set("search", t_search);
        CampaignListSWTab::GetRequestParams(params);
    }

    void CheckStartRequest() override
    {
        if (campaigns.Length == 0 && m_request is null && UI::IsWindowAppearing()) {
            StartRequest();
        }

        if (m_request !is null) {
            return;
        }

        if (t_typingStart == 0) {
            return;
        }

        if (Time::Now > t_typingStart + 1000) {
            t_typingStart = 0;
            StartRequest();
        }
    }

    void HandleResponse(const Json::Value &in json) override
    {
        auto items = json["campaigns"];
        for (uint i = 0; i < items.Length; i++) {
            CampaignSummary@ campaign = CampaignSummary(items[i]);
            if (campaign.clubid != 0) campaigns.InsertLast(campaign);
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