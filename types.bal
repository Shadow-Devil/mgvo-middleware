enum RequestType {
    GET_TRAINERS = "1",
    GET_LOCATIONS = "2",
    GET_GROUPS = "3",
    GET_GROUP_CATEGORIES = "4",
    GET_DEPARTMENTS = "5",
    GET_EVENTS = "6",
    GET_MEMBERS = "7",
    GET_MEMBERPIC = "8",
    GET_DOCUMENTS = "9",
    GET_DOCUMENTLISTS = "10",
    GET_TARIFE = "11",
    GET_CONTRIBUTIONGROUPS = "12",
    POST_MEMBERS = "20",
    GET_CALENDARS = "30",
    GET_CANCELED_TRAININGS = "31"
}

enum OutputMode {
    None = "0",
    Json = "1",
    Xml = "2"
}

type MgvoResponse record {|
    string rootname;
    string objname;
    string? headline;
    string call_id;
    string version;
    string verein;
    string objfieldlist?;
    json...;
|};

