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