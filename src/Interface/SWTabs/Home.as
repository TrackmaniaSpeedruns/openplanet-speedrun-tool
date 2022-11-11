class HomeSWTab : SWTab
{
    UI::Font@ t_header;

    HomeSWTab()
    {
        @t_header = UI::LoadFont("DroidSans.ttf", 20, -1, -1, true, true, true);
    }

    string GetLabel() override { return Icons::Home; }
    string GetTooltip() override { return "Home"; }

    vec4 GetColor() override { return vec4(0, 0.645, 0.144, 1); }

    void Render() override
    {
        float width = (UI::GetWindowSize().x*0.35)*0.5;
        vec2 posTop = UI::GetCursorPos();

        UI::BeginChild("Icon", vec2(width,0));
        auto logo = Images::CachedFromURL("https://cdn.discordapp.com/icons/396655697334501376/2bcdeb3bb7e94e46722fe046449642cc.png?size=1024");
        if (logo.m_texture !is null){
            vec2 imageSize = logo.m_texture.GetSize();
            UI::Image(logo.m_texture, vec2(
                width,
                imageSize.y / (imageSize.x / width)
            ));
        }
        UI::EndChild();
        UI::SetCursorPos(posTop + vec2(width + 8, 0));

        UI::BeginChild("Description");

        if (g_LiveSplit !is null) {
            UI::PushFont(t_header);
            UI::Text(PLUGIN_ICON + "LiveSplit");
            UI::PopFont();
            UI::Text("Connexion status:");
            UI::SameLine();
            if (g_LiveSplit.connected) {
                UI::Text("\\$0f0" + Icons::Check + " \\$zConnected \\$777("+PluginSettings::LiveSplitHost+":"+PluginSettings::LiveSplitPort+")");
                if (PluginSettings::LiveSplitAppVersion.Length > 0)
                    UI::Text("App Version \\$777"+PluginSettings::LiveSplitAppVersion);

                if (PluginSettings::LiveSplitServerVersion.Length > 0) {
                    UI::Text(Icons::PuzzlePiece + " LiveSplit Server for Trackmania Extension \\$777Version "+PluginSettings::LiveSplitServerVersion);
                    UI::SameLine();
                    UI::TextDisabled(Icons::InfoCircle);
                    UI::SetPreviousTooltip("LiveSplit server updates are automatically downloaded within the LiveSplit application.\n\nClick to force update the extension.");
                    if (UI::IsItemClicked())
                        Renderables::Add(LiveSplitExtensionUpdateConfirm());
                }
            } else UI::Text("\\$f00" + Icons::Times + " \\$zDisconnected");

            if (UI::Button(Icons::Refresh + " Restart client")) startnew(PluginSettings::RestartLiveSplitClient);

            UI::Separator();
        }

        UI::PushFont(t_header);
        UI::Text(PLUGIN_COLOR+Icons::ClockO+" \\$zTrackmania Speedruns");
        UI::PopFont();
        if (UI::Button(Icons::Discord + " Join TMSR Discord")) OpenBrowserURL("https://discord.gg/VkZxU32Mzf");
        UI::SameLine();
        if (UI::Button(Icons::ListOl + " speedrun.com leaderboard")) OpenBrowserURL("https://speedrun.com/tm");

        UI::Separator();
        if (UI::CollapsingHeader(Icons::Info + " Plugin")) {
            UI::PushFont(t_header);
            UI::Text(PLUGIN_COLOR + Icons::Plug + " \\$zPlugin");
            UI::PopFont();
            UI::Text("Made by \\$777" + Meta::ExecutingPlugin().Author);
            UI::Text("Version \\$777" + Meta::ExecutingPlugin().Version);
            UI::Text("Plugin ID \\$777" + Meta::ExecutingPlugin().ID);
            UI::Text("Site ID \\$777" + Meta::ExecutingPlugin().SiteID);
            UI::Text("Type \\$777" + tostring(Meta::ExecutingPlugin().Type));
            if (IS_DEV_MODE) {
                UI::SameLine();
                UI::Text("\\$777(\\$f39"+Icons::Code+" \\$777Dev mode)");
            }

            if (UI::Button(Icons::Github + " Github")) OpenBrowserURL(GITHUB_URL);

            UI::Separator();
            UI::PushFont(t_header);
            UI::Text("\\$f39" + Icons::Heartbeat + " \\$zOpenplanet");
            UI::PopFont();
            UI::Text("Version \\$777" + Meta::OpenplanetBuildInfo());
        }

        UI::EndChild();
    }
}