namespace PluginSettings
{
    string LiveSplitServerVersion = "";
    int[] LiveSplitServerVersionSplit;

    string LiveSplitAppVersion = "";
    int[] LiveSplitAppVersionSplit;

    [Setting hidden]
    string LiveSplitAppPath = "";

    [Setting hidden]
    bool LiveSplitClientEnabled = true;

    [Setting hidden]
    string LiveSplitHost = "localhost";

    [Setting hidden]
    int LiveSplitPort = 16934;

    [SettingsTab name="LiveSplit"]
    void RenderLiveSplitSettings()
    {
        UI::TextWrapped("This plugin integrates an client that interacts with the LiveSplit application in order to provide a realtime split times, auto splitting, and more.");

        UI::Text("Status:");
        UI::SameLine();
        if (g_LiveSplit !is null)
        {
            if (g_LiveSplit.connected) {
                UI::Text("\\$0f0"+Icons::Check + " \\$zConnected");

                if (LiveSplitAppVersion.Length > 0)
                    UI::Text("LiveSplit app version: "+LiveSplitAppVersion);

                if (LiveSplitServerVersion.Length > 0) {
                    UI::Text("LiveSplit server version: "+LiveSplitServerVersion);
                    UI::SetPreviousTooltip("LiveSplit server updates are automatically downloaded within the LiveSplit application.");
                }
            } else {
                if (g_LiveSplit.connectTimeout) UI::Text("\\$f00"+Icons::Times + " \\$zCannot connect - Timeout");
                else UI::Text(Icons::Refresh + " Connecting...");
            }
        }
        else {
            UI::Text("Disconnected or not initialized");
        }
        UI::Separator();

        if (UI::OrangeButton("Reset to default"))
        {
            LiveSplitHost = "localhost";
            LiveSplitPort = 16934;
            LiveSplitAppPath = "";
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
        LiveSplitAppPath = UI::InputText("LiveSplit App path", LiveSplitAppPath);
    }

    void RestartLiveSplitClient()
    {
        LiveSplitClientEnabled = false;
        yield();
        LiveSplitClientEnabled = true;
    }

    void getLiveSplitVersions()
    {
        PluginSettings::LiveSplitServerVersion = g_LiveSplit.getServerVersionAsync();

        // Check if version is at least 1.9.0 to get app version
        if (PluginSettings::LiveSplitServerVersion.Length > 0)
        {
            string[] splitSrvStr = PluginSettings::LiveSplitServerVersion.Split(".");

            for (uint i = 0; i < splitSrvStr.Length; i++)
            {
                LiveSplitServerVersionSplit.InsertLast(Text::ParseInt(splitSrvStr[i]));
            }

            if (LiveSplitServerVersionSplit.Length >= 3)
            {
                if (LiveSplitServerVersionSplit[0] >= 1 && LiveSplitServerVersionSplit[1] >= 9 && LiveSplitServerVersionSplit[2] >= 0)
                {
                    PluginSettings::LiveSplitAppVersion = g_LiveSplit.getAppVersionAsync();

                    string[] splitAppStr = PluginSettings::LiveSplitAppVersion.Split(".");

                    for (uint i = 0; i < splitAppStr.Length; i++)
                    {
                        LiveSplitAppVersionSplit.InsertLast(Text::ParseInt(splitAppStr[i]));
                    }
                }
            }
        }
    }

    void UpdateLiveSplitExtension()
    {
        g_LiveSplit.UpdateExtensionAsync();
    }
}