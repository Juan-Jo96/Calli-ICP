// src/calli_backend/young_latinos.mo
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Types "./modules/types";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";

actor YoungLatinos {
    //Map to store young Latinos by their principal ID
    private var youngLatinosMap: HashMap.HashMap<Text, Types.YoungLatino> = HashMap.HashMap<Text, Types.YoungLatino>(10, Text.equal, Text.hash);
    
    //Add Young Latino to the system if they are not already registered by their principal ID
    public shared(msg) func addYoungLatino(youngLatino: Types.YoungLatino): async Text {
        let callerPrincipal = Principal.toText(msg.caller);
        let existingRecord = youngLatinosMap.get(callerPrincipal);
        switch (existingRecord) {
            case (null) {
                // No existing record, proceed to add a new one
                let youngLatinoRecord = {
                    id = callerPrincipal;
                    name = youngLatino.name;
                    age = youngLatino.age;
                    verifiedProfile = youngLatino.verifiedProfile;
                    xLink = youngLatino.xLink;
                    linkedInLink = youngLatino.linkedInLink;
                    aboutMe = youngLatino.aboutMe;
                    interests = youngLatino.interests;
                    email = youngLatino.email;
                    phoneNumber = youngLatino.phoneNumber;
                    location = youngLatino.location;
                    creditScore = youngLatino.creditScore;
                    monthlyIncome = youngLatino.monthlyIncome;
                    monthlyPaymentCapacity = youngLatino.monthlyPaymentCapacity;
                    totalSavings = youngLatino.totalSavings;
                    legalInformation = youngLatino.legalInformation;
                    backgroundCheck = youngLatino.backgroundCheck;
                    creditReport = youngLatino.creditReport;
                    identityVerification = youngLatino.identityVerification;
                    propertyOwnershipDocuments = youngLatino.propertyOwnershipDocuments;
                };
                let youngLatinoRecordWithPrincipalId = {
                    youngLatinoRecord with
                    id = Principal.fromText(callerPrincipal)
                };
                youngLatinosMap.put(callerPrincipal, youngLatinoRecordWithPrincipalId);
                Debug.print("YoungLatino added: " # callerPrincipal);
                return "YoungLatino added successfully with ID: " # callerPrincipal;
            };
            case (_) {
                // Existing record found, reject the addition
                return "A record with the associated principal already exists.";
            };
        };
    };

    // Get Young Latino profile settings by principal ID
    public shared(_) func getYoungLatino(youngLatinoId: Principal): async ?Types.YoungLatino {
        let youngLatinoIdText = Principal.toText(youngLatinoId);
        return youngLatinosMap.get(youngLatinoIdText);
    };

    //Get all Young Latinos registered in the system
    public shared(_) func getAllYoungLatinos(): async [Types.YoungLatino] {
        let entries = youngLatinosMap.entries();
        let array = Buffer.Buffer<Types.YoungLatino>(youngLatinosMap.size());
        for ((_, youngLatino) in entries) {
            array.add(youngLatino);
        };
        return Buffer.toArray(array);
    };
    //Update Young Latino profile settings (only if the caller is the young Latino themselves)
    public shared(msg) func updateYoungLatino(updatedLatino: Types.YoungLatino): async Text {
        let callerPrincipal = Principal.toText(msg.caller);
        let maybeExistingRecord = youngLatinosMap.get(callerPrincipal);
        switch (maybeExistingRecord) {
            case (null) {
                return "No record found for the caller.";
            };
            case (_) {
                youngLatinosMap.put(callerPrincipal, {
                    id = Principal.fromText(callerPrincipal);
                    name = updatedLatino.name;
                    age = updatedLatino.age;
                    verifiedProfile = updatedLatino.verifiedProfile;
                    xLink = updatedLatino.xLink;
                    linkedInLink = updatedLatino.linkedInLink;
                    aboutMe = updatedLatino.aboutMe;
                    interests = updatedLatino.interests;
                    email = updatedLatino.email;
                    phoneNumber = updatedLatino.phoneNumber;
                    location = updatedLatino.location;
                    creditScore = updatedLatino.creditScore;
                    monthlyIncome = updatedLatino.monthlyIncome;
                    monthlyPaymentCapacity = updatedLatino.monthlyPaymentCapacity;
                    totalSavings = updatedLatino.totalSavings;
                    legalInformation = updatedLatino.legalInformation;
                    backgroundCheck = updatedLatino.backgroundCheck;
                    creditReport = updatedLatino.creditReport;
                    identityVerification = updatedLatino.identityVerification;
                    propertyOwnershipDocuments = updatedLatino.propertyOwnershipDocuments;
                });
                return "Record updated successfully.";
            };
        };
    };
};