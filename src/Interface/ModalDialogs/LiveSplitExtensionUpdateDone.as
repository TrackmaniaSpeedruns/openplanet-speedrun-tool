class LiveSplitExtensionUpdateDone : ModalDialog
{
    LiveSplitExtensionUpdateDone()
    {
        super("\\$ff0" + Icons::Check + " \\$zExtension updated successfully!");
        m_size = vec2(600, 200);
    }

    void RenderDialog() override
    {
        UI::BeginChild("Content", vec2(0, -34));
        UI::Text("Extension updated successfully! Please restart LiveSplit to apply the changes.");
        if (UI::Button(Icons::ExternalLink + " Open in file explorer")) {
            OpenExplorerPath(PluginSettings::LiveSplitAppPath);
        }
        UI::EndChild();
        if (UI::Button("OK")) {
            Close();
        }
    }
}