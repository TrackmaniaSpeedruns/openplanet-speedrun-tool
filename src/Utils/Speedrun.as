class Speedrun
{
    bool IsRunning = false;

    void Update(float dt)
    {
        PlayerStateSR::UpdateLoop(dt);
    }
}