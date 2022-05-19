class FavoritesSWTab : SWTab
{
    Net::HttpRequest@ m_request;
    array<CampaignSummary@> campaigns;

    string GetLabel() override { return Icons::Heart; }
    string GetTooltip() override { return "Favorites"; }

    vec4 GetColor() override { return vec4(1, 0.4, 0.4, 1); }

    bool IsVisible() override { return DataJson["favoriteCampaigns"].Length > 0 || DataJson["favoritePlaylists"].Length > 0; }

    void StartRequest()
    {
        string url = "https://trackmania.io/api/campaigns/0";
        @m_request = API::Get(url);
    }

    void CheckStartRequest()
    {
        // If there's not already a request and the window is appearing, we start a new request
        if (campaigns.Length == 0 && m_request is null && UI::IsWindowAppearing()) {
            StartRequest();
        }
    }

    void CheckRequest()
    {
        CheckStartRequest();

        // If there's a request, check if it has finished
        if (m_request !is null && m_request.Finished()) {
            // Parse the response
            string res = m_request.String();
            if (IS_DEV_MODE) trace("FavoritesSWTab::CheckRequest: " + res);
            @m_request = null;
            auto json = Json::Parse(res);

            if (json.GetType() == Json::Type::Null) {
                // handle error
                return;
            }

            // Handle the response
            if (json.HasKey("error")) {
                //HandleErrorResponse(json["error"]);
            } else {
                HandleResponse(json);
            }
        }
    }

    void HandleResponse(const Json::Value &in json)
    {
        auto items = json["campaigns"];
        for (uint i = 0; i < items.Length; i++) {
            campaigns.InsertLast(CampaignSummary(items[i]));
        }
    }

    void Render() override
    {
        CheckRequest();
        if (m_request !is null && campaigns.Length == 0) {
            int HourGlassValue = Time::Stamp % 3;
            string Hourglass = (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
            UI::Text(Hourglass + " Loading...");
        } else {
            UI::Columns(2, "ColumsFavoritesTab");
            UI::BeginChild("SingleCampaigns");
            UI::Text("Campaigns :");
            if (DataJson["favoriteCampaigns"].Length == 0) UI::Text("No favorite campaigns");
            else {
                for (uint c = 0; c < DataJson["favoriteCampaigns"].Length; c++)
                {
                    bool isSelected = false;
                    CampaignSummary@ favCampaign = CampaignSummary(DataJson["favoriteCampaigns"][c]);

                    // permissions check
                    if (
                        !Permissions::PlayPastOfficialQuarterlyCampaign() &&
                        favCampaign.type == Campaigns::campaignType::Season &&
                        favCampaign.id != campaigns[0].id  // Check if the ID is not the first on the campaign list from tmio (another season)
                    ) {
                        DataJson["favoriteCampaigns"].Remove(c);
                        DataManager::Save();
                    }
                    if (
                        !Permissions::PlayCurrentOfficialQuarterlyCampaign() &&
                        favCampaign.type == Campaigns::campaignType::Season &&
                        favCampaign.id == campaigns[0].id  // Check if the ID is the first on the campaign list from tmio (current season)
                    ) {
                        DataJson["favoriteCampaigns"].Remove(c);
                        DataManager::Save();
                    }
                    if (
                        !Permissions::PlayPublicClubCampaign() &&
                        favCampaign.type == Campaigns::campaignType::Club
                    ) {
                        DataJson["favoriteCampaigns"].Remove(c);
                        DataManager::Save();
                    }

                    if (favCampaign.type == Campaigns::campaignType::TOTD) {
                        int current_month = Text::ParseInt(Time::FormatString("%m"));
                        int current_year = Text::ParseInt(Time::FormatString("%Y"));
                        auto diff = current_month - 7 + (12 * (current_year - 2020));
                        current_month--;
                        for(int i = diff; i > 0; i--) {
                            if (i == diff && !Permissions::PlayCurrentOfficialMonthlyCampaign())
                            {
                                DataJson["favoriteCampaigns"].Remove(c);
                                DataManager::Save();
                            }

                            if (i != diff && !Permissions::PlayPastOfficialMonthlyCampaign())
                            {
                                DataJson["favoriteCampaigns"].Remove(c);
                                DataManager::Save();
                            }
                        }
                    }

                    for (uint i = 0; i < g_SpeedrunWindow.selectedCampaigns.Length; i++)
                    {
                        if (g_SpeedrunWindow.selectedCampaigns[i].id == favCampaign.id)
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
                    isSelected = UI::WhiteCheckbox("###SelectCampaign"+favCampaign.id, isSelected);
                    UI::SetPreviousTooltip("Add to current campaigns playlist");
                    if (isSelected) g_SpeedrunWindow.selectedCampaigns.InsertLast(favCampaign);
                    UI::SameLine();
                    UI::Text(ColoredString(favCampaign.name));
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
                            CampaignSummary@ favPlaylistCampaign = CampaignSummary(DataJson["favoritePlaylists"][p]["campaigns"][pc]);
                            // permissions check
                            if (
                                !Permissions::PlayPastOfficialQuarterlyCampaign() &&
                                favPlaylistCampaign.type == Campaigns::campaignType::Season &&
                                favPlaylistCampaign.id != campaigns[0].id  // Check if the ID is not the first on the campaign list from tmio (another season)
                            ) {
                                DataJson["favoritePlaylists"][p]["campaigns"].Remove(pc);
                                DataManager::Save();
                            }
                            if (
                                !Permissions::PlayCurrentOfficialQuarterlyCampaign() &&
                                favPlaylistCampaign.type == Campaigns::campaignType::Season &&
                                favPlaylistCampaign.id == campaigns[0].id  // Check if the ID is the first on the campaign list from tmio (current season)
                            ) {
                                DataJson["favoritePlaylists"][p]["campaigns"].Remove(pc);
                                DataManager::Save();
                            }
                            if (
                                !Permissions::PlayPublicClubCampaign() &&
                                favPlaylistCampaign.type == Campaigns::campaignType::Club
                            ) {
                                DataJson["favoritePlaylists"][p]["campaigns"].Remove(pc);
                                DataManager::Save();
                            }

                            if (favPlaylistCampaign.type == Campaigns::campaignType::TOTD) {
                                int current_month = Text::ParseInt(Time::FormatString("%m"));
                                int current_year = Text::ParseInt(Time::FormatString("%Y"));
                                auto diff = current_month - 7 + (12 * (current_year - 2020));
                                current_month--;
                                for(int i = diff; i > 0; i--) {
                                    if (i == diff && !Permissions::PlayCurrentOfficialMonthlyCampaign())
                                    {
                                        DataJson["favoritePlaylists"][p]["campaigns"].Remove(pc);
                                        DataManager::Save();
                                    }

                                    if (i != diff && !Permissions::PlayPastOfficialMonthlyCampaign())
                                    {
                                        DataJson["favoritePlaylists"][p]["campaigns"].Remove(pc);
                                        DataManager::Save();
                                    }
                                }
                            }

                            g_SpeedrunWindow.selectedCampaigns.InsertLast(favPlaylistCampaign);
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
}