namespace PluginSettings
{

    [Setting hidden]
    bool LiveSplitFirstSetupDone = false;

    [Setting hidden]
    string LiveSplitAppPath = "";

    [Setting hidden]
    string LiveSplitServerVersion = "";

    [Setting hidden]
    bool LiveSplitClientEnabled = true;

    [Setting hidden]
    string LiveSplitHost = "localhost";

    [Setting hidden]
    int LiveSplitPort = 16834;

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
            }

            LiveSplitClientEnabled = UI::WhiteCheckbox("Enable LiveSplit client", LiveSplitClientEnabled);

            if (LiveSplitClientEnabled)
            {
                LiveSplitHost = UI::InputText("IP address / hostname", LiveSplitHost);
                LiveSplitPort = UI::InputInt("Port", LiveSplitPort);
            }
            UI::EndTabItem();
        }
        if (UI::BeginTabItem(Icons::Check + " Misc"))
        {
            LiveSplitFirstSetupDone = UI::WhiteCheckbox("Wizard done", LiveSplitFirstSetupDone);
            LiveSplitAppPath = UI::InputText("LiveSplit path", LiveSplitAppPath);
            UI::SetPreviousTooltip("The path where LiveSplit is installed. This is used for automatic component updates.");
            UI::EndTabItem();
        }
        UI::EndTabBar();
    }

    void RestartLiveSplitClient()
    {
        LiveSplitClientEnabled = false;
        yield();
        LiveSplitClientEnabled = true;
    }
}