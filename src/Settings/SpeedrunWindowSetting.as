namespace PluginSettings
{
    [Setting hidden]
    bool SpeedrunWindowOpened = false;

    [SettingsTab name="Window"]
    void RenderSpeedrunWindowSettings()
    {
        SpeedrunWindowOpened = UI::WhiteCheckbox("Speedrun Window", SpeedrunWindowOpened);
    }
}