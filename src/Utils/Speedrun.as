class Speedrun
{
    bool IsRunning = false;
    bool firstMap = false;

    Campaigns::campaignType currentCampaignType = Campaigns::campaignType::Unknown;

    array<MapInfo@> mapPlaylist;

    PlayerState::sTMData@ TMData;

    void Update(float dt)
    {
        if (IsRunning)
        {
            @TMData = PlayerState::GetRaceData();
            if (TMData.dEventInfo.FinishRun && PluginSettings::SwitcherAutoloadNextMap)
                startnew(Speedrun::NextMap);

            if (g_LiveSplit !is null)
                LiveSplitUpdateLoop();
        }
        else
        {
            currentCampaignType = Campaigns::campaignType::Unknown;
        }
    }

    void LiveSplitUpdateLoop()
    {
        if (TMData.dEventInfo.PlayerStateChange)
        {
            if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Driving)
            {
                if (g_speedrun.firstMap)
                {
                    if (PluginSettings::LiveSplitStartTimerOnSpawn)
                    {
                        g_LiveSplit.StartTimer();
                        g_LiveSplit.resume();
                    }
                }
                else
                    g_LiveSplit.resume();
            }

            if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Menus || TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Finished)
                g_LiveSplit.pause();

            if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Countdown)
            {
                if (g_speedrun.firstMap)
                    g_LiveSplit.reset();
                else
                    g_LiveSplit.pause();
            }
        }

        if (TMData.dEventInfo.FinishRun && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[0])
            g_LiveSplit.split();

        if (TMData.dEventInfo.CheckpointChange && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[1])
            g_LiveSplit.split();

        if (TMData.dEventInfo.PauseChange)
        {
            if (TMData.IsPaused)
                g_LiveSplit.pause();
            else
                g_LiveSplit.resume();
        }
    }
}

namespace Speedrun
{
    void StartSpeedrun()
    {
        g_speedrun.IsRunning = true;
        g_speedrun.firstMap = true;


        CampaignSummary@ campaign = g_SpeedrunWindow.selectedCampaigns[0];
        g_speedrun.currentCampaignType = campaign.type;
        FetchCampaign(campaign.id, campaign.clubid);
        g_SpeedrunWindow.selectedCampaigns.RemoveAt(0);
        UI::HideOverlay();
        ClosePauseMenu();
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        app.BackToMainMenu();
        while(!app.ManiaTitleControlScriptAPI.IsReady) {
            yield();
        }
        UI::ShowNotification("Loading map...", ColoredString(g_speedrun.mapPlaylist[0].name));
        app.ManiaTitleControlScriptAPI.PlayMap(g_speedrun.mapPlaylist[0].file_url, "", "");
        g_speedrun.mapPlaylist.RemoveAt(0);
    }

    void NextMap()
    {
        g_speedrun.firstMap = false;
        if (g_speedrun.mapPlaylist.Length > 0)
        {
            ClosePauseMenu();
            CTrackMania@ app = cast<CTrackMania>(GetApp());
            app.BackToMainMenu();
            while(!app.ManiaTitleControlScriptAPI.IsReady) {
                yield();
            }
            UI::ShowNotification("Loading map...", ColoredString(g_speedrun.mapPlaylist[0].name));
            UI::HideOverlay();
            app.ManiaTitleControlScriptAPI.PlayMap(g_speedrun.mapPlaylist[0].file_url, "", "");
            g_speedrun.mapPlaylist.RemoveAt(0);
        }
        else
        {
            // The playlist is empty, check if we have more campaigns
            if (g_SpeedrunWindow.selectedCampaigns.Length > 0)
            {
                CampaignSummary@ campaign = g_SpeedrunWindow.selectedCampaigns[0];
                g_speedrun.currentCampaignType = campaign.type;
                UI::ShowNotification("Switching to campaign: " + ColoredString(campaign.name));
                FetchCampaign(campaign.id, campaign.clubid);
                g_SpeedrunWindow.selectedCampaigns.RemoveAt(0);
                NextMap();
            }
            else
            {
                // The end of the speedrun
                UI::ShowNotification("Speedrun finished!");
                g_speedrun.IsRunning = false;
            }
        }
    }

    void FetchCampaign(int campaignId = 0, int clubId = 0)
    {
        Json::Value tmioRes;
        switch (g_speedrun.currentCampaignType)
        {
			case Campaigns::campaignType::Training :
                print("Training");
                for (uint i = 1; i <= 25; i++) {
                    MapInfo@ newmap = MapInfo();
                    newmap.campaignId = 3;
                    newmap.file_url = "Campaigns\\Training\\Training - " + Text::Format("%02d", i) + ".Map.Gbx";
                    newmap.name = "Training - " + Text::Format("%02d", i);
                    if (IS_DEV_MODE) trace("Adding map: " + StripFormatCodes(newmap.name) + " to speedrun playlist");
                    g_speedrun.mapPlaylist.InsertLast(newmap);
                }
				break;
			case Campaigns::campaignType::Season :
                print("Season");
                tmioRes = API::GetAsync("https://trackmania.io/api/officialcampaign/" + campaignId);

                for (uint i = 0; i < tmioRes["playlist"].Length; i++) {
                    Json::Value mapJson = tmioRes["playlist"][i];
                    MapInfo@ newmap = MapInfo();
                    newmap.campaignId = tmioRes["id"];
                    newmap.author = mapJson["author"];
                    newmap.name = mapJson["name"];
                    newmap.filename = mapJson["filename"];
                    newmap.uid = mapJson["mapUid"];
                    newmap.file_url = mapJson["fileUrl"];
                    newmap.exchange_id = mapJson["exchangeid"];
                    if (IS_DEV_MODE) trace("Adding map: " + StripFormatCodes(newmap.name) + " to speedrun playlist");
                    g_speedrun.mapPlaylist.InsertLast(newmap);
                }
				break;
			case Campaigns::campaignType::TOTD :
                print("TOTD");
                tmioRes = API::GetAsync("https://trackmania.io/api/totd/" + campaignId);

                for (uint i = 0; i < tmioRes["days"].Length; i++) {
                    Json::Value dayJson = tmioRes["days"][i];
                    MapInfo@ newmap = MapInfo();
                    newmap.campaignId = dayJson["campaignid"];
                    newmap.author = dayJson["author"];
                    newmap.name = dayJson["name"];
                    newmap.filename = dayJson["filename"];
                    newmap.uid = dayJson["mapUid"];
                    newmap.file_url = dayJson["fileUrl"];
                    newmap.exchange_id = dayJson["exchangeid"];
                    if (IS_DEV_MODE) trace("Adding TOTD map: " + StripFormatCodes(newmap.name) + " to speedrun playlist");
                    g_speedrun.mapPlaylist.InsertLast(newmap);
                }
				break;
			case Campaigns::campaignType::Club :
                print("Club");
                tmioRes = API::GetAsync("https://trackmania.io/api/campaign/" + clubId + "/" + campaignId);

                for (uint i = 0; i < tmioRes["playlist"].Length; i++) {
                    Json::Value mapJson = tmioRes["playlist"][i];
                    MapInfo@ newmap = MapInfo();
                    newmap.campaignId = tmioRes["id"];
                    newmap.author = mapJson["author"];
                    newmap.name = mapJson["name"];
                    newmap.filename = mapJson["filename"];
                    newmap.uid = mapJson["mapUid"];
                    newmap.file_url = mapJson["fileUrl"];
                    newmap.exchange_id = mapJson["exchangeid"];
                    if (IS_DEV_MODE) trace("Adding map: " + StripFormatCodes(newmap.name) + " to speedrun playlist");
                    g_speedrun.mapPlaylist.InsertLast(newmap);
                }
				break;
			default:
				warn("Unknown campaign type for campaign " + campaignId);
        }
    }
}