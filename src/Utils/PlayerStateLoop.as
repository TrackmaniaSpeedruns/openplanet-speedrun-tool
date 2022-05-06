namespace PlayerStateSR
{

    PlayerState::sTMData@ TMData;

    void UpdateLoop(float dt)
    {
        @TMData = PlayerState::GetRaceData();
        if (g_LiveSplit !is null)
        {
            // trace(tostring(TMData.PlayerState));

            if (TMData.dEventInfo.PlayerStateChange)
            {
                if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Driving && PluginSettings::LiveSplitStartTimerOnSpawn)
                    g_LiveSplit.StartTimer();

                if (TMData.PlayerState == PlayerState::EPlayerState::EPlayerState_Countdown)
                    g_LiveSplit.pause();
            }

            if (TMData.dEventInfo.FinishRun && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[0])
                g_LiveSplit.split();

            if (TMData.dEventInfo.CheckpointChange && PluginSettings::LiveSplitSplitOn == PluginSettings::LiveSplitSplitOnSettings[1])
                g_LiveSplit.split();

            if (TMData.dEventInfo.PauseChange)
            {
                if (TMData.IsPaused)
                    g_LiveSplit.pause();
                else
                    g_LiveSplit.resume();
            }

        }
    }
}