namespace Hats {
class APIUser {
    APIUser() {}

    protected API@ api;

    string uid;
    string login;
    string displayName;
    string locale;
    uint64 idHat;
    string hatConfig;
    uint64 created;
    uint64 updated;

    APIUser(API &in api) {
        this.api = api;
    }


}
}
