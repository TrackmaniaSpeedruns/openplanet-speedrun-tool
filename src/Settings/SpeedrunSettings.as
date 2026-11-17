namespace PluginSettings
{
    [Setting hidden]
    bool SwitcherPreloadCache = false;

    [Setting hidden]
    bool HideUIOnLoadMap = true;

    [Setting hidden]
    bool SwitcherAutoloadNextMap = true;

    [Setting hidden]
    bool WriteSpeedrunLog = true;

    [Setting hidden]
    bool CreateReplayOnFinishMap = true;

    [Setting hidden]
    string SwitcherNextMapOnMedal = Speedrun::Medals[0];

    array<string> LiveSplitSplitOnSettings = {
        "Finish",
        "Checkpoint",
        "Lap",
        "No split"
    };

    array<string> SpeedrunModes = {
        "Normal"
#if DEPENDENCY_CHAOSMODE
        ,"Chaos Mode"
#endif
    };

    [Setting hidden]
    string SpeedrunMode = SpeedrunModes[0];

    [Setting hidden]
    string LiveSplitSplitOn = LiveSplitSplitOnSettings[0];

    [SettingsTab name="Speedrun"]
    void RenderSpeedrunSettings()
    {
        string speedrunPath = IO::FromUserGameFolder("Speedruns");

        // SwitcherPreloadCache = UI::WhiteCheckbox("Preload Cache", SwitcherPreloadCache);
        SwitcherAutoloadNextMap = UI::WhiteCheckbox("Auto skip to Next Map (recommended)", SwitcherAutoloadNextMap);
        HideUIOnLoadMap = UI::WhiteCheckbox("Hide Openplanet UI on map loading", HideUIOnLoadMap);
        WriteSpeedrunLog = UI::WhiteCheckbox("Output speedruns log files", WriteSpeedrunLog);
        UI::SetPreviousTooltip("You can find your log files in " + speedrunPath);

        if (UI::CyanButton(Icons::FolderO + " Open Speedruns folder")) {
            if (!IO::FolderExists(speedrunPath)) IO::CreateFolder(speedrunPath);
            OpenExplorerPath(speedrunPath);
        }

        CreateReplayOnFinishMap = UI::WhiteCheckbox("Create replays", CreateReplayOnFinishMap);

        if ((g_LiveSplit !is null && g_LiveSplit.connected) || SwitcherAutoloadNextMap)
        {
            if (g_LiveSplit !is null && g_LiveSplit.connected) UI::Text("Split on medal:");
            else UI::Text("Skip on medal:");
            UI::SameLine();
            UI::SetNextItemWidth(120);
            if (UI::BeginCombo("###MedalSkipOptionCombo", SwitcherNextMapOnMedal)){
                for (uint i = 0; i < Speedrun::Medals.Length; i++) {
                    string medal = Speedrun::Medals[i];

                    if (UI::Selectable(medal, SwitcherNextMapOnMedal == medal)) {
                        SwitcherNextMapOnMedal = medal;
                    }

                    if (SwitcherNextMapOnMedal == medal) {
                        UI::SetItemDefaultFocus();
                    }
                }
                UI::EndCombo();
            }
        }

        if (g_LiveSplit !is null && g_LiveSplit.connected)
        {
            UI::Text("Split at every");
            UI::SameLine();
            UI::SetNextItemWidth(120);
            if (UI::BeginCombo("###SplitOptionCombo", LiveSplitSplitOn)){
                for (uint i = 0; i < LiveSplitSplitOnSettings.Length; i++) {
                    string split = LiveSplitSplitOnSettings[i];

                    if (UI::Selectable(split, LiveSplitSplitOn == split)) {
                        LiveSplitSplitOn = split;
                    }

                    if (LiveSplitSplitOn == split) {
                        UI::SetItemDefaultFocus();
                    }
                }
                UI::EndCombo();
            }
        }

        UI::Text("Speedrun mode:");
        UI::SameLine();
        UI::SetNextItemWidth(140);
        if (UI::BeginCombo("###SpeedrunModeOptionCombo", SpeedrunMode)){
            for (uint i = 0; i < SpeedrunModes.Length; i++) {
                string mode = SpeedrunModes[i];

                if (UI::Selectable(mode, SpeedrunMode == mode)) {
                    SpeedrunMode = mode;
                }

                if (SpeedrunMode == mode) {
                    UI::SetItemDefaultFocus();
                }
            }
            UI::EndCombo();
        }
#if !DEPENDENCY_CHAOSMODE
        if (SpeedrunMode == "Chaos Mode") {
            SpeedrunMode = SpeedrunModes[0];
        }
#endif
    }
}