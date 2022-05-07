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
        UI::SetNextWindowSize(600,150);
        if (UI::Begin("LiveSplit Dev", isOpened))
        {
            if (g_LiveSplit !is null && g_LiveSplit.connected)
            {
                bool pressedEnter = false;
                commandText = UI::InputText("###Command", commandText, pressedEnter, UI::InputTextFlags::EnterReturnsTrue);
                UI::SameLine();
                if (UI::GreenButton("Send") || pressedEnter)
                {
                    if (commandText.Length > 0)
                    {
                        g_LiveSplit.send(commandText);
                        commandText = "";
                    }
                }

                UI::Text("Command result: " + g_LiveSplit.lastResult);
            }
            else
            {
                UI::Text("Not connected to LiveSplit, check logs");
            }

            if (PlayerStateSR::TMData !is null)
            {
                UI::Separator();
                UI::Text("PlayerState: " + tostring(PlayerStateSR::TMData.PlayerState));
                if (PlayerStateSR::TMData.IsPaused) UI::Text("Game Paused");
                if (PlayerStateSR::TMData.IsMultiplayer) UI::Text("In Multiplayer");
                if (PlayerStateSR::TMData.IsSpectator) UI::Text("In Spectator");
            }
        }
        UI::End();
        UI::PopStyleVar(4);
    }
}