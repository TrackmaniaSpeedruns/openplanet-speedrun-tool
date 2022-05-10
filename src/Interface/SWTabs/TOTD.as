class TOTDSelectSWTab : SWTab
{

    array<CampaignSummary@> campaigns;

    TOTDSelectSWTab()
    {
        GetTOTDList();
    }

    string GetLabel() override { return Icons::Calendar + " Track of The Day"; }

    vec4 GetColor() override { return vec4(0.217, 0.569, 0.61, 1); }

    bool IsVisible() override { return Permissions::PlayCurrentOfficialMonthlyCampaign(); }

    int64 GetDaysInMonthEpoch(int month, int year) {
        int64 secondsInADay = 86400;
        if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
            return 31*secondsInADay;
        if(month == 4 || month == 6 || month == 9 || month == 11)
            return 30*secondsInADay;
        if(month == 2) {
            if (year % 4 == 0) {
                return 29*secondsInADay;
            } else {
                return 28*secondsInADay;
            }
        }
        return 0;
    }

    void GetTOTDList() {
        int current_month = Text::ParseInt(Time::FormatString("%m"));
        int current_year = Text::ParseInt(Time::FormatString("%Y"));
        bool first_entry = true;

        auto diff = current_month - 7 + (12 * (current_year - 2020));
        int64 current_epoch = Time::get_Stamp() - (Text::ParseInt(Time::FormatString("%d"))*86400);

        current_month--; //subtract 1 month, because we can't speedrun the current TOTD month
        for(int i = diff; i > 0; i--) {
            Json::Value json = Json::Object();
            json["id"] = (diff - i + 1);
            json["clubid"] = 0;
            json["name"] = Time::FormatString("%B %Y", current_epoch);
            json["timestamp"] = 0;
            json["mapcount"] = GetDaysInMonthEpoch(current_month, current_year) / 86400;
            json["type"] = "TOTD";
            CampaignSummary@ totd = CampaignSummary(json);

            if (i > 0 && Permissions::PlayPastOfficialMonthlyCampaign())
                campaigns.InsertLast(totd);
            else if (i == 0)
                campaigns.InsertLast(totd);

            current_epoch -= GetDaysInMonthEpoch(current_month, current_year);
            if(current_month <= 1) {
                current_month = 12;
                current_year--;
            } else {
                current_month--;
            }
        }
    }

    void Clear()
    {
        campaigns.RemoveRange(0, campaigns.Length);
    }

    void Reload()
    {
        Clear();
        GetTOTDList();
    }

    void RenderReloadButton()
    {
        vec2 posOrig = UI::GetCursorPos();
        UI::SetCursorPos(vec2(UI::GetWindowSize().x-40, posOrig.y));
        if (UI::Button(Icons::Refresh))
        {
            Reload();
        }
        UI::SetCursorPos(vec2(posOrig.x, posOrig.y+12));
        UI::NewLine();
    }

    void Render() override
    {
        RenderReloadButton();
        if (campaigns.Length == 0) {
            UI::Text("No campaigns found.");
            return;
        }
        UI::BeginChild("campaignList");
        if (UI::BeginTable("List", 2)) {
            UI::TableSetupScrollFreeze(0, 1);
            PushTabStyle();
            UI::TableSetupColumn("Name", UI::TableColumnFlags::WidthStretch);
            UI::TableSetupColumn("Select", UI::TableColumnFlags::WidthFixed, 80);
            UI::TableHeadersRow();
            PopTabStyle();

            UI::ListClipper clipper(campaigns.Length);
            while(clipper.Step()) {
                for(int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++)
                {
                    UI::PushID("CampaignListLine"+i);
                    CampaignSummary@ campaign = campaigns[i];
                    IfaceRender::CampaignListLine(campaign);
                    UI::PopID();
                }
            }
            UI::EndTable();
        }
        UI::EndChild();
    }

}