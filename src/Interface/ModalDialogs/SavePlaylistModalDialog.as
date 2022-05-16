class SavePlaylistModalDialog : ModalDialog
{
    string playlistName = "";
    bool nameAlreadyExists = false;
    SavePlaylistModalDialog()
    {
        super("\\$9f0" + Icons::Kenney::Save + " \\$zSave playlist");
        m_size = vec2(600, 200);
    }

    void RenderDialog() override
    {
        UI::BeginChild("Content", vec2(0, -34));
        UI::Text("Set a name for your playlist");
        playlistName = UI::InputText("Name", playlistName);
        for (uint i = 0; i < DataJson["favoritePlaylists"].Length; i++) {
            string name = DataJson["favoritePlaylists"][i]["name"];

            nameAlreadyExists = name.ToLower() == playlistName.ToLower();
        }
        if (nameAlreadyExists) {
            UI::Text("\\$f90" + Icons::ExclamationTriangle + " \\$zThis name already exists");
        }
        UI::EndChild();
        if (UI::RedButton(Icons::Times + " Cancel")) {
            Close();
        }
        UI::SameLine();
        UI::SetCursorPos(vec2(UI::GetWindowSize().x - 75, UI::GetCursorPos().y));
        if (playlistName.Length > 0 && !nameAlreadyExists && UI::GreenButton(Icons::Kenney::Save + " Save")) {
            Json::Value obj = Json::Object();
            obj["name"] = playlistName;
            obj["campaigns"] = Json::Array();
            for (uint c = 0; c < g_SpeedrunWindow.selectedCampaigns.Length; c++) {
                obj["campaigns"].Add(g_SpeedrunWindow.selectedCampaigns[c].ToJson());
            }
            DataJson["favoritePlaylists"].Add(obj);
            DataManager::Save();
            Close();
        }
    }
}