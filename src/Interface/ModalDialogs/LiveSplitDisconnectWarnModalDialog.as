class LiveSplitDisconnectWarnModalDialog : ModalDialog
{
    Resources::Font@ m_header = Resources::GetFont("DroidSans-Bold.ttf", 20);

    LiveSplitDisconnectWarnModalDialog()
    {
        super("\\$f90" + Icons::ExclamationTriangle + " \\$zWarning###LiveSplitDisconnected");
        m_size = vec2(600, 200);
    }

    void RenderDialog() override
    {
        UI::BeginChild("Content", vec2(0, -34));
        UI::PushFont(m_header);
        UI::Text("The plugin is not connected with LiveSplit!");
        UI::PopFont();
        UI::Text("Auto start, game time, and autosplitting will not work on your LiveSplit application.");
        UI::Text("Are you sure you want to continue?");
        UI::EndChild();
        if (UI::Button(Icons::Times + " No")) {
            Close();
        }
        UI::SameLine();
        UI::SetCursorPos(vec2(UI::GetWindowSize().x - 75, UI::GetCursorPos().y));
        if (UI::OrangeButton(Icons::PlayCircleO + " Yes")) {
            Close();
        }
    }
}