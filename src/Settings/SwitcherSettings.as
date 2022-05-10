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

    [SettingsTab name="Map Switcher"]
    void RenderSwitcherSettings()
    {
        // SwitcherPreloadCache = UI::WhiteCheckbox("Preload Cache", SwitcherPreloadCache);
        SwitcherAutoloadNextMap = UI::WhiteCheckbox("Auto skip to Next Map (recommended)", SwitcherAutoloadNextMap);
        UI::Text("Split on medal:");
        UI::SameLine();
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
        WriteSpeedrunLog = UI::WhiteCheckbox("Output speedruns log files", WriteSpeedrunLog);
        UI::SetPreviousTooltip("You can find your log files in " + IO::FromUserGameFolder("Speedruns"));
    }
}