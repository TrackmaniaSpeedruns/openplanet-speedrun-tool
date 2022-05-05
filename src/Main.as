LiveSplitClient@ g_LiveSplit;
LiveSplitDevWindow@ g_LiveSplitDevWindow;

void Main()
{
    if (PluginSettings::LiveSplitClientEnabled)
    {
        @g_LiveSplitDevWindow = LiveSplitDevWindow();
        @g_LiveSplit = LiveSplitClient();
        waitForLiveSplitData();
    }
    else
    {
        waitForEnableLiveSplit();
    }
}

void RenderMenu()
{
    if (g_LiveSplitDevWindow !is null && IS_DEV_MODE && UI::MenuItem("LiveSplit Dev window", "", g_LiveSplitDevWindow.isOpened))
    {
        g_LiveSplitDevWindow.isOpened = !g_LiveSplitDevWindow.isOpened;
    }
}

void RenderInterface()
{
    if (g_LiveSplitDevWindow !is null) g_LiveSplitDevWindow.Render();
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
            waitForEnableLiveSplit();

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
            waitForLiveSplitData();
            // then break out of the loop
            break;
        }
    }
}