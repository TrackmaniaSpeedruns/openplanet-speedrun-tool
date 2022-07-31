const bool IS_DEV_MODE = Meta::ExecutingPlugin().get_Type() == Meta::PluginType::Folder;
const string PLUGIN_COLOR = "\\$4ea";
const string PLUGIN_ICON = PLUGIN_COLOR+Icons::ClockO+"\\$z ";
const string DATA_JSON_LOCATION = IO::FromDataFolder("Speedrun.json");
Json::Value DataJson = Json::FromFile(DATA_JSON_LOCATION);
const string GITHUB_USER = "TrackmaniaSpeedruns";
const string GITHUB_REPO_OP = "openplanet-speedrun-tool";
const string GITHUB_REPO_AUTOSPLITTER = "LiveSplit.TMServer";
const string GITHUB_URL = "https://github.com/"+GITHUB_USER+"/";