import ballerina/http;
import ballerina/mime;
import ballerina/io;

final http:Client mgvoClient = check new ("https://www.mgvo.de/api");

type MgvoMiddlewareResponse MgvoResponse|http:Unauthorized|error;

@http:ServiceConfig
service / on new http:Listener(8080) {

    resource function get trainers(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_TRAINERS, call\-id);
    }

    resource function get locations(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_LOCATIONS, call\-id);
    }

    resource function get groups(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_GROUPS, call\-id);
    }

    resource function get groups/categories(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_GROUP_CATEGORIES, call\-id);
    }

    resource function get departments(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_DEPARTMENTS, call\-id);
    }

    resource function get events(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_EVENTS, call\-id);
    }

    resource function get members/[int id](@http:Header string call\-id, @http:Header string crypt\-key) returns MgvoMiddlewareResponse|http:NotFound {
        // - General search term: suchbeg
        // - Age/Date of birth: suchalterv - suchalterb
        // - Resignation (Austritt): suchaustrittv - suchaustrittb
        // - Group ID: suchgruid
        // - Contribution group (Beitragsgruppe): suchbeigru
        // - Direct debit payer (Lastschriftzahler): lssel (Selection value: 1)
        // - Cash payer/Transfer (Barzahler/Überweiser): barsel (Selection value: 1)
        // - Standing order (Dauerauftrag): dasel (Selection value: 1)
        // - Gender: geschl (x,m,w)
        // - Member: ausgetr (x,m,a)
        // - Active/Passive: aktpass (x,a,p)
        // - Mail recipient (Mailempfänger): mailempf (x,e,s)
        // - Domestic/Foreign (Inland/Ausland): landsel (x,i,a)
        // - Dunning level (Mahnstufe): selmahnstufe (a,1,2,3)
        var encrypted = check encrypt(call\-id, crypt\-key, {
            suchbeg: id
        });

        http:Response result = check mgvoClient->/["api_entry.php"](
            call_id = call\-id,
            reqtype = GET_MEMBERS,
            outmode = Json,
            paras = encrypted,
            version = 3
        );
        if (result.statusCode != 200) {
            return http:NOT_FOUND;
        }
        return <MgvoResponse>check result.getJsonPayload().cloneReadOnly();
    }

    resource function get members/[int id]/picture(@http:Header string call\-id, @http:Header string crypt\-key) returns MgvoMiddlewareResponse|http:NotFound {
        var encrypted = check encrypt(call\-id, crypt\-key, {
            mgnr: id
        });

        http:Response result = check mgvoClient->/["api_entry.php"](
            call_id = call\-id,
            reqtype = GET_MEMBERPIC,
            outmode = Json,
            paras = encrypted,
            version = 3
        );
        if (result.statusCode != 200) {
            return http:NOT_FOUND;
        }
        return <MgvoResponse>check result.getJsonPayload().cloneReadOnly();
    }

    resource function get documents(@http:Header string call\-id) returns MgvoMiddlewareResponse {

        return getMgvo(GET_DOCUMENTS, call\-id);
    }

    resource function get documents/lists(@http:Header string call\-id) returns MgvoMiddlewareResponse {

        return getMgvo(GET_DOCUMENTLISTS, call\-id);
    }

    resource function get prices(@http:Header string call\-id) returns MgvoMiddlewareResponse {

        return getMgvo(GET_TARIFE, call\-id);
    }

    resource function get prices/groups(@http:Header string call\-id) returns MgvoMiddlewareResponse {

        return getMgvo(GET_CONTRIBUTIONGROUPS, call\-id);
    }

    resource function post members(@http:Payload json payload) returns http:NotImplemented {
        return http:NOT_IMPLEMENTED;
    }

    resource function get calendars(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_CALENDARS, call\-id);
    }

    resource function get calendars/trainings/canceled(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return getMgvo(GET_CANCELED_TRAININGS, call\-id);
    }
}

isolated function getMgvo(RequestType requestType, string call\-id) returns MgvoMiddlewareResponse {
    http:Response result = check mgvoClient->/["api_entry.php"](
        call_id = call\-id,
        reqtype = requestType,
        outmode = Json,
        version = 3
    );

    io:println(result.getTextPayload());
    io:println(result.statusCode);
    var mimetype = check mime:getMediaType(result.getContentType());

    if mimetype.getBaseType() == "text/html" {
        var payload = check result.getTextPayload();
        if payload.includes("Fehler: Sicherheitsverstoß!") {
            return http:UNAUTHORIZED;
        }
        panic error(payload);
    }

    if (result.statusCode != 200) {
        panic error(string `${result.statusCode}, ${check result.getTextPayload()}`);
    }
    return <MgvoResponse>check result.getJsonPayload().cloneReadOnly();
}
