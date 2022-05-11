namespace PluginSettings
{
    [Setting hidden]
    bool SwitcherPreloadCache = false;

    [Setting hidden]
    bool SwitcherAutoloadNextMap = true;

    [Setting hidden]
    bool WriteSpeedrunLog = true;

    [Setting hidden]
    string SwitcherNextMapOnMedal = Speedrun::Medals[0];

    [Setting hidden]
    bool LiveSplitStartTimerOnSpawn = true;

    array<string> LiveSplitSplitOnSettings = {
        "Finish",
        "Checkpoint",
        "No split"
    };

    [Setting hidden]
    string LiveSplitSplitOn = LiveSplitSplitOnSettings[0];

    [SettingsTab name="Speedrun"]
    void RenderSpeedrunSettings()
    {
        // SwitcherPreloadCache = UI::WhiteCheckbox("Preload Cache", SwitcherPreloadCache);
        SwitcherAutoloadNextMap = UI::WhiteCheckbox("Auto skip to Next Map (recommended)", SwitcherAutoloadNextMap);
        WriteSpeedrunLog = UI::WhiteCheckbox("Output speedruns log files", WriteSpeedrunLog);
        UI::SetPreviousTooltip("You can find your log files in " + IO::FromUserGameFolder("Speedruns"));

        if (g_LiveSplit !is null && g_LiveSplit.connected)
            LiveSplitStartTimerOnSpawn = UI::WhiteCheckbox("Start timer after 3,2,1 countdown", LiveSplitStartTimerOnSpawn);

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