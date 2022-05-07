class OfficialCampaignsSelectSWTab : CampaignListSWTab
{
    string GetLabel() override { return Icons::Globe + " Seasonal Campaigns"; }

    vec4 GetColor() override { return vec4(0.6, 0.43, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialQuarterlyCampaign(); }

    void Render() override
    {

    }
}