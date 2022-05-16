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
                CampaignSummary@ campaign = CampaignSummary(DataJson["favoriteCampaigns"][c]);
                UI::PushID("FavCampaign"+c);
                if (UI::RedButton(Icons::Times))
                {
                    DataJson["favoriteCampaigns"].Remove(c);
                    DataManager::Save();
                }
                UI::SameLine();
                UI::Text(ColoredString(campaign.name));
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
                UI::SameLine();
                UI::Text(ColoredString(playlistName));
                UI::SetPreviousTooltip(campaignsName);
                UI::PopID();
            }
        }
        UI::EndChild();
    }
}