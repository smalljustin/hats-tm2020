namespace Hats {
class APIUser {
    APIUser() {}

    string uid;
    string login;
    string displayName;
    string locale;
    string hat;
    string hatConfig;
    uint64 created;
    uint64 updated;

    uint64 age;

    APIUser(Json::Value data) {
        age = Time::Now;
        uid = data["uid"];
        login = data["login"];
        displayName = data["displayName"];
        locale = data["locale"];
        created = data["created"];
        updated = data["updated"];

        if (data["hat"].GetType() == Json::Type::String) {
            hat = data["hat"];
        } else {
            hat = "";
        }

        if (data["hatConfig"].GetType() == Json::Type::String) {
            hatConfig = data["hatConfig"];
        } else {
            hatConfig = "";
        }
    }

    bool updateHat() {
        Json::Value payload = api.baseAPIObject();
        payload["idHat"] = hat;
        payload["hatConfig"] = hatConfig;

        Json::Value result;
        Net::HttpRequest req;
        if (api.genericAPI("/api/sethat", payload, result, req, true, "POST")) {
            return true;
        } else {
            warn("Key invalid");
            if (api.debugSpam) {
                trace(Json::Write(result));
                trace(api.errorMsg);
            }
            return false;
        }
    }

    APIHat@ getHat() {
        return hats.fetch(hat);
    }




}

class UserFactory {
    protected dictionary users;
    UserFactory() {
        users = dictionary();
    }

    bool has(const string &in uid) {
        return users.Exists(uid);
    }

    APIUser@ fetch(const string &in uid) {
       return cast<APIUser@>(users[uid]);
    }

    APIUser@ ingest(Json::Value data) {
        APIUser user(data);
        users.Set(user.uid, user);
        return @user;
    }

    bool getUsersFromAPI(string[] uids, uint maxCacheAge = 3600) {
        Json::Value result;
        Net::HttpRequest req;
        string endpoint = "/api/playerhats";

        // filter out cached hats
        Json::Value unfiltered = Json::Array();

        for(uint i = 0; i < uids.Length; i++) {
            if (has(uids[i])) {
                if ((fetch(uids[i]).age + maxCacheAge) < Time::Stamp) {
                    unfiltered.Add(Json::Value(uids[i]));
                }
            } else {
                unfiltered.Add(Json::Value(uids[i]));
            }
        }

        Json::Value payload = api.baseAPIObject();
        payload["playerIDs"] = unfiltered;
        if (api.genericAPI(endpoint, payload, result, req, true, "POST")) {
            for (uint i = 0; i < result.Length; i++) {
                ingest(result[i]);
            }
            return true;
        } else {
            warn("Key invalid");
            if (api.debugSpam) {
                trace(Json::Write(result));
                trace(api.errorMsg);
            }
            return false;
        }
    }
}

}
