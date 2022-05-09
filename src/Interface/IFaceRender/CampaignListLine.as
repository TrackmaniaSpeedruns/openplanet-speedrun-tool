namespace IfaceRender
{
    void CampaignListLine(CampaignSummary@ campaign)
    {
        UI::TableNextRow();

        UI::TableSetColumnIndex(0);
        UI::Text(ColoredString(campaign.name));

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