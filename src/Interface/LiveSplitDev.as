class LiveSplitDevWindow
{
    bool isOpened = false;
    string commandText = "";

    void Render()
    {
        if (!isOpened) return;

        UI::PushStyleVar(UI::StyleVar::WindowPadding, vec2(10, 10));
        UI::PushStyleVar(UI::StyleVar::WindowRounding, 10.0);
        UI::PushStyleVar(UI::StyleVar::FramePadding, vec2(10, 6));
        UI::PushStyleVar(UI::StyleVar::WindowTitleAlign, vec2(.5, .5));
        UI::SetNextWindowSize(600,120);
        if (UI::Begin("LiveSplit Dev", isOpened))
        {
            if (g_LiveSplit !is null && g_LiveSplit.connected)
            {
                commandText = UI::InputText("Command", commandText);

                if (UI::GreenButton("Send"))
                {
                    if (commandText.Length > 0)
                    {
                        g_LiveSplit.send(commandText);
                        commandText = "";
                    }
                }
            }
            else
            {
                UI::Text("Not connected to LiveSplit, check logs");
            }
        }
        UI::End();
        UI::PopStyleVar(4);
    }
}