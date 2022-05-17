class LiveSplitClient
{
    Net::Socket@ sock;
    bool connected = false;
    bool connectTimeout = false;
    string lastResult = "";
    int connexionAttemptDelay = 0;
    int connexionAttemptDelayMax = 200;
    bool isTimerPaused = false;
    string LiveSplitServerDownloadUrlIfUpdate;
    string LiveSplitServerVersionIfUpdate;

    LiveSplitClient()
    {
        if (!PluginSettings::LiveSplitFirstSetupDone) Renderables::Add(LiveSplitWizard());
        else {
            CheckForUpdateVoid();
            connect();
        }
    }

    void CheckForUpdateVoid()
    {
        if (PathIsValid()) {
            // Check for LiveSplit server updates
            if (checkForVersionUpdateAsync()) {
                // Got an update!
                print("LiveSplit server update available: " + LiveSplitServerVersionIfUpdate + ", installing...");
                InstallUpdate();
            } else trace("LiveSplit Server is up to date.");
        } else {
            warn("LiveSplit path is invalid! Check your settings.");
            UI::ShowNotification(Icons::ClockO+" Speedrun", "LiveSplit path is invalid! Check your settings\nOpenplanet>Settings>Speedrun>LiveSplit>Misc", vec4(1,0.7,0,1));
        }
    }

    bool PathIsValid()
    {
        if (PluginSettings::LiveSplitAppPath.Length == 0)
            return false;
        if (!IO::FolderExists(PluginSettings::LiveSplitAppPath))
            return false;
        if (!IO::FileExists(PluginSettings::LiveSplitAppPath+"\\LiveSplit.exe"))
            return false;
        if (!IO::FolderExists(PluginSettings::LiveSplitAppPath+"\\Components"))
            return false;
        if (!IO::FileExists(PluginSettings::LiveSplitAppPath+"\\Components\\LiveSplit.Server.dll"))
            return false;

        return true;
    }

    bool checkForVersionUpdateAsync()
    {
        Json::Value githubReleasesJson = API::GetAsync("https://api.github.com/repos/GreepTheSheep/LiveSplit.Server/releases/latest");
        LiveSplitServerVersionIfUpdate = githubReleasesJson["tag_name"];
        if (PluginSettings::LiveSplitServerVersion != LiveSplitServerVersionIfUpdate) {
            LiveSplitServerVersionIfUpdate = githubReleasesJson["tag_name"];
            LiveSplitServerDownloadUrlIfUpdate = githubReleasesJson["assets"][0]["browser_download_url"];
            return true;
        } else return false;
    }

    void InstallUpdate()
    {
        Net::HttpRequest@ dllDownloadRequest = API::Get(LiveSplitServerDownloadUrlIfUpdate);
        while (!dllDownloadRequest.Finished()) {
            yield();
        }
        dllDownloadRequest.SaveToFile(PluginSettings::LiveSplitAppPath+"\\Components\\LiveSplit.Server.dll");
        print("LiveSplit server update installed.");
        PluginSettings::LiveSplitServerVersion = LiveSplitServerVersionIfUpdate;
        UI::ShowNotification(Icons::ClockO+" Speedrun", "LiveSplit Server updated to version " + LiveSplitServerVersionIfUpdate + ".\nPlease restart LiveSplit.", vec4(0.1, 1, 0.1, 0));
    }

    void connect()
    {
        trace("Connecting to LiveSplit server... ("+PluginSettings::LiveSplitHost+":"+PluginSettings::LiveSplitPort+")");
        @sock = Net::Socket();
        bool connectStatus = sock.Connect(PluginSettings::LiveSplitHost, PluginSettings::LiveSplitPort);
        if (!connectStatus) {
            error("Failed to connect to LiveSplit server.");
            return;
        }

        while (!sock.CanRead() && !sock.CanWrite()) {
            yield();
            if (connexionAttemptDelay >= connexionAttemptDelayMax) {
                error("Failed to connect to LiveSplit server. (Timeout)");
                connectTimeout = true;
                return;
            }
            connexionAttemptDelay++;
        }

        trace("Connected to LiveSplit server in "+connexionAttemptDelay+" gameticks.");
        connected = true;

    }

    void send(const string&in command)
    {
        if (sock !is null) {
            if (IS_DEV_MODE) trace("Sending command to LiveSplit server: "+command);
            sock.WriteRaw(command+"\r\n");
        }
    }

    void disconnect()
    {
        if (sock !is null) {
            trace("Disconnecting from LiveSplit server.");
            sock.Close();
            connected = false;
            @sock = null;
        }
    }

    void startOrSplit()
    {
        if (connected) {
            send("startorsplit");
        }
    }

    void setgametime(string timeSeconds)
    {
        if (connected) {
            send("setgametime "+timeSeconds);
        }
    }

    void split()
    {
        if (connected) {
            send("split");
        }
    }

    void StartTimer()
    {
        if (connected) {
            send("switchto gametime");
            send("starttimer");
            isTimerPaused = false;
        }
    }

    void pause(bool gameTime = true)
    {
        if (connected) {
            if (gameTime) send("pausegametime");
            else send("pause");
            isTimerPaused = true;
        }
    }

    void resume(bool gameTime = true)
    {
        if (connected) {
            if (gameTime) send("unpausegametime");
            else send("resume");
            isTimerPaused = false;
        }
    }

    void reset()
    {
        if (connected) {
            send("reset");
        }
    }

    void skipsplit()
    {
        if (connected) {
            send("skipsplit");
        }
    }

    void switchToGameTime()
    {
        if (connected) {
            send("switchto gametime");
        }
    }

    string getCategoryNameAsync()
    {
        if (connected) {
            lastResult = "";
            send("getcategoryname");
            while (lastResult == "") {
                yield();
            }
            return lastResult;
        }
        return "";
    }

    string getGameNameAsync()
    {
        if (connected) {
            lastResult = "";
            send("getgamename");
            while (lastResult == "") {
                yield();
            }
            return lastResult;
        }
        return "";
    }
}