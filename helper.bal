import ballerina/crypto;
import ballerina/url;
import ballerina/time;

isolated function serialize(anydata value) returns string {
    // Source: array("A" => "Red", "B" => "Green", "C" => "Blue") 
    // Target: a:3:{s:1:"A";s:3:"Red";s:1:"B";s:5:"Green";s:1:"C";s:4:"Blue";}
    if (value is string) {
        return string `s:${value.length()}:"${value}";`;
    } else if (value is int) {
        return string `i:${value};`;
    } else if (value is float) {
        return string `d:${value};`;
    } else if (value is boolean) {
        return string `b:${value};`;
    } else if (value is map<anydata>) {
        final string entries = value.entries().reduce(isolated function(string s, [string, anydata] current) returns string =>
            s + serialize(current[0]) + serialize(current[1])
        , "");
        return string `a:${value.length()}:{${entries}}`;
    } else {
        panic error("not implemented");
    }
}

isolated function encrypt(string call_id, string crypt_key, map<anydata> queryParams, string iv = "31bfe7df6c8e3abe") returns string|url:Error|crypto:Error {
    queryParams["call_id"] = call_id;
    queryParams["time"] = time:utcNow(3)[0];
    var hash = crypto:hashSha256(crypt_key.toBytes()).toBase16().substring(0, 32);
    var input = serialize(queryParams);
    var cipherText = check crypto:encryptAesCbc(input.toBytes(), hash.toBytes(), iv.toBytes());
    return url:encode((iv + cipherText.toBase64()).toBytes().toBase64(), "UTF-8");
}
