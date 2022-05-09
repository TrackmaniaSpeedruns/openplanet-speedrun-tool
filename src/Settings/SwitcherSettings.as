namespace PluginSettings
{
    [Setting hidden]
    bool SwitcherPreloadCache = false;

    [Setting hidden]
    bool SwitcherAutoloadNextMap = true;

    [SettingsTab name="Map Switcher"]
    void RenderSwitcherSettings()
    {
        SwitcherPreloadCache = UI::WhiteCheckbox("Preload Cache", SwitcherPreloadCache);
        SwitcherAutoloadNextMap = UI::WhiteCheckbox("Auto load Next Map", SwitcherAutoloadNextMap);
    }
}