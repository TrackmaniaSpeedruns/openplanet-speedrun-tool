LiveSplitClient@ g_LiveSplit;
LiveSplitDevWindow@ g_LiveSplitDevWindow;
SpeedrunWindow@ g_SpeedrunWindow;
Speedrun@ g_speedrun;

void Main()
{
    if (DataJson.GetType() != Json::Type::Object)
        DataManager::Init();

    if (!DataManager::compareJsonSignature())
    {
        // JSON is wrong, reset it
        DataManager::Init();
        UI::ShowNotification(Icons::Times + "Speedrun: Invalid JSON signature", "It seems you edited the data file manually, resetting to default", vec4(1, 0, 0, 1));
        error("Invalid JSON signature, resetting to default");
    }

    @g_speedrun = Speedrun();
    @g_SpeedrunWindow = SpeedrunWindow();
    @g_LiveSplitDevWindow = LiveSplitDevWindow();
    if (PluginSettings::LiveSplitClientEnabled)
    {
        @g_LiveSplit = LiveSplitClient();
        startnew(waitForLiveSplitData);
    }
    else startnew(waitForEnableLiveSplit);
}

void Update(float dt)
{
    g_speedrun.Update(dt);
}

void RenderMenu()
{
    if (g_LiveSplitDevWindow !is null && IS_DEV_MODE && UI::MenuItem("LiveSplit Dev", "", g_LiveSplitDevWindow.isOpened))
        g_LiveSplitDevWindow.isOpened = !g_LiveSplitDevWindow.isOpened;

    if (g_SpeedrunWindow !is null && UI::MenuItem(PLUGIN_ICON+ "Speedrun", "", g_SpeedrunWindow.isOpened))
        PluginSettings::SpeedrunWindowOpened = !PluginSettings::SpeedrunWindowOpened;
}

void RenderInterface()
{
    if (g_LiveSplitDevWindow !is null) g_LiveSplitDevWindow.Render();
    if (g_SpeedrunWindow !is null) g_SpeedrunWindow.Render();
}

void Render()
{
    Renderables::Render();
}

void waitForLiveSplitData()
{
    string chunk = "";
    while(true)
    {
        yield();

        if (!PluginSettings::LiveSplitClientEnabled)
        {
            // we need to disconnect from the server
            g_LiveSplit.disconnect();

            // then kill the classes
            @g_LiveSplit = null;
            @g_LiveSplitDevWindow = null;

            // start the wait for enable LS
            startnew(waitForEnableLiveSplit);

            // then break out of the loop
            break;
        }

        // Get the data from the LiveSplit Server
        if (g_LiveSplit !is null && g_LiveSplit.connected)
        {
            chunk = g_LiveSplit.sock.ReadRaw(1024);
            if (chunk.Length > 0) {
                chunk = chunk.Trim();
                g_LiveSplit.lastResult = chunk;
                trace("Data from LiveSplit: " + chunk);
                chunk = "";
            }
        }
    }
}

void waitForEnableLiveSplit()
{
    while(true)
    {
        yield();

        if (PluginSettings::LiveSplitClientEnabled)
        {
            // init the classes
            @g_LiveSplitDevWindow = LiveSplitDevWindow();
            @g_LiveSplit = LiveSplitClient();
            startnew(waitForLiveSplitData);
            // then break out of the loop
            break;
        }
    }
}

UI::InputBlocking OnKeyPress(bool down, VirtualKey key){
    return Speedrun::OnKeyPress(down, key) ? UI::InputBlocking::Block : UI::InputBlocking::DoNothing;
}