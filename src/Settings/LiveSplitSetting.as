namespace PluginSettings
{
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
            if (g_LiveSplit.connected) {
                UI::Text("\\$0f0"+Icons::Check + " \\$zConnected");
                if (IS_DEV_MODE) LiveSplitServerVersion = UI::InputText("LiveSplit server version", LiveSplitServerVersion);
                else {
                    UI::Text("LiveSplit server version: "+LiveSplitServerVersion);
                    UI::SetPreviousTooltip("LiveSplit server updates are automatically downloaded within the LiveSplit application.");
                }
            } else {
                if (g_LiveSplit.connectTimeout) UI::Text("\\$f00"+Icons::Times + " \\$zCannot connect - Timeout");
                else UI::Text(Icons::Refresh + " Connecting...");
            }
        }
        else
        {
            UI::Text("Disconnected or not initialized");
        }
        UI::Separator();

        if (UI::OrangeButton("Reset to default"))
        {
            LiveSplitHost = "localhost";
            LiveSplitPort = 16934;
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
    }

    void RestartLiveSplitClient()
    {
        LiveSplitClientEnabled = false;
        yield();
        LiveSplitClientEnabled = true;
    }

    void getServerVersion()
    {
        PluginSettings::LiveSplitServerVersion = g_LiveSplit.getServerVersionAsync();
    }
}