const bool IS_DEV_MODE = Meta::ExecutingPlugin().get_Type() == Meta::PluginType::Folder;
const string PLUGIN_COLOR = "\\$4ea";
const string PLUGIN_ICON = PLUGIN_COLOR+Icons::ClockO+"\\$z ";
const string DATA_JSON_LOCATION = IO::FromDataFolder("Speedrun.json");
const string DATA_JSON_SIG_LOCATION = IO::FromDataFolder("Speedrun.json.sig");
Json::Value DataJson = Json::FromFile(DATA_JSON_LOCATION);