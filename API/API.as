namespace Hats {
API api;
class API {

    /**
     * what server we're talking to. example: "http://localhost:8000"
     */
    string baseURL;
	
    /**
     * API key provided by the Auth endpoint, or an empty string if not set
     */	
    string apiKey;

    /**
     * enables trace() spam
     */
	bool debugSpam = false;
	
    /**
     * true if an API operation is underway
     */
    bool asyncInProgress = false;

    /**
     * if an API error occurs, this should be set to a descriptive message
     */
    string errorMsg;

    API() {}

    API(const string &in baseURL, const string &in apiKey) {
        this.baseURL = baseURL;
        this.apiKey = apiKey;
    }

    /**
     * check if our api key is still valid, or if we need to get a new one
     */
    bool checkKeyStatus() {
        Json::Value payload = baseAPIObject();

        if(apiKey == "") {
            trace("null or empty api key");
            return false;
        }

        Json::Value result;
        Net::HttpRequest req;
        if (genericAPI("/api/keystatus", payload, result, req)) {
            return true;
        } else {
            warn("Key invalid");
            if (debugSpam) {
                trace(Json::Write(result));
                trace(errorMsg);
            }
            return false;
        }
    }


    /**
     * use the Auth framework to grab a new API key from our server
     */
    string fetchAPIKey() {
        asyncInProgress = true;
        auto app = cast<CTrackMania>(GetApp());
        auto network = cast<CTrackManiaNetwork>(app.Network);

        if (debugSpam) {
            trace("getting token from mothership");
        }

        // get a token from the mothership
        auto tokenTask = Auth::GetToken();
        while (!tokenTask.Finished()) {
            yield();
        }

        // Get the token
        string token = tokenTask.Token();
        if (debugSpam) {
            trace(token);
        }
        if (token == "") {
            errorMsg = "Unable to automatically auth, see Settings->API.";
            asyncInProgress = false;
            return "";
        }

        Json::Value json = Json::Object();
        json["token"] = token;
        json["login"] = network.PlayerInfo.Login;

        Json::Value result;
        Net::HttpRequest req;
        if (genericAPI("/auth/openplanet", json, result, req, false)) {
            return result["apiKey"];
        } else {
            errorMsg = "Unable to automatically auth, see Settings->API.";
            if (debugSpam) {
                trace(Json::Write(result));
            }
            return "";
        }
    }

    /**
     * internal helper
     */
    bool genericAPI(string _endpoint, Json::Value payload, Json::Value &out result, Net::HttpRequest@ req, bool requireKey = true, const string &in method = "POST") {
        if (requireKey && apiKey.Length == 0) {
            errorMsg = "No API key entered, please go to Settings";
            return false;
        }

        asyncInProgress = true;
        if (method == "POST") {
            @req = Net::HttpPost(baseURL + _endpoint, Json::Write(payload), "application/json");
        } else if (method == "GET") {
            @req = Net::HttpGet(baseURL + _endpoint);
        }
        
        while (!req.Finished()) {
            yield();
        }

        try {
            result = Json::Parse(req.String());

            if (result.GetType() == Json::Type::Null) {
                throw("not json");
            }

        } catch {
            errorMsg = "JSON parse error, see Openplanet log";

            if (debugSpam) {
                trace(req.String());
                trace(req.ResponseCode());
            }
            return false;
        }

        if(req.ResponseCode() == 200) {
            errorMsg = "";
            asyncInProgress = false;
            return true;
        } else {
            if (debugSpam) {
                trace(req.String());
                trace(req.ResponseCode());
            }

            errorMsg = result["_error"];
            asyncInProgress = false;
            return false;
        }
    }

    /**
     * internal helper
     */
    Json::Value baseAPIObject() {
    	Json::Value json = Json::Object();
    	json["apiKey"] = apiKey;
    	return json;
    }
}
}
