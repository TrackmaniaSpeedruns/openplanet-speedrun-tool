class FavoritesSWTab : SWTab
{
    string GetLabel() override { return Icons::Heart; }
    string GetTooltip() override { return "Favorites"; }

    vec4 GetColor() override { return vec4(1, 0.4, 0.4, 1); }

    bool IsVisible() override { return DataJson["favoriteCampaigns"].Length > 0 || DataJson["favoritePlaylists"].Length > 0; }

    void Render() override
    {
        UI::Columns(2, "ColumsFavoritesTab");
        UI::BeginChild("SingleCampaigns");
        UI::Text("Campaigns :");
        if (DataJson["favoriteCampaigns"].Length == 0) UI::Text("No favorite campaigns");
        else {
            for (uint c = 0; c < DataJson["favoriteCampaigns"].Length; c++)
            {
                bool isSelected = false;
                CampaignSummary@ campaign = CampaignSummary(DataJson["favoriteCampaigns"][c]);
                for (uint i = 0; i < g_SpeedrunWindow.selectedCampaigns.Length; i++)
                {
                    if (g_SpeedrunWindow.selectedCampaigns[i].id == campaign.id)
                    {
                        if (!isSelected) g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
                        isSelected = true;
                        break;
                    }
                }
                UI::PushID("FavCampaign"+c);
                if (UI::RedButton(Icons::Times))
                {
                    DataJson["favoriteCampaigns"].Remove(c);
                    DataManager::Save();
                }
                UI::SetPreviousTooltip("Delete from favorites");
                UI::SameLine();
                UI::Text(ColoredString(campaign.name));
                UI::SameLine();
                isSelected = UI::WhiteCheckbox("###SelectCampaign"+campaign.id, isSelected);
                UI::SetPreviousTooltip("Add to current campaigns playlist");
                if (isSelected) g_SpeedrunWindow.selectedCampaigns.InsertLast(campaign);
                UI::PopID();
            }
        }
        UI::EndChild();
        UI::NextColumn();
        UI::BeginChild("Playlists");
        UI::Text("Playlists :");
        if (DataJson["favoritePlaylists"].Length == 0) UI::Text("No favorite playlists");
        else {
            for (uint p = 0; p < DataJson["favoritePlaylists"].Length; p++)
            {
                string playlistName =  DataJson["favoritePlaylists"][p]["name"];
                string campaignsName = "";
                for (uint pc = 0; pc < DataJson["favoritePlaylists"][p]["campaigns"].Length; pc++)
                {
                    string cName = DataJson["favoritePlaylists"][p]["campaigns"][pc]["name"];
                    campaignsName = campaignsName + "- " + cName + "\n";
                }
                UI::PushID("FavPlaylist"+p);
                if (UI::RedButton(Icons::Times))
                {
                    DataJson["favoritePlaylists"].Remove(p);
                    DataManager::Save();
                }
                UI::SetPreviousTooltip("Delete from favorites");
                UI::SameLine();
                if (UI::Button(Icons::Plus)) {
                    for (uint pc = 0; pc < DataJson["favoritePlaylists"][p]["campaigns"].Length; pc++)
                    {
                        CampaignSummary@ campaign = CampaignSummary(DataJson["favoritePlaylists"][p]["campaigns"][pc]);
                        g_SpeedrunWindow.selectedCampaigns.InsertLast(campaign);
                    }
                    UI::ShowNotification(DataJson["favoritePlaylists"][p]["campaigns"].Length + " campaigns added to selection");
                }
                UI::SetPreviousTooltip("Add playlist to selection");
                UI::SameLine();
                UI::Text(ColoredString(playlistName));
                UI::SetPreviousTooltip(campaignsName);
                UI::PopID();
            }
        }
        UI::EndChild();
    }
}