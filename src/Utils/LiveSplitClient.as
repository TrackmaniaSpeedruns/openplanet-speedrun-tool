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
        connect();
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

        connected = true;
        startnew(PluginSettings::getServerVersion);
        trace("Connected to LiveSplit server in "+connexionAttemptDelay+" gameticks.");
    }

    void send(const string&in command)
    {
        if (sock !is null) {
            if (IS_DEV_MODE) trace("Sending command to LiveSplit server: "+command);
            sock.WriteRaw(command+"\r\n");
        }
    }

    string getServerVersionAsync()
    {
        if (connected) {
            lastResult = "";
            send("getserverversion");
            while (lastResult == "") {
                yield();
            }
            return lastResult;
        }
        return "";
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