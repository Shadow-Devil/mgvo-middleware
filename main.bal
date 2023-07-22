import ballerina/io;
import ballerina/time;
import ballerina/http;
configurable string call_id = ?;
configurable string crypt_key = ?;

public function main() returns error? {
    http:Client mgvo = check new ("https://www.mgvo.de/api");
    var encrypted = check encrypt(crypt_key, {
            suchbeg: "8",
            call_id: call_id,
            time: time:utcNow(3)[0]
    });
    
    http:Response result = check mgvo->/["api_entry.php"].get( 
        call_id = call_id,
        reqtype = GET_MEMBER,
        outmode = Json,
        paras = encrypted,
        version = 3
    );
    io:println(result.getTextPayload());
}

