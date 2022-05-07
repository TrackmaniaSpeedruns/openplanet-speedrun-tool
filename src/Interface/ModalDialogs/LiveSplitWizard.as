class LiveSplitWizard : ModalDialog
{
    Resources::Font@ m_header;
    Net::HttpRequest@ m_dllComponentRequest;
    bool isFoldersChecked = false;
    bool folderCheckInProgress = false;
    bool folderCheckError = false;
    string folderCheckErrorReason = "";

    bool DllDownloadError = false;
    bool isDllDownloaded = false;
    int m_stage = 0;

    LiveSplitWizard()
    {
        super(PLUGIN_ICON+ "LiveSplit setup");
        m_size = vec2(Draw::GetWidth()/2, Draw::GetHeight()/2);

        @m_header = Resources::GetFont("DroidSans-Bold.ttf", 22);
    }

    bool CanClose() override { return false; }

    void CheckFolders()
    {
        folderCheckInProgress = true;
        if (PluginSettings::LiveSplitAppPath.Length == 0) {
            folderCheckError = true;
            folderCheckErrorReason = "LiveSplitAppPath is empty.";
            warn(folderCheckErrorReason);
            folderCheckInProgress = false;
            return;
        }
        if (!IO::FolderExists(PluginSettings::LiveSplitAppPath)) {
            folderCheckError = true;
            folderCheckErrorReason = "LiveSplitAppPath folder does not exist.";
            warn(folderCheckErrorReason);
            folderCheckInProgress = false;
            return;
        }
        if (!IO::FileExists(PluginSettings::LiveSplitAppPath+"\\LiveSplit.exe")) {
            folderCheckError = true;
            folderCheckErrorReason = "LiveSplitAppPath\\LiveSplit.exe does not exist.";
            warn(folderCheckErrorReason);
            folderCheckInProgress = false;
            return;
        }
        if (!IO::FolderExists(PluginSettings::LiveSplitAppPath+"\\Components")) IO::CreateFolder(PluginSettings::LiveSplitAppPath+"\\Components");
        isFoldersChecked = true;
        folderCheckInProgress = false;
    }

    void StartServerComponentRequest()
    {
        string url = "https://github.com/GreepTheSheep/LiveSplit.Server/releases/download/1.8.19-custom/LiveSplit.Server.dll";
        @m_dllComponentRequest = API::Get(url);
    }

    void CheckServerComponentRequest()
    {
        // If there's a request, check if it has finished
        if (m_dllComponentRequest !is null && m_dllComponentRequest.Finished()) {
            m_dllComponentRequest.SaveToFile(PluginSettings::LiveSplitAppPath+"\\Components\\LiveSplit.Server.dll");
            isDllDownloaded = true;
            @m_dllComponentRequest = null;
        }
    }

    void RenderStep1()
    {
        UI::PushFont(m_header);
        UI::Text("Welcome to the Speedrun Tool!");
        UI::PopFont();
        UI::TextWrapped("It looks like this is the first time you are using the plugin."
			" To get started, you need to setup and connect to your LiveSplit application.");

        UI::NewLine();

        UI::Markdown("To get started, you need to setup and connect to your LiveSplit application."
            " Download [LiveSplit](https://github.com/LiveSplit/LiveSplit/releases/latest),"
            " and then run it.");
        UI::NewLine();

        UI::TextWrapped("After downloading, please set here the path to your LiveSplit installation.");
        UI::Text("LiveSplit path:");
        UI::SameLine();
        PluginSettings::LiveSplitAppPath = UI::InputText("###LiveSplit", PluginSettings::LiveSplitAppPath);
    }

    void RenderStep2()
    {
        if (!isFoldersChecked && !folderCheckInProgress && !folderCheckError) CheckFolders();

        if (folderCheckError)
        {
            UI::Text("\\$f00" + Icons::Times + " \\$zError: " + folderCheckErrorReason);
            UI::Text("Check your settings and try again.");
            if (UI::Button("Retry"))
            {
                folderCheckError = false;
                isFoldersChecked = false;
            }
        } else
        {
            if (!isDllDownloaded) CheckServerComponentRequest();
            if (m_dllComponentRequest is null && !isDllDownloaded) StartServerComponentRequest();

            if (isDllDownloaded)
            {
                UI::Text("\\$0f0" +Icons::Check+ " \\$zLiveSplit Server has been installed.");
                UI::Text("You can now restart LiveSplit and use the plugin!");
            } else
            {
                UI::Text(Icons::Hourglass + " LiveSplit Server is downloading...");
            }
        }
    }

    void RenderDialog() override
    {
        UI::BeginChild("Content", vec2(0, -34));
		switch (m_stage) {
			case 0: RenderStep1(); break;
			case 1: RenderStep2(); break;
		}
		UI::EndChild();

        if (m_stage == 0) {
            if (UI::OrangeButton(Icons::Times + " Skip")) {
                PluginSettings::LiveSplitFirstSetupDone = true;
                Close();
            }
        } else {
            if (UI::OrangeButton(Icons::ArrowLeft + " Back")) {
                m_stage--;
            }
        }
        UI::SameLine();
        vec2 currentPos = UI::GetCursorPos();
        UI::SetCursorPos(vec2(UI::GetWindowSize().x - 90, currentPos.y));
        if (m_stage != 1) {
            if (m_stage == 0 && PluginSettings::LiveSplitAppPath.Length > 0 && UI::GreenButton("Next " + Icons::ArrowRight))
                m_stage++;
            else if (m_stage != 0) {
                if (UI::GreenButton("Next " + Icons::ArrowRight))
                    m_stage++;
            }
        } else {
            if (UI::GreenButton(Icons::Check + "Finish")) {
                PluginSettings::LiveSplitFirstSetupDone = true;
                Close();
            }
        }
    }
}