class Speedrun
{
    bool IsRunning = false;
    bool firstMap = false;
    bool logInitialized = false;
    string logFileName = "";
    int MapCompleteTime = 0;
    int SumCompleteTime = 0;

    Campaigns::campaignType currentCampaignType = Campaigns::campaignType::Unknown;

    CampaignSummary@ currentCampaign;

    array<MapInfo@> mapPlaylist;

    PlayerState::sTMData@ TMData;

    void Update(float dt)
    {
        if (IsRunning)
        {
            @TMData = PlayerState::GetRaceData();
            if (TMData.dEventInfo.FinishRun)
            {
                MapCompleteTime = TMData.dPlayerInfo.EndTime;
                SumCompleteTime += MapCompleteTime;

                if (logInitialized)
                    WriteSpeedrunLog();

                if (PluginSettings::SwitcherAutoloadNextMap)
                {
                    if (PluginSettings::SwitcherNextMapOnMedal != Speedrun::Medals[0])
                    {
                        int author = TMData.dMapInfo.TMObjective_AuthorTime;
                        int gold = TMData.dMapInfo.TMObjective_GoldTime;
                        int silver = TMData.dMapInfo.TMObjective_SilverTime;
                        int bronze = TMData.dMapInfo.TMObjective_BronzeTime;
                        if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[4] && MapCompleteTime <= author)
                            startnew(Speedrun::NextMap);
                        else if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[3] && MapCompleteTime <= gold)
                            startnew(Speedrun::NextMap);
                        else if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[2] && MapCompleteTime <= silver)
                            startnew(Speedrun::NextMap);
                        else if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[1] && MapCompleteTime <= bronze)
                            startnew(Speedrun::NextMap);
                    }
                    else startnew(Speedrun::NextMap);
                }
            }

            if (g_LiveSplit !is null)
                LiveSplitUpdateLoop();
        }
        else
        {
            currentCampaignType = Campaigns::campaignType::Unknown;
            MapCompleteTime = 0;
            SumCompleteTime = 0;
            logInitialized = false;
            if (mapPlaylist.Length > 0) mapPlaylist.RemoveRange(0, mapPlaylist.Length);
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
        {
            if (PluginSettings::SwitcherNextMapOnMedal != Speedrun::Medals[0])
            {
                int author = TMData.dMapInfo.TMObjective_AuthorTime;
                int gold = TMData.dMapInfo.TMObjective_GoldTime;
                int silver = TMData.dMapInfo.TMObjective_SilverTime;
                int bronze = TMData.dMapInfo.TMObjective_BronzeTime;
                if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[4] && MapCompleteTime <= author)
                    g_LiveSplit.split();
                else if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[3] && MapCompleteTime <= gold)
                    g_LiveSplit.split();
                else if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[2] && MapCompleteTime <= silver)
                    g_LiveSplit.split();
                else if (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[1] && MapCompleteTime <= bronze)
                    g_LiveSplit.split();
            }
            else g_LiveSplit.split();
        }

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

    void InitSpeedrunLog(bool newFile = true)
    {
        string speedrunPath = IO::FromUserGameFolder("Speedruns");
        if (!IO::FolderExists(speedrunPath)) IO::CreateFolder(speedrunPath);

        if (newFile)
            logFileName = speedrunPath + "/" + Time::FormatString("%F_%H-%M-%S") + ".txt";

        IO::File file(logFileName);
        file.Open(IO::FileMode::Append);
        if (!newFile) file.WriteLine();
        file.WriteLine("Trackmania - " + StripFormatCodes(currentCampaign.name) + " - started at " + Time::FormatString("%F %T"));
        file.WriteLine("(times without respawns)");
        file.WriteLine();
        file.WriteLine("Sum | Segment | Track");
	    file.Close();
        logInitialized = true;
    }

    void WriteSpeedrunLog()
    {
        IO::File file(logFileName);
        file.Open(IO::FileMode::Append);
        file.WriteLine(Speedrun::FormatTimer(SumCompleteTime) + " | " + Speedrun::FormatTimer(MapCompleteTime) + " | " + StripFormatCodes(TMData.dMapInfo.MapName));
	    file.Close();
    }

    void EndOfFileLog()
    {
        IO::File file(logFileName);
        file.Open(IO::FileMode::Append);
        file.WriteLine();
        file.WriteLine("End of speedrun at " + Time::FormatString("%F %T"));
	    file.Close();
    }
}

namespace Speedrun
{

    array<string> Medals = {
        "No medal",
        "Bronze",
        "Silver",
        "Gold",
        "Author"
    };

    void StartSpeedrun()
    {
        g_speedrun.IsRunning = true;
        g_speedrun.firstMap = true;


        CampaignSummary@ campaign = g_SpeedrunWindow.selectedCampaigns[0];
        g_speedrun.currentCampaignType = campaign.type;
        @g_speedrun.currentCampaign = campaign;
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

        if (PluginSettings::WriteSpeedrunLog)
            g_speedrun.InitSpeedrunLog(true);
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
                @g_speedrun.currentCampaign = campaign;
                UI::ShowNotification("Switching to campaign: " + ColoredString(campaign.name));
                FetchCampaign(campaign.id, campaign.clubid);
                g_SpeedrunWindow.selectedCampaigns.RemoveAt(0);
                if (PluginSettings::WriteSpeedrunLog)
                    g_speedrun.InitSpeedrunLog(false);
                NextMap();
            }
            else
            {
                // The end of the speedrun
                UI::ShowNotification("Speedrun finished!");
                if (PluginSettings::WriteSpeedrunLog)
                    g_speedrun.EndOfFileLog();
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

    string FormatTimer(int time) {
        int ms = time % 1000;
        time /= 1000;
        int hours = time / 60 / 60;
        int minutes = (time / 60) % 60;
        int seconds = time % 60;

        string result = "";

        if (hours > 0) {
            result += Text::Format("%02d", hours) + ":";
        }
        if (minutes > 0 || (hours > 0 && minutes < 10)) {
            result += Text::Format("%02d", minutes) + ":";
        }
        result += Text::Format("%02d", seconds) + "." + Text::Format("%03d", ms);

        return result;
    }
}