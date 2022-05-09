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
        json["type"] = "training";
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
    }
}