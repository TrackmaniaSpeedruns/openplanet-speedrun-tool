namespace PluginSettings
{
    [Setting name="Reset speedrun: Enable keys" category="Keyboard Shortcuts"]
    bool KeysResetSpeedrunEnable = true;

    [Setting name="Reset speedrun: use combo keys" category="Keyboard Shortcuts"]
    bool KeysResetSpeedrunUseComboKeys = true;

    [Setting name="Reset speedrun: Key 1" category="Keyboard Shortcuts"]
    VirtualKey KeysResetSpeedrunKey1 = VirtualKey::Shift;

    [Setting name="Reset speedrun: Key 2" category="Keyboard Shortcuts" description="Not affected if combo keys are disabled"]
    VirtualKey KeysResetSpeedrunKey2 = VirtualKey::Delete;

    [Setting name="Next map: Enable keys" category="Keyboard Shortcuts"]
    bool KeysNextMapEnable = false;

    [Setting name="Next map: use combo keys" category="Keyboard Shortcuts"]
    bool KeysNextMapUseComboKeys = true;

    [Setting name="Next map: Key 1" category="Keyboard Shortcuts"]
    VirtualKey KeysNextMapSpeedrunKey1 = VirtualKey::Shift;

    [Setting name="Next map: Key 2" category="Keyboard Shortcuts" description="Not affected if combo keys are disabled"]
    VirtualKey KeysNextMapSpeedrunKey2 = VirtualKey::Return;
}