class TrainingSelectSWTab : SWTab
{
    CampaignSummary@ TrainingCampaignSummary;

    TrainingSelectSWTab()
    {
        Json::Value json = Json::Object();
        json["id"] = 0;
        json["clubid"] = 0;
        json["name"] = "Training";
        json["timestamp"] = 0;
        json["mapcount"] = 25;
        json["type"] = "Training";
        @TrainingCampaignSummary = CampaignSummary(json);
    }

    string GetLabel() override { return Icons::Medkit + " Training"; }

    vec4 GetColor() override { return vec4(0, 0, 0, 1); }

    void Render()
    {
        bool isSelected = false;
        for (uint i = 0; i < g_SpeedrunWindow.selectedCampaigns.Length; i++)
        {
            if (g_SpeedrunWindow.selectedCampaigns[i].id == TrainingCampaignSummary.id)
            {
                if (!isSelected) g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
                isSelected = true;
                break;
            }
        }
        isSelected = UI::WhiteCheckbox("Select Training Campaign", isSelected);
        if (isSelected) g_SpeedrunWindow.selectedCampaigns.InsertLast(TrainingCampaignSummary);

        // Check if the campaign is favorited
        bool isFav = false;
        int favIndex = -1;
        for (uint f = 0; f < DataJson["favoriteCampaigns"].Length; f++)
        {
            CampaignSummary@ favorite = CampaignSummary(DataJson["favoriteCampaigns"][f]);
            if (favorite.id == TrainingCampaignSummary.id)
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
    }
}