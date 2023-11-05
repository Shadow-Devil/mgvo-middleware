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
    string? headline?;
    string call_id;
    string version;
    string verein;
    string? objfieldlist?;
    json...;
|};

type Member record {|
    string mgnr?; // TODO Integer
    string anrede; // TODO Int 0-84
    string anrzus?;
    "m"|"w"|"d"|"s" geschlecht?;
    string etianr?; // TODO Enum (hf|f|s|t|el|n)
    string gebdat?; // TODO Date
    string alter?; // TODO Integer
    string vorname?;
    string nachname;

    "l"|"b"|"d" zahlungsart?; //Lastschrift|Bar|Dauerauftrag
    "j"|"h"|"v"|"m" zahlweise?; //Jährlich|Halbjährlich|Vierteljährlich|Monatlich
    string zahlung_ab?; // TODO Date
    string maxabbuch?; // TODO Float
    string mgnr_fam?; // TODO Integer (Familienzahler)
    string abwabrtag?; // TODO Integer (1-28) (Abw. Abrechnungstag)
    string einmalbetrag?; // TODO Float
    string ebbez?; // TODO Boolean (Einmalbetrag bezahlt)
    string sepa_mndid?;
    string sepa_mnddat?; // TODO Date
    string kontoname?;
    string blz?; // TODO Integer
    //string bankname?;
    string konto?; // TODO Integer
    string iban?;
    string bic?;

    string str?;
    string ort?;
    string plz?;
    string land?; // TODO Enum
    string wiedervl?; // TODO Date
    string wvlzust_id?; // TODO Enum (master|demo) zust. Bearb. Wvl.

    string tel1?;
    string tel2?;
    string mobil1?;
    string mobil2?;
    string email?;
    string nl_cons?; // TODO Boolean (Newsletter)
    string fax?;

    string vbnr?; // Verbandsnummer
    string vbeintritt?; // TODO Date

    string eintritt?; // TODO Date
    string eintrittsbrief?; // TODO Boolean
    string kuendigung?; // TODO Date
    string verstorben?; // TODO Boolean
    string austritt?; // TODO Date
    string austrittsbrief?; // TODO Boolean

    string saldo?; // TODO Float
    string letztebuchung?; // TODO Date
    string mahnkz?; // TODO Integer (0-3) (Mahnstufe)
    string mahndat1?; // TODO Date
    string mahndat2?; // TODO Date
    string mahndat3?; // TODO Date
    string stdarbstd?; // TODO Boolean (Standardarbeitstunden)
    string sollarbstunden?; // TODO Integer
    string ermstdsatz?; // TODO Boolean

    string fkt01?;
    string fkt01_dat?; // TODO Date
    string fkt01_datb?; // TODO Date
    string fkt02?;
    string fkt02_dat?; // TODO Date
    string fkt02_datb?; // TODO Date
    string fkt03?;
    string fkt03_dat?; // TODO Date
    string fkt03_datb?; // TODO Date

    string notiz?;
    string ermbis?; // TODO Date (Ermäßigung bis)
    string mstatus?;
    string zinssatzid?;

    string lastss?; // TODO Date
    string mgbzugangdat?; // TODO Date
    string lastupd?; // TODO Datetime

    string anrkey?; // TODO Integer
    string gruppenliste?; // TODO with ", "
    string beigrulist?; // TODO with "/"

    string idxtel1?;
    string idxtel2?;
    string idxtel3?;
    string idxtel4?;

    string sscnt?; // TODO?
    json[] mggruar?;

    string zfld01?;
    string zfld02?;
    string zfld03?;
    string zfld04?;
    string zfld05?;
    string zfld06?;
    string zfld07?;
    string zfld08?;
    string zfld09?;
    string zfld10?;
    string zfld11?;
    string zfld12?;
    string zfld13?;
    string zfld14?;
    string zfld15?;
    string zfld16?;
|};

