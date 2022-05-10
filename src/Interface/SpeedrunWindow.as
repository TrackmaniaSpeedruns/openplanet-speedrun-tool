class SpeedrunWindow
{
    bool isOpened = PluginSettings::SpeedrunWindowOpened;
    array<SWTab@> tabs;
    SWTab@ activeTab;
    SWTab@ c_lastActiveTab;
    array<CampaignSummary@> selectedCampaigns;

    SpeedrunWindow()
    {
        AddTab(HomeSWTab());
        AddTab(SpeedrunBeforeStart());
        AddTab(TrainingSelectSWTab());
        AddTab(OfficialCampaignsSelectSWTab());
        AddTab(TOTDSelectSWTab());
        AddTab(ClubCampaignsSelectSWTab());
    }

    void AddTab(SWTab@ tab, bool select = false){
        tabs.InsertLast(tab);
        if (select) {
            @activeTab = tab;
        }
    }

    void Render()
    {
        isOpened = PluginSettings::SpeedrunWindowOpened;
        if (!isOpened) return;

        UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
        UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
        UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
        UI::SetNextWindowSize(820, 500);
        if (UI::Begin(PLUGIN_ICON+"Speedrun \\$666v"+Meta::ExecutingPlugin().Version, PluginSettings::SpeedrunWindowOpened))
        {
            // Push the last active tab style so that the separator line is colored (this is drawn in BeginTabBar)
            auto lastActiveTab = c_lastActiveTab;
            if (lastActiveTab !is null) {
                lastActiveTab.PushTabStyle();
            }
            UI::BeginTabBar("Tabs");

            for(uint i = 0; i < tabs.Length; i++){
                auto tab = tabs[i];
                if (!tab.IsVisible()) continue;

                UI::PushID(tab);

                int flags = 0;
                if (tab is activeTab) {
                    flags |= UI::TabItemFlags::SetSelected;
                    if (!tab.GetLabel().Contains("Loading")) @activeTab = null;
                }

                tab.PushTabStyle();

                if (tab.CanClose()){
                    bool open = true;
                    if(UI::BeginTabItem(tab.GetLabel(), open, flags)){
                        @c_lastActiveTab = tab;

                        UI::BeginChild("Tab");
                        tab.Render();
                        UI::EndChild();

                        UI::EndTabItem();
                    }
                    if (!open){
                        tabs.RemoveAt(i--);
                    }
                } else {
                    if(UI::BeginTabItem(tab.GetLabel(), flags)){
                        @c_lastActiveTab = tab;

                        UI::BeginChild("Tab");
                        tab.Render();
                        UI::EndChild();

                        UI::EndTabItem();
                    }
                }

                tab.PopTabStyle();

                UI::PopID();

            }

            UI::EndTabBar();

            // Pop the tab style (for the separator line) only after EndTabBar, to satisfy the stack unroller
            if (lastActiveTab !is null) {
                lastActiveTab.PopTabStyle();
            }
        }
        UI::End();
        UI::PopStyleVar(4);
    }
}