class CampaignListSWTab : SWTab
{
    Net::HttpRequest@ m_request;
    array<CampaignSummary@> campaigns;
    int m_page = 0;

    bool ShowLoadMore() { return true; }

    void GetRequestParams(dictionary@ params){}

    void StartRequest()
    {
        dictionary params;
        GetRequestParams(params);

        string urlParams = "";
        if (!params.IsEmpty()) {
            auto keys = params.GetKeys();
            for (uint i = 0; i < keys.Length; i++) {
                string key = keys[i];
                string value;
                params.Get(key, value);

                urlParams += (i == 0 ? "?" : "&");
                urlParams += key + "=" + Net::UrlEncode(value);
            }
        }

        string url = "https://trackmania.io/api/campaigns/"+m_page+urlParams;
        @m_request = API::Get(url);
    }

    void CheckStartRequest()
    {
        // If there's not already a request and the window is appearing, we start a new request
        if (campaigns.Length == 0 && m_request is null && UI::IsWindowAppearing()) {
            StartRequest();
        }
    }

    void CheckRequest()
    {
        CheckStartRequest();

        // If there's a request, check if it has finished
        if (m_request !is null && m_request.Finished()) {
            // Parse the response
            string res = m_request.String();
            if (IS_DEV_MODE) trace("CampaignList::CheckRequest: " + res);
            @m_request = null;
            auto json = Json::Parse(res);

            if (json.GetType() == Json::Type::Null) {
                // handle error
                return;
            }

            // Handle the response
            if (json.HasKey("error")) {
                //HandleErrorResponse(json["error"]);
            } else {
                HandleResponse(json);
            }
        }
    }

    void HandleResponse(const Json::Value &in json)
    {
        auto items = json["campaigns"];
        for (uint i = 0; i < items.Length; i++) {
            campaigns.InsertLast(CampaignSummary(items[i]));
        }
    }

    void Clear()
    {
        campaigns.RemoveRange(0, campaigns.Length);
    }

    void Reload()
    {
        Clear();
        StartRequest();
    }

    void RenderHeader(){}

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
        CheckRequest();

        RenderHeader();

        if (m_request !is null && campaigns.Length == 0) {
            int HourGlassValue = Time::Stamp % 3;
            string Hourglass = (HourGlassValue == 0 ? Icons::HourglassStart : (HourGlassValue == 1 ? Icons::HourglassHalf : Icons::HourglassEnd));
            UI::Text(Hourglass + " Loading...");
        } else {
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
                if (m_request !is null) {
                    UI::TableNextRow();
                    UI::TableSetColumnIndex(0);
                    UI::Text(Icons::HourglassEnd + " Loading...");
                }
                UI::EndTable();
                if (m_request is null && ShowLoadMore() && UI::GreenButton("Load more")){
                    m_page++;
                    StartRequest();
                }
            }
            UI::EndChild();
        }
    }
}