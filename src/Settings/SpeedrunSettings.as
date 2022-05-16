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

    [Setting hidden]
    string LiveSplitSplitOn = LiveSplitSplitOnSettings[0];

    [SettingsTab name="Speedrun"]
    void RenderSpeedrunSettings()
    {
        // SwitcherPreloadCache = UI::WhiteCheckbox("Preload Cache", SwitcherPreloadCache);
        SwitcherAutoloadNextMap = UI::WhiteCheckbox("Auto skip to Next Map (recommended)", SwitcherAutoloadNextMap);
        HideUIOnLoadMap = UI::WhiteCheckbox("Hide Openplanet UI on map loading", HideUIOnLoadMap);
        WriteSpeedrunLog = UI::WhiteCheckbox("Output speedruns log files", WriteSpeedrunLog);
        UI::SetPreviousTooltip("You can find your log files in " + IO::FromUserGameFolder("Speedruns"));

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
    }
}