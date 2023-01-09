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

    APIUser(Json::Value data) {
        uid = data["uid"];
        login = data["login"];
        displayName = data["displayName"];
        locale = data["locale"];
        hat = data["hat"];
        hatConfig = data["hatConfig"];
        created = data["created"];
        updated = data["updated"];
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

UserFactory users;
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
}

}
