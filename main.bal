import ballerina/http;
import ballerina/mime;
import ballerina/io;
import ballerina/crypto;
import ballerina/constraint;
import ballerina/url;

type MgvoMiddlewareResponse MgvoResponse|http:Unauthorized|error;

// TODO: change up once 7.1 is released (https://github.com/ballerina-platform/openapi-tools/releases)
//httpscerr:UnauthorizedError|
//httpscerr:NotImplementedError|
//http:ClientError;

@constraint:Int {
    minValue: 0,
    maxValue: 3
}
type DunningLevel int;

const Gender = {
    "factual": "x",
    "male": "m",
    "female": "w"
};

service / on new http:Listener(8080) {

    private final http:Client mgvoClient;

    function init() returns error? {
        self.mgvoClient = check new ("https://www.mgvo.de/api");
    }

    resource function get trainers(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_TRAINERS, call\-id);
    }

    resource function get locations(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_LOCATIONS, call\-id);
    }

    resource function get groups(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_GROUPS, call\-id);
    }

    resource function get groups/categories(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_GROUP_CATEGORIES, call\-id);
    }

    resource function get departments(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_DEPARTMENTS, call\-id);
    }

    resource function get events(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_EVENTS, call\-id);
    }

    isolated resource function get members(
            @http:Header string call\-id,
            @http:Header string crypt\-key,
            string? search,
            string? birthdateFrom,
            string? birthdateTo,
            string? resignationFrom,
            string? resignationTo,
            string? groupId,
            string? priceGroup,
            boolean? directDebitPayer,
            boolean? cashPayer,
            boolean? standingOrder,
            "factual"|"male"|"female"? gender,
            string? member,
            string? active,
            string? mailRecipient,
            string? domestic,
            DunningLevel? dunningLevel
    ) returns MgvoMiddlewareResponse|error {
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
        map<anydata> params = {
            suchbeg: search,
            suchalterv: birthdateFrom,
            suchalterb: birthdateTo,
            suchaustrittv: resignationFrom,
            suchaustrittb: resignationTo,
            suchgruid: groupId,
            suchbeigru: priceGroup,
            lssel: directDebitPayer == true ? "1" : null,
            barsel: cashPayer == true ? "1" : null,
            dasel: standingOrder == true ? "1" : null,
            geschl: gender is null ? null : Gender[gender],
            ausgetr: member,
            aktpass: active,
            mailempf: mailRecipient,
            landsel: domestic,
            selmahnstufe: dunningLevel is null ? null : dunningLevel == 0 ? "a" : dunningLevel.toString()
        };

        return self.encryptedGetMgvo(GET_MEMBERS, call\-id, crypt\-key, params.filter(v => v !is null));
    }

    resource function get members/[int id](@http:Header string call\-id, @http:Header string crypt\-key) returns MgvoMiddlewareResponse|error {
        return self.encryptedGetMgvo(GET_MEMBERS, call\-id, crypt\-key, {
            suchbeg: id
        });
    }

    resource function get members/[int id]/picture(@http:Header string call\-id, @http:Header string crypt\-key) returns http:NotImplemented {
        return http:NOT_IMPLEMENTED;
        // TODO doesn't work also in the original php api
        //return self.encryptedGetMgvo(GET_MEMBERPIC, call\-id, crypt\-key, {
        //    mgnr: id
        //});
    }

    resource function get documents(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_DOCUMENTS, call\-id);
    }

    resource function get documents/lists(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_DOCUMENTLISTS, call\-id);
    }

    resource function get prices(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_TARIFE, call\-id);
    }

    resource function get prices/groups(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_CONTRIBUTIONGROUPS, call\-id);
    }

    resource function post members(@http:Payload json payload) returns http:NotImplemented { //httpscerr:NotImplementedError {
        //return error httpscerr:NotImplementedError("Not implemented");
        return http:NOT_IMPLEMENTED;
    }

    resource function get calendars(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_CALENDARS, call\-id);
    }

    resource function get calendars/trainings/canceled(@http:Header string call\-id) returns MgvoMiddlewareResponse {
        return self.getMgvo(GET_CANCELED_TRAININGS, call\-id);
    }

    isolated function getMgvo(RequestType requestType, string call\-id) returns MgvoMiddlewareResponse {
        http:Response result = check self.mgvoClient->/["api_entry.php"](
            call_id = call\-id,
            reqtype = requestType,
            outmode = Json,
            version = 3
        );
        io:println(result.getTextPayload());
        io:println(result.statusCode.toString());
        var mimetype = mime:getMediaType(result.getContentType());
        io:println(mimetype);

        if mimetype is mime:MediaType && mimetype.getBaseType() == "text/html" {
            var payload = check result.getTextPayload();
            if payload.includes("Fehler: Sicherheitsverstoß!") {
                //return error httpscerr:UnauthorizedError(string `Header "call-id" = "${call\-id}" is invalid`);
                return http:UNAUTHORIZED;
            }
            if payload.includes("Nicht erlaubt!") {
                return http:UNAUTHORIZED;
            }
            panic error(payload);
        }

        if (result.statusCode != 200) {
            panic error(string `${result.statusCode}, ${check result.getTextPayload()}`);
        }
        return <MgvoResponse>check result.getJsonPayload().cloneReadOnly();
    }

    isolated function encryptedGetMgvo(RequestType requestType, string call\-id, string crypt\-key, map<anydata> queryParams) returns MgvoMiddlewareResponse|url:Error|crypto:Error {
        var encrypted = check encrypt(call\-id, crypt\-key, queryParams);

        http:Response result = check self.mgvoClient->/["api_entry.php"](
            call_id = call\-id,
            reqtype = requestType,
            outmode = Json,
            paras = encrypted,
            version = 3.0
        );
        io:println(result.getTextPayload());
        io:println(result.statusCode.toString());
        var mimetype = mime:getMediaType(result.getContentType());
        io:println(mimetype);

        if mimetype is mime:MediaType && mimetype.getBaseType() == "text/html" {
            var payload = check result.getTextPayload();
            if payload.includes("Fehler: Sicherheitsverstoß!") {
                //return error httpscerr:UnauthorizedError(string `Header "call-id" = "${call\-id}" is invalid`);
                return http:UNAUTHORIZED;
            }
            if payload.includes("Nicht erlaubt!") {
                return http:UNAUTHORIZED;
            }
            if payload.includes("ERROR 5: Sicherheitsfehler") {
                return http:UNAUTHORIZED;
            }
            if payload.includes("ERROR 8: Anwendungsfehler") {
                return error(payload);
            }
            return error(payload);
        }

        if (result.statusCode != 200) {
            panic error(string `${result.statusCode}, ${check result.getTextPayload()}`);
        }
        return <MgvoResponse>check result.getJsonPayload().cloneReadOnly();
    }
}
