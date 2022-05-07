namespace PluginSettings
{
    [Setting hidden]
    bool SwitcherPreloadCache = false;

    [Setting hidden]
    bool SwitcherAutoloadNextMap = true;

    [SettingsTab name="Map Switcher"]
    void RenderSwitcherSettings()
    {
        SwitcherPreloadCache = UI::Checkbox("Preload Cache", SwitcherPreloadCache);
        SwitcherAutoloadNextMap = UI::Checkbox("Auto load Next Map", SwitcherAutoloadNextMap);
    }
}