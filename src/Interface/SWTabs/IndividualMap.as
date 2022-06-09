class IndividualMapTab : SWTab
{
    string GetLabel() { return Icons::Map; }
    string GetTooltip() override { return "Individual Map"; }

    vec4 GetColor() { return vec4(1, 0, 0.76, 1); }

    bool IsVisible() override { return GetApp().RootMap !is null; }

    void Render() override
    {
        CGameCtnChallenge@ Map = cast<CGameCtnChallenge>(GetApp().RootMap);
        UI::Columns(2, "ColumsMapTab");
        UI::BeginChild("Map");
        UI::Text(ColoredString(Map.MapName));
        UI::Text("by " + Map.AuthorNickName);
        UI::NewLine();
        if (g_LiveSplit !is null && g_LiveSplit.connected)
        {
            UI::Text("Split at every");
            UI::SameLine();
            UI::SetNextItemWidth(120);
            if (UI::BeginCombo("###SplitOptionCombo", PluginSettings::LiveSplitSplitOn)){
                for (uint i = 0; i < PluginSettings::LiveSplitSplitOnSettings.Length; i++) {
                    string split = PluginSettings::LiveSplitSplitOnSettings[i];

                    if (UI::Selectable(split, PluginSettings::LiveSplitSplitOn == split)) {
                        PluginSettings::LiveSplitSplitOn = split;
                    }

                    if (PluginSettings::LiveSplitSplitOn == split) {
                        UI::SetItemDefaultFocus();
                    }
                }
                UI::EndCombo();
            }
            UI::NewLine();
            if (!g_speedrun.IsRunning) {
                if (UI::GreenButton(Icons::Play)) {
                    Speedrun::StartSpeedrunSingleMap();
                }
            }
            else {
                if (!g_speedrun.isSingleMap)
                    UI::Text("Please stop the actual speedrun before starting a new one");
                else {
                    if (UI::RedButton(Icons::Times)) {
                        Speedrun::StopSpeedrunSingleMap();
                    }
                }
            }
        } else {
            UI::Text("\\$f00"+Icons::Times+" \\$zLiveSplit is not connected, check details at the right column");
        }
        UI::EndChild();
        UI::NextColumn();
        UI::BeginChild("SpeedrunSettings");
        PluginSettings::RenderLiveSplitSettings();
        UI::EndChild();
    }
}