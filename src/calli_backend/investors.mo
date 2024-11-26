import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Types "modules/types";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

actor Investors {

    //Map to store investors by their principal ID
    private var investors: HashMap.HashMap<Text, Types.Investor> = HashMap.HashMap<Text, Types.Investor>(10, Text.equal, Text.hash);

    //Add Investor to the system if they are not already registered by their principal ID
    public shared(msg) func addInvestor(investor: Types.Investor): async Text {
        let callerPrincipal = Principal.toText(msg.caller);
        let existingRecord = investors.get(callerPrincipal);
        switch (existingRecord) {
            case (null) {
                // No existing record, proceed to add a new one
                let investorRecord = {
                    investorId = msg.caller;
                    name = investor.name;
                    email = investor.email;
                    phoneNumber = investor.phoneNumber;
                    address = investor.address;
                    linkedInLink = investor.linkedInLink;
                    xLink = investor.xLink;
                    nationality = investor.nationality;
                    occupation = investor.occupation;
                    accreditedInvestor = investor.accreditedInvestor;
                    identityVerification = investor.identityVerification;
                    proofOfAddress = investor.proofOfAddress;
                    proofOfIncome = investor.proofOfIncome;
                };
                investors.put(callerPrincipal, investorRecord);
                Debug.print("Investor added: " # callerPrincipal);
                return "Investor added successfully with ID: " # callerPrincipal;
            };
            case (_) {
                // Existing record found, reject the addition
                return "A record with the associated principal already exists.";
            };
        };
    };

    // Get Investor profile settings by principal ID
    public shared(_) func getInvestor(investorId: Principal): async ?Types.Investor {
        let investorIdText = Principal.toText(investorId);
        return investors.get(investorIdText);
    };

    // Get all Investors registered in the system
    public shared(_) func getAllInvestors(): async [Types.Investor] {
        let entries = investors.entries();
        let array = Buffer.Buffer<Types.Investor>(investors.size());
        for ((_, investor) in entries) {
            array.add(investor);
        };
        return Buffer.toArray(array);
    };

    // Update Investor profile settings (only if the caller is the investor themselves)
    public shared(msg) func updateInvestor(updatedInvestor: Types.Investor): async Text {
        let callerPrincipal = Principal.toText(msg.caller);
        let maybeExistingRecord = investors.get(callerPrincipal);
        switch (maybeExistingRecord) {
            case (null) {
                return "No record found for the caller.";
            };
            case (_) {
                investors.put(callerPrincipal, {
                    investorId = msg.caller;
                    name = updatedInvestor.name;
                    email = updatedInvestor.email;
                    phoneNumber = updatedInvestor.phoneNumber;
                    address = updatedInvestor.address;
                    linkedInLink = updatedInvestor.linkedInLink;
                    xLink = updatedInvestor.xLink;
                    nationality = updatedInvestor.nationality;
                    occupation = updatedInvestor.occupation;
                    accreditedInvestor = updatedInvestor.accreditedInvestor;
                    identityVerification = updatedInvestor.identityVerification;
                    proofOfAddress = updatedInvestor.proofOfAddress;
                    proofOfIncome = updatedInvestor.proofOfIncome;
                });
                return "Investor record updated successfully.";
            };
        };
    };
};