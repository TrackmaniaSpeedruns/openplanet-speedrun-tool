namespace API
{
    string _LastLiveEndpointRaw;

    Json::Value@ FetchLiveEndpoint(const string &in route) {
        NadeoServices::AddAudience("NadeoLiveServices");
        while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) yield();

        auto req = NadeoServices::Get("NadeoLiveServices", route);
        req.Start();
        while(!req.Finished()) { yield(); }
        _LastLiveEndpointRaw = req.String();
        return Json::Parse(_LastLiveEndpointRaw);
    }

    Json::Value@ CallLiveApiPath(const string &in path) {
        AssertGoodPath(path);
        return FetchLiveEndpoint(NadeoServices::BaseURLLive() + path);
    }

    // Ensure we aren't calling a bad path
    void AssertGoodPath(string &in path) {
        if (path.Length <= 0 || !path.StartsWith("/")) {
            throw("API Paths should start with '/'!");
        }
    }

    Net::HttpRequest@ Get(const string &in url)
    {
        auto ret = Net::HttpRequest();
        ret.Method = Net::HttpMethod::Get;
        ret.Url = url;
        ret.Start();
        return ret;
    }

    Json::Value GetAsync(const string &in url)
    {
        auto req = Get(url);
        while (!req.Finished()) {
            yield();
        }
        return Json::Parse(req.String());
    }
}