import ballerina/crypto;
import ballerina/url;

isolated function serialize(map<anydata> queryParam) returns string {
// Source: array("A" => "Red", "B" => "Green", "C" => "Blue") 
// Target: a:3:{s:1:"A";s:3:"Red";s:1:"B";s:5:"Green";s:1:"C";s:4:"Blue";}
    string serializedString = "";
    foreach var key in queryParam.keys() {
        serializedString = serializedString + "s:" + key.length().toString() + ":\"" + key + "\";";
        serializedString = serializedString + serializeValue(queryParam[key]);
    }
    return "a:" + queryParam.length().toString() + ":{" + serializedString + "}";
}

isolated function serializeValue(anydata value) returns string {
    if (value is string) {
        return "s:" + value.length().toString() + ":\"" + value + "\";";
    } else if (value is int) {
        return "i:" + value.toString() + ";";
    } else if (value is float) {
        return "d:" + value.toString() + ";";
    } else if (value is boolean) {
        return "b:" + value.toString() + ";";
    } else if (value is map<anydata>) {
        return serialize(value);
    } else {
        panic error("Not implemented");
    }
}

public function encrypt(string crypt_key, map<anydata> queryParams, string iv = "31bfe7df6c8e3abe") returns string|error {
    var hash = crypto:hashSha256(crypt_key.toBytes()).toBase16().substring(0, 32);
    var input = serialize(queryParams);    
    var cipherText = check crypto:encryptAesCbc(input.toBytes(), hash.toBytes(), iv.toBytes());
    return url:encode((iv + cipherText.toBase64()).toBytes().toBase64(), "UTF-8");
}
