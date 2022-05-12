class Speedrun
{
    bool IsRunning = false;
    bool firstMap = false;
    bool actualMapCompleted = false;
    bool logInitialized = false;
    string logFileName = "";
    string logFileCode = "";
    string actualSpeedrunPath = "";
    int mapCounter = 0;
    int resetCounter = 0;
    int MapCompleteTime = 0;
    int SumCompleteTime = 0;
    int SumCompleteTimeWithRespawns = 0;

    Campaigns::campaignType currentCampaignType = Campaigns::campaignType::Unknown;

    CampaignSummary@ currentCampaign;
    array<CampaignSummary@> pastCampaigns;

    array<MapInfo@> mapPlaylist;

    CGameDataFileManagerScript@ gameDataFileManager;
    CSmArenaRulesMode@ playgroundScript;

    PlayerState::sTMData@ TMData;

    void Update(float dt)
    {
        if (IsRunning)
        {
            @TMData = PlayerState::GetRaceData();
            if (TMData.dEventInfo.PlayerStateChange)
            {
                if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_EndRace)
                {
                    if (!TMData.dEventInfo.FinishRun)
                    {
                        if (g_speedrun.firstMap)
                            SumCompleteTimeWithRespawns == 0;
                        else
                        {
                            MapCompleteTime = TMData.dPlayerInfo.CurrentRaceTime;
                            SumCompleteTimeWithRespawns += TMData.dPlayerInfo.CurrentRaceTime;
                            resetCounter++;
                            if (logInitialized)
                                WriteSpeedrunLog(true);
                        }
                    }
                }
            }

            if (TMData.dEventInfo.FinishRun)
            {
                if (actualMapCompleted) //if actual map is already completed (finish 2nd time on same map)
                {
                    UI::ShowNotification("Map already completed");
                    return;
                }

                MapCompleteTime = TMData.dPlayerInfo.EndTime;
                SumCompleteTime += MapCompleteTime;
                SumCompleteTimeWithRespawns += MapCompleteTime;

                if (logInitialized)
                    WriteSpeedrunLog();

                if (PluginSettings::CreateReplayOnFinishMap)
                    CreateReplay();

                if (PluginSettings::SwitcherNextMapOnMedal != Speedrun::Medals[0])
                {
                    int author = TMData.dMapInfo.TMObjective_AuthorTime;
                    int gold = TMData.dMapInfo.TMObjective_GoldTime;
                    int silver = TMData.dMapInfo.TMObjective_SilverTime;
                    int bronze = TMData.dMapInfo.TMObjective_BronzeTime;
                    if (
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[4] && MapCompleteTime <= author) ||
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[3] && MapCompleteTime <= gold) ||
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[2] && MapCompleteTime <= silver) ||
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[1] && MapCompleteTime <= bronze)
                    )
                    {
                        if (PluginSettings::SwitcherAutoloadNextMap)
                            startnew(Speedrun::NextMap);
                        else
                        {
                            actualMapCompleted = true;
                            firstMap = false; // don't reset timer
                            UI::ShowNotification("Map completed", "Use the button 'next map' on the menu to load the next map");
                        }
                    }
                }
                else
                {
                    if (PluginSettings::SwitcherAutoloadNextMap)
                        startnew(Speedrun::NextMap);
                    else
                    {
                        actualMapCompleted = true;
                        firstMap = false;
                        UI::ShowNotification("Map completed", "Use the button 'next map' on the menu to load the next map");
                    }
                }
            }

            if (g_LiveSplit !is null && g_LiveSplit.connected)
                LiveSplitUpdateLoop();
        }
        else
        {
            currentCampaignType = Campaigns::campaignType::Unknown;
            MapCompleteTime = 0;
            SumCompleteTime = 0;
            SumCompleteTimeWithRespawns = 0;
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
                        g_LiveSplit.setgametime(0);
                        g_LiveSplit.resume();
                    }
                }
                else
                    g_LiveSplit.resume();
            }

            if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Finished)
                g_LiveSplit.pause();

            if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Countdown)
            {
                if (g_speedrun.firstMap)
                    g_LiveSplit.reset();
                else
                    g_LiveSplit.pause();
            }
        }

        if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Menus)
            g_LiveSplit.pause();

        if (g_speedrun.TMData.IsSpectator)
            g_LiveSplit.pause();

        if (
            (TMData.dEventInfo.FinishRun && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[0]) ||
            (TMData.dEventInfo.FinishRun && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[2] && !TMData.dMapInfo.bIsMultiLap)
        )
        {
            if (PluginSettings::SwitcherNextMapOnMedal != Speedrun::Medals[0])
            {
                int author = TMData.dMapInfo.TMObjective_AuthorTime;
                int gold = TMData.dMapInfo.TMObjective_GoldTime;
                int silver = TMData.dMapInfo.TMObjective_SilverTime;
                int bronze = TMData.dMapInfo.TMObjective_BronzeTime;
                if (
                    !actualMapCompleted && (
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[4] && MapCompleteTime <= author) ||
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[3] && MapCompleteTime <= gold) ||
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[2] && MapCompleteTime <= silver) ||
                        (PluginSettings::SwitcherNextMapOnMedal == Speedrun::Medals[1] && MapCompleteTime <= bronze)
                    )
                )
                    g_LiveSplit.split();
            }
            else
            {
                if (!actualMapCompleted) g_LiveSplit.split();
            }
        }

        if (TMData.dEventInfo.CheckpointChange && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[1])
            g_LiveSplit.split();

        if (TMData.dMapInfo.bIsMultiLap && TMData.dEventInfo.LapChange && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[2])
            g_LiveSplit.split();

        if (TMData.dEventInfo.PauseChange)
        {
            if (TMData.IsPaused)
                g_LiveSplit.pause();
            else
                g_LiveSplit.resume();
        }
    }

    void InitSpeedrunPath()
    {
        string speedrunPath = IO::FromUserGameFolder("Speedruns");
        if (!IO::FolderExists(speedrunPath)) IO::CreateFolder(speedrunPath);
        actualSpeedrunPath = speedrunPath + "/" + Time::FormatString("%F_%H-%M-%S");
        if (!IO::FolderExists(actualSpeedrunPath)) IO::CreateFolder(actualSpeedrunPath);
    }

    void InitSpeedrunLog(bool newFile = true)
    {
        if (newFile)
        {
            array<string> base36Chars = "0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z".Split(",");
            int64 gameReleaseTimestamp = 1593558000;
            int64 stampDiffSeconds = Time::Stamp - gameReleaseTimestamp;
            int minutesDateTime = stampDiffSeconds / 60;
            string base36DateTime = "";
            while(minutesDateTime > 0) {
                base36DateTime = base36Chars[minutesDateTime % 36] + base36DateTime;
                print(base36DateTime + " - " + minutesDateTime);
                minutesDateTime /= 36;
            }
            logFileCode = PadLeft(base36DateTime, 5, "_");
            logFileName = actualSpeedrunPath + "/" + logFileCode + ".txt";
        }

        IO::File file(logFileName);
        file.Open(IO::FileMode::Append);
        if (!newFile) file.WriteLine();
        file.WriteLine("Trackmania - " + StripFormatCodes(currentCampaign.name) + " - started at " + Time::FormatString("%F %T"));
        file.WriteLine();
        file.WriteLine("Sum | Segment | Track");
	    file.Close();
        logInitialized = true;
    }

    void WriteSpeedrunLog(bool isReset = false)
    {
        IO::File file(logFileName);
        file.Open(IO::FileMode::Append);
        string line = Speedrun::FormatTimer(SumCompleteTimeWithRespawns) + " | " + Speedrun::FormatTimer(MapCompleteTime) + " | " + StripFormatCodes(TMData.dMapInfo.MapName) + (isReset ? (" (Reset "+resetCounter+")") : "");
        print(line);
        file.WriteLine(line);
	    file.Close();
    }

    void EndOfFileLog()
    {
        IO::File file(logFileName);
        file.Open(IO::FileMode::Append);
        file.WriteLine();
        file.WriteLine("End of speedrun at " + Time::FormatString("%F %T"));
	    file.Close();
        IO::Move(logFileName, actualSpeedrunPath + "/" + logFileCode+"_"+Speedrun::FormatTimer(SumCompleteTime).Replace(":", ".") + ".txt");
    }

    void CreateReplay()
    {
        @gameDataFileManager = TryGetDataFileMgr();
        @playgroundScript = TryGetPlaygroundScript();
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        CGamePlayground@ GamePlayground = cast<CGamePlayground>(app.CurrentPlayground);
        if (app.RootMap !is null)
        {
            if (playgroundScript !is null && GamePlayground.GameTerminals.get_Length() > 0)
            {
                CSmPlayer@ player = cast<CSmPlayer>(GamePlayground.GameTerminals[0].ControlledPlayer);
                if (player !is null)
                {
                    CSmScriptPlayer@ playerScriptAPI = cast<CSmScriptPlayer>(player.ScriptAPI);
                    if (playerScriptAPI !is null)
                    {
                        auto ghost = playgroundScript.Ghost_RetrieveFromPlayer(playerScriptAPI);
                        if (ghost !is null)
                        {
                            string safeMapName = StripFormatCodes(app.RootMap.MapName);
                            string safeUserName = ghost.Nickname;
                            string fmtGhostTime = Speedrun::FormatTimer(ghost.Result.Time).Replace(":", "-");
                            string replayName = mapCounter + " - " + safeMapName + " - " + safeUserName + " - " + Time::FormatString("%F_%H-%M-%S") + " (" + fmtGhostTime + ")";

                            string replayPath = actualSpeedrunPath + "/" + replayName;
                            gameDataFileManager.Replay_Save(replayPath, app.RootMap, ghost);
                            playgroundScript.DataFileMgr.Ghost_Release(ghost.Id);
                        } else UI::ShowNotification("Error: replay cannot be created for this run");
                    } else UI::ShowNotification("Error: replay cannot be created for this run");
                } else UI::ShowNotification("Error: replay cannot be created for this run");
            } else UI::ShowNotification("Error: replay cannot be created for this run");
        } else UI::ShowNotification("Error: replay cannot be created for this run");
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
        g_speedrun.pastCampaigns.InsertLast(campaign);
        g_SpeedrunWindow.selectedCampaigns.RemoveAt(0);
        UI::HideOverlay();
        ClosePauseMenu();
        CTrackMania@ app = cast<CTrackMania>(GetApp());
        app.BackToMainMenu();
        while(!app.ManiaTitleControlScriptAPI.IsReady) {
            yield();
        }
        UI::ShowNotification("Loading map...", ColoredString(g_speedrun.mapPlaylist[0].name));
        g_speedrun.mapCounter = 1;
        app.ManiaTitleControlScriptAPI.PlayMap(g_speedrun.mapPlaylist[0].file_url, "", "");
        g_speedrun.mapPlaylist.RemoveAt(0);

        g_speedrun.InitSpeedrunPath();

        if (PluginSettings::WriteSpeedrunLog)
            g_speedrun.InitSpeedrunLog(true);
    }

    void NextMap()
    {
        g_speedrun.firstMap = false;
        g_speedrun.actualMapCompleted = false;
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
            g_speedrun.mapCounter++;
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
                g_speedrun.pastCampaigns.InsertLast(campaign);
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

    void RestartSpeedrun()
    {
        // remove all maps from queue
        g_speedrun.mapPlaylist.RemoveRange(0, g_speedrun.mapPlaylist.Length);

        // Take all pased campaigns and put them back in the campaign list
        for (uint i = 0; i < g_speedrun.pastCampaigns.Length; i++)
        {
            g_SpeedrunWindow.selectedCampaigns.InsertAt(i, g_speedrun.pastCampaigns[i]);
            g_speedrun.pastCampaigns.RemoveAt(i);
        }
        startnew(StartSpeedrun);
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
                    newmap.author = dayJson["map"]["authorplayer"]["name"];
                    newmap.name = dayJson["map"]["name"];
                    newmap.filename = dayJson["map"]["filename"];
                    newmap.uid = dayJson["map"]["mapUid"];
                    newmap.file_url = dayJson["map"]["fileUrl"];
                    newmap.exchange_id = dayJson["map"]["exchangeid"];
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