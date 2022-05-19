const bool IS_DEV_MODE = Meta::ExecutingPlugin().get_Type() == Meta::PluginType::Folder;
const string PLUGIN_COLOR = "\\$4ea";
const string PLUGIN_ICON = PLUGIN_COLOR+Icons::ClockO+"\\$z ";
const string DATA_JSON_LOCATION = IO::FromDataFolder("Speedrun.json");
Json::Value DataJson = Json::FromFile(DATA_JSON_LOCATION);