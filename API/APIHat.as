namespace Hats {
class APIHat {
    APIHat() {}

    string idHat;
    string name;
    APIUser@ author;
    bool isApproved;
    uint64 created;
    uint64 updated;

    uint64 age;

    APIHat(Json::Value data) {
        age = Time::Now;
        idHat = data["idHat"];
        name = data["name"];
        isApproved = data["approved"];
        created = data["created"];
        updated = data["updated"];

        @author = users.ingest(data["author"]);
    }

    string getHatData() {
        return api.getHatData(idHat);
    }

    string ToString() {
        return "APIHat " + idHat + " (" + name + " by " + author.displayName + ")";
    }
}

class HatFactory {
    protected dictionary hats;

    HatFactory() {
        hats = dictionary();
    }

    bool has(const string &in idHat) {
        return hats.Exists(idHat);
    }

    APIHat@ fetch(const string &in idHat) {
       return cast<APIHat@>(hats[idHat]);
    }

    APIHat@ ingest(Json::Value data) {
        APIHat hat(data);
        hats.Set(hat.idHat, hat);
        return @hat;
    }

    bool getHatsFromAPI(const bool &in includeMyUnapproved = false) {
        Json::Value result;
        Net::HttpRequest req;
        string endpoint = "/api/hats";

        if (includeMyUnapproved) {
            endpoint += "?apiKey="+api.apiKey;
        }

        Json::Value payload = Json::Object(); // unused, my code sucks
        if (api.genericAPI(endpoint, payload, result, req, false, "GET")) {
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

    void dumpHats() {
        string[] keys = hats.GetKeys();
        for (uint i = 0; i < keys.Length; i++) {
            trace(cast<APIHat>(hats[keys[i]]));
        }
    }
}
}
