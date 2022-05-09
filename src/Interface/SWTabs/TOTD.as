class TOTDSelectSWTab : SWTab
{
    string GetLabel() override { return Icons::Calendar + " Track of The Day"; }

    vec4 GetColor() override { return vec4(0.217, 0.569, 0.61, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialMonthlyCampaign(); }

}