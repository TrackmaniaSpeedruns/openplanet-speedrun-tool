class SpeedrunBeforeStart : SWTab
{

    SpeedrunBeforeStart()
    {
    }

    string GetLabel() { return Icons::Play + " Start"; }

    bool IsVisible() override { return g_SpeedrunWindow.selected_campaigns.Length > 0; }

    vec4 GetColor() { return vec4(0.6, 0.6, 0.6, 1); }

    void Render() override
    {

    }
}