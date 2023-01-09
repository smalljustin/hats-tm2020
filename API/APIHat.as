namespace Hats {
class APIHat {
    APIHat() {}

    protected API@ api;

    uint64 idHat;
    string name;
    APIUser author;
    bool isApproved;
    uint64 created;
    uint64 updated;

    APIHat(API &in api) {
        this.api = api;
    }


}
}
