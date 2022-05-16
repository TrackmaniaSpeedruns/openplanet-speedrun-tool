class SpeedrunStatusTab : SWTab
{

    string GetLabel() { return PLUGIN_ICON + " Status"; }

    vec4 GetColor() { return vec4(0.6, 0.6, 0.6, 1); }

    bool CheckLiveSplit()
    {
        bool isOK = true;
        if (PluginSettings::LiveSplitClientEnabled)
        {
            if (g_LiveSplit is null)
            {
                isOK = false;
            }
            else
            {
                if (!g_LiveSplit.connected)
                {
                    Renderables::Add(LiveSplitDisconnectWarnModalDialog());
                    isOK = false;
                }
            }
        }
        return isOK;
    }

    void Render() override
    {
        if (g_speedrun.IsRunning)
        {
            if (UI::CyanButton(Icons::AngleDoubleRight + " Next map"))
            {
                if (g_LiveSplit !is null && g_LiveSplit.connected)
                {
                    if (g_speedrun.actualMapCompleted)
                    {
                        g_LiveSplit.setgametime(Speedrun::FormatTimer(g_speedrun.SumCompleteTimeWithRespawns));
                        g_LiveSplit.split();
                    }
                    else g_LiveSplit.skipsplit();
                }
                startnew(Speedrun::NextMap);
            }
            UI::SameLine();
            if (UI::RedButton(Icons::Times + " Stop speedrun"))
            {
                if (g_LiveSplit !is null && g_LiveSplit.connected)
                    g_LiveSplit.reset();
                g_speedrun.IsRunning = false;
            }
            UI::SameLine();
            if (UI::OrangeButton(Icons::Refresh + " Restart speedrun (Shift+Del)"))
            {
                if (g_LiveSplit !is null && g_LiveSplit.connected)
                    g_LiveSplit.reset();
                Speedrun::RestartSpeedrun();
            }
        }
        else
        {
            if (g_SpeedrunWindow.selectedCampaigns.Length == 0)
            {
                UI::Text("No campaigns selected, please select campaigns in the tabs above");
            }
            else
            {
                if (PluginSettings::SwitcherPreloadCache)
                {
                    if (UI::GreenButton(Icons::Play + " Start preloading cache"))
                    {
                        if (!CheckLiveSplit()) return;
                        print("Starting preload cache");
                    }
                }
                else
                {
                    if (UI::GreenButton(Icons::Play + " Start speedrun"))
                    {
                        if (!CheckLiveSplit()) return;
                        print("Starting speedrun");
                        startnew(Speedrun::StartSpeedrun);
                    }
                }
                if (g_LiveSplit is null)
                {
                    UI::SameLine();
                    if (PluginSettings::LiveSplitClientEnabled)
                        UI::Text("\\$f00"+Icons::Times+" \\$zLiveSplit client is not loaded, please wait...");
                    else
                    {
                        UI::Text("\\$ff0" + Icons::InfoCircle + " \\$zLiveSplit client is disabled");
                        UI::SameLine();
                        if (UI::CyanButton("Enable LiveSplit"))
                            PluginSettings::LiveSplitClientEnabled = true;
                    }
                }
                if (g_LiveSplit !is null && !g_LiveSplit.connected)
                {
                    UI::SameLine();
                    UI::Text("\\$f90" + Icons::ExclamationTriangle + " \\$zLiveSplit client is not connected to the app");
                    UI::SameLine();
                    if (UI::CyanButton(Icons::Refresh + " Retry"))
                        startnew(PluginSettings::RestartLiveSplitClient);
                    UI::SameLine();
                    if (UI::OrangeButton("Disable LiveSplit"))
                        PluginSettings::LiveSplitClientEnabled = false;
                }
            }
        }

        UI::Separator();

        UI::Columns(2, "ColumsStartTab");
        UI::BeginChild("Campaigns");
        if (g_SpeedrunWindow.selectedCampaigns.Length == 1) UI::Text("Campaign:");
        else
        {
            if (g_SpeedrunWindow.selectedCampaigns.Length < 1) UI::Text("No campaigns selected");
            else UI::Text("Campaigns order ("+g_SpeedrunWindow.selectedCampaigns.Length+"):");
        }

        for (uint i = 0; i < g_SpeedrunWindow.selectedCampaigns.Length; i++)
        {
			CampaignSummary@ campaign = g_SpeedrunWindow.selectedCampaigns[i];
            UI::PushID("CampaignOrderLine"+i);
            if (g_SpeedrunWindow.selectedCampaigns.Length > 1)
            {
                if (UI::Button(Icons::AngleUp))
                {
                    g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
                    g_SpeedrunWindow.selectedCampaigns.InsertAt(Math::Max(0, i-1), campaign);
                }
                UI::SameLine();
                if (UI::Button(Icons::AngleDown))
                {
                    g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
                    g_SpeedrunWindow.selectedCampaigns.InsertAt(Math::Min(g_SpeedrunWindow.selectedCampaigns.Length, i+1), campaign);
                }
                UI::SameLine();
            }
			if (UI::RedButton(Icons::Times))
            {
                g_SpeedrunWindow.selectedCampaigns.RemoveAt(i);
            }
			UI::SameLine();
			UI::Text(ColoredString(campaign.name));
			UI::PopID();
		}
        UI::EndChild();
        UI::NextColumn();
        UI::BeginChild("SpeedrunSettings");
        UI::Text("Speedrun Settings:");
        PluginSettings::RenderSpeedrunSettings();
        UI::EndChild();
    }
}