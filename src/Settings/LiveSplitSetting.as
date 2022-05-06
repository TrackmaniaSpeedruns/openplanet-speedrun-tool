namespace PluginSettings
{
    [Setting hidden]
    bool LiveSplitClientEnabled = true;

    [Setting hidden]
    string LiveSplitHost = "localhost";

    [Setting hidden]
    int LiveSplitPort = 16834;

    [Setting hidden]
    bool LiveSplitStartTimerOnSpawn = true;

    array<string> LiveSplitSplitOnSettings = {
        "Finish",
        "Checkpoint",
        "No split"
    };

    [Setting hidden]
    string LiveSplitSplitOn = LiveSplitSplitOnSettings[0];

    [SettingsTab name="LiveSplit"]
    void RenderLiveSplitSettings()
    {
        UI::TextWrapped("This plugin integrates an client that interacts with the LiveSplit application in order to provide a realtime split times, auto splitting, and more.");

        UI::Text("Status:");
        UI::SameLine();
        if (g_LiveSplit !is null)
        {
            if (g_LiveSplit.connected) UI::Text("\\$0f0"+Icons::Check + " \\$zConnected");
            else {
                if (g_LiveSplit.connectTimeout) UI::Text("\\$f00"+Icons::Times + " \\$zCannot connect - Timeout");
                else UI::Text(Icons::Refresh + " Connecting...");
            }
        }
        else
        {
            UI::Text("Disconnected or not initialized");
        }
        UI::Separator();

        // create tabs
        UI::BeginTabBar("LiveSplitSettingsCategoryTabBar", UI::TabBarFlags::FittingPolicyResizeDown);
        if (UI::BeginTabItem(Icons::Kenney::Network + " Connexion Settings"))
        {
            if (UI::OrangeButton("Reset to default"))
            {
                LiveSplitHost = "localhost";
                LiveSplitPort = 16834;
            }
            if (LiveSplitClientEnabled)
            {
                UI::SameLine();
                if (UI::Button(Icons::Refresh + " Restart client")) startnew(RestartLiveSplitClient);
                UI::SetPreviousTooltip("This will disable the client, then wait 1 second, then enable it again.");
            }

            LiveSplitClientEnabled = UI::Checkbox("Enable LiveSplit client", LiveSplitClientEnabled);

            if (LiveSplitClientEnabled)
            {
                LiveSplitHost = UI::InputText("IP address / hostname", LiveSplitHost);
                LiveSplitPort = UI::InputInt("Port", LiveSplitPort);
            }
            UI::EndTabItem();
        }
        if (UI::BeginTabItem(Icons::Hourglass + " Splitter Options"))
        {
            LiveSplitStartTimerOnSpawn = UI::Checkbox("Start timer after 3,2,1 countdown", LiveSplitStartTimerOnSpawn);

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
            UI::EndTabItem();
        }
        UI::EndTabBar();
    }

    void RestartLiveSplitClient()
    {
        LiveSplitClientEnabled = false;
        sleep(1000);
        LiveSplitClientEnabled = true;
    }
}