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
            }

            // Finish = checkpoint so it splits twice (check that)

            if (TMData.dEventInfo.FinishRun && PluginSettings::LiveSplitSplitOnFinish)
                g_LiveSplit.split();

            if (TMData.dEventInfo.CheckpointChange && PluginSettings::LiveSplitSplitOnCheckpoint)
                g_LiveSplit.split();

        }
    }
}