enum RequestType {
    GET_TRAINERS = "1",
    GET_LOCATIONS = "2",
    GET_GROUPS = "3",
    GET_GROUPCATEGORIES = "4",
    GET_DEPARTMENTS = "5",
    GET_EVENTS = "6",
    GET_MEMBER = "7",
    GET_MEMBERPIC = "8",
    GET_DOCUMENT = "9",
    GET_DOCUMENTLIST = "10",
    GET_TARIFE = "11",
    GET_CONTRIBUTIONGROUPS = "12",
    POST_MEMBER = "20",
    GET_CALENDAR = "30",
    GET_TRAININGFAIL = "31"
}

enum OutputMode {
    None = "0",
    Json = "1",
    Xml = "2"
}

type MgvoResponse record {|
    string rootname;
    string objname;
    string headline;
    string call_id;
    string version;
    string verein;
    string objfieldlist;
    map<string>[]...;
|};