class OfficialCampaignsSelectSWTab : CampaignListSWTab
{
    bool ShowLoadMore() override { return false; }

    string GetLabel() override { return Icons::Globe + " Seasonal Campaigns"; }

    vec4 GetColor() override { return vec4(0.6, 0.43, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialQuarterlyCampaign(); }

    void HandleResponse(const Json::Value &in json) override
    {
        auto items = json["campaigns"];
        for (uint i = 0; i < items.Length; i++) {
            CampaignSummary@ campaign = CampaignSummary(items[i]);
            if (campaign.clubid == 0) campaigns.InsertLast(campaign);
        }
    }
}