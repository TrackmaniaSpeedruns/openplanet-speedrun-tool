class ClubCampaignsSelectSWTab : CampaignListSWTab
{
    string GetLabel() override { return Icons::Boxes + " Club Campaigns"; }

    vec4 GetColor() override { return vec4(0.57, 0.61, 0.22, 1); }

    bool IsVisible() override { return Permissions::PlayPublicClubCampaign(); }

    void Render() override
    {

    }
}