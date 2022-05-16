namespace IfaceRender
{
    void CampaignListLine(CampaignSummary@ campaign)
    {
        UI::TableNextRow();

        UI::TableSetColumnIndex(0);
        UI::Text(ColoredString(campaign.name));
        // Check if the campaign is favorited
        bool isFav = false;
        int favIndex = -1;
        for (uint f = 0; f < DataJson["favoriteCampaigns"].Length; f++)
        {
            CampaignSummary@ favorite = CampaignSummary(DataJson["favoriteCampaigns"][f]);
            if (favorite.id == campaign.id)
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
                DataJson["favoriteCampaigns"].Add(campaign.ToJson());
                DataManager::Save();
            }
        }

        UI::TableSetColumnIndex(1);
        bool isSelected = false;
        for (uint i = 0; i < g_SpeedrunWindow.selectedCampaigns.Length; i++)
        {
            if (g_SpeedrunWindow.selectedCampaigns[i].id == campaign.id)
            {
                if (!isSelected) g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
                isSelected = true;
                break;
            }
        }
        isSelected = UI::WhiteCheckbox("###SelectCampaign"+campaign.id, isSelected);
        if (isSelected) g_SpeedrunWindow.selectedCampaigns.InsertLast(campaign);
    }
}