void ClosePauseMenu()
{
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    if(app.ManiaPlanetScriptAPI.ActiveContext_InGameMenuDisplayed) {
        CSmArenaClient@ playground = cast<CSmArenaClient>(app.CurrentPlayground);
        if(playground !is null) {
            playground.Interface.ManialinkScriptHandler.CloseInGameMenu(CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Resume);
        }
    }
}

CSmArenaRulesMode@ TryGetPlaygroundScript()
{
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    if (app !is null)
    {
        CSmArenaRulesMode@ playgroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
        if (playgroundScript !is null)
        {
            return playgroundScript;
        }
    }
    return null;
}

CGameDataFileManagerScript@ TryGetDataFileMgr()
{
    CTrackMania@ app = cast<CTrackMania>(GetApp());
    if (app !is null)
    {
        CSmArenaRulesMode@ playgroundScript = cast<CSmArenaRulesMode>(app.PlaygroundScript);
        if (playgroundScript !is null)
        {
            CGameDataFileManagerScript@ dataFileMgr = cast<CGameDataFileManagerScript>(playgroundScript.DataFileMgr);
            if (dataFileMgr !is null)
            {
                return dataFileMgr;
            }
        }
    }
    return null;
}