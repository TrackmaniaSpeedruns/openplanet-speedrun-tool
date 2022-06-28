class LiveSplitExtensionUpdateConfirm : ModalDialog
{
    LiveSplitExtensionUpdateConfirm()
    {
        super("\\$9f0" + Icons::CloudDownload + " \\$zUpdate extension");
        m_size = vec2(600, 200);
    }

    void RenderDialog() override
    {
        UI::BeginChild("Content", vec2(0, -34));
        UI::Text("\\$9f0" + Icons::CloudDownload + " \\$zUpdate extension");
        UI::Text("Before continuning, you need to confirm the path of your LiveSplit application.");
        PluginSettings::LiveSplitAppPath = UI::InputText("LiveSplit App path", PluginSettings::LiveSplitAppPath);
        if (PluginSettings::LiveSplitAppPath.Length > 3 && UI::Button(Icons::ExternalLink + " Open in file explorer")) {
            OpenExplorerPath(PluginSettings::LiveSplitAppPath);
        }
        UI::EndChild();
        if (UI::RedButton(Icons::Times + " Cancel")) {
            Close();
        }
        UI::SameLine();
        UI::SetCursorPos(vec2(UI::GetWindowSize().x - 98, UI::GetCursorPos().y));
        if (PluginSettings::LiveSplitAppPath.Length > 3 && UI::GreenButton(Icons::Download + " Update")) {
            Close();
            startnew(PluginSettings::UpdateLiveSplitExtension);
        }
    }
}