import Principal "mo:base/Principal";
import Entity "mo:candb/Entity";

shared({ caller = creator }) actor class User() {
    type UserInfo = {
        firstName: Text;
        lastName: Text;
        email: Text;
        phoneNumber: Text;
        country: Text;
        address: Text;
        linkedInLink: ?Text;
        xLink: ?Text;
        proofOfIncome: ?Blob;
        proofOfID: ?Blob;
    };

    private var userInfo: ?UserInfo = null;
    private let owner = creator;

    // Add initialization method for factory
    public shared(msg) func initUser(attributes: [(Entity.AttributeKey, Entity.AttributeValue)]): async () {
        assert(msg.caller == owner);
        
        var firstName = "";
        var lastName = "";
        var email = "";
        var phoneNumber = "";
        var country = "";
        var address = "";

        for ((key, value) in attributes.vals()) {
            switch(value) {
                case (#text(val)) {
                    switch(key) {
                        case "firstName" { firstName := val; };
                        case "lastName" { lastName := val; };
                        case "email" { email := val; };
                        case "phoneNumber" { phoneNumber := val; };
                        case "country" { country := val; };
                        case "address" { address := val; };
                    };
                };
                case _ {};
            };
        };

        userInfo := ?{
            firstName = firstName;
            lastName = lastName;
            email = email;
            phoneNumber = phoneNumber;
            country = country;
            address = address;
            linkedInLink = null;
            xLink = null;
            proofOfIncome = null;
            proofOfID = null;
        };
    };

    // Existing methods remain the same
    public shared(msg) func setUserInfo(info: UserInfo): async Text {
        assert(msg.caller == owner);
        userInfo := ?info;
        return "User information set successfully";
    };

    public query func getUserInfo(): async ?UserInfo {
        return userInfo;
    };

    public shared(msg) func updateUserInfo(update: UserInfo): async Text {
        assert(msg.caller == owner);
        userInfo := ?update;
        return "User information updated successfully";
    };

    system func preupgrade() {};
    system func postupgrade() {};
}