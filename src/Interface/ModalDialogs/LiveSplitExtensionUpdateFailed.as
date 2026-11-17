class LiveSplitExtensionUpdateFailed : ModalDialog
{
    string errorMessage;

    LiveSplitExtensionUpdateFailed(string errorMsg)
    {
        super("\\$f00" + Icons::Times + " \\$zFailed to update extension.");
        errorMessage = errorMsg;
        m_size = vec2(600, 200);
    }

    void RenderDialog() override
    {
        UI::BeginChild("Content", vec2(0, -34));
        UI::Text("Failed to update LiveSplit extension.");
        UI::TextDisabled(errorMessage);
        UI::Text("Please try to close LiveSplit when you update the extension.");
        if (UI::Button(Icons::Refresh + " Retry")) {
            Close();
            startnew(PluginSettings::UpdateLiveSplitExtension);
        }
        UI::EndChild();
        if (UI::Button("Close")) {
            Close();
        }
    }
}