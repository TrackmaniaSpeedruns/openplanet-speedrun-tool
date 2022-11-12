class CommunitySpeedrunSWTab : SWTab
{
    CampaignSummary@ CommunitySpeedrun;

    CommunitySpeedrunSWTab()
    {
        Json::Value json = Json::Object();
        json["id"] = 32622;
        json["clubid"] = 2080;
        json["name"] = "Community $fc0Speedrun";
        json["timestamp"] = 1668174869;
        json["mapcount"] = 25;
        json["type"] = "Club";
        @CommunitySpeedrun = CampaignSummary(json);
    }

    string GetLabel() override { return Icons::FlagCheckered + " Community Speedrun"; }

    vec4 GetColor() override { return vec4(0.26, 1, 0.16, 1); }

    bool IsVisible() override { return Permissions::PlayPublicClubCampaign(); }

    void Render() override
    {
        bool isSelected = false;
        for (uint i = 0; i < g_SpeedrunWindow.selectedCampaigns.Length; i++)
        {
            if (g_SpeedrunWindow.selectedCampaigns[i].id == CommunitySpeedrun.id)
            {
                if (!isSelected) g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
                isSelected = true;
                break;
            }
        }
        isSelected = UI::WhiteCheckbox("Select Community \\$fc0Speedrun", isSelected);
        if (isSelected) g_SpeedrunWindow.selectedCampaigns.InsertLast(CommunitySpeedrun);

        UI::SameLine();
        // Check if the campaign is favorited
        bool isFav = false;
        int favIndex = -1;
        for (uint f = 0; f < DataJson["favoriteCampaigns"].Length; f++)
        {
            CampaignSummary@ favorite = CampaignSummary(DataJson["favoriteCampaigns"][f]);
            if (favorite.id == CommunitySpeedrun.id)
            {
                isFav = true;
                favIndex = f;
                break;
            }
        }
        if (isFav) {
            UI::Text("\\$f00" + Icons::Heart);
            UI::SetPreviousTooltip("Campaign added to favorites. Click to remove from favorites");
            if (UI::IsItemClicked()) {
                DataJson["favoriteCampaigns"].Remove(favIndex);
                DataManager::Save();
            }
        } else {
            UI::TextDisabled(Icons::HeartO);
            UI::SetPreviousTooltip("Campaign is not in favorites. Click to add to favorites");
            if (UI::IsItemClicked()) {
                DataJson["favoriteCampaigns"].Add(CommunitySpeedrun.ToJson());
                DataManager::Save();
            }
        }
    }
}