import Principal "mo:base/Principal";
import Types "./modules/types";

actor Main {
    // Define references to other canisters
    let youngLatinosCanister: actor { addYoungLatino: Types.YoungLatino -> async Text; getYoungLatinoDetails: Text -> async ?Types.YoungLatino } = actor "young-latinos-canister-id";
    let investorsCanister: actor { addInvestor: Types.Investor -> async Text; getInvestorDetails: Text -> async ?Types.Investor } = actor "investors-canister-id";
    let propertiesCanister: actor { listProperty: Types.Property -> async Text; getPropertyDetails: Text -> async ?Types.Property } = actor "properties-canister-id";
    let rentToOwnFactoryCanister: actor {
        createRentToOwnContract: Types.RentToOwnContract -> async Principal;
        checkUserContract: Text -> async ?Principal;
    } = actor "renttoownfactory-canister-id";

    public shared(_) func registerYoungLatino(youngLatino: Types.YoungLatino): async Text {
        return await youngLatinosCanister.addYoungLatino(youngLatino);
    };

    public shared(_) func registerInvestor(investor: Types.Investor): async Text {
        return await investorsCanister.addInvestor(investor);
    };

    public shared(_) func addProperty(property: Types.Property): async Text {
        return await propertiesCanister.listProperty(property);
    };

    public shared(_) func getYoungLatinoInfo(id: Text): async ?Types.YoungLatino {
        return await youngLatinosCanister.getYoungLatinoDetails(id);
    };

    public shared(_) func getPropertyInfo(propertyId: Text): async ?Types.Property {
        return await propertiesCanister.getPropertyDetails(propertyId);
    };

    public shared(_) func getInvestorInfo(investorId: Text): async ?Types.Investor {
        return await investorsCanister.getInvestorDetails(investorId);
    };

    //Function to validate contract conditions are met before deploying the contract
    private func prepareAndValidateRentToOwnContract(youngLatinoId: Principal, propertyId: Text, investorId: Principal): async Principal {
        // Check if the YoungLatino exists
        let youngLatino = await youngLatinosCanister.getYoungLatinoDetails(Principal.toText(youngLatinoId));
        if (youngLatino == null) {
            return Principal.fromText("validation-failed-principal-id"); // YoungLatino does not exist
        };

        // Check if the property exists
        let propertyDetails = await propertiesCanister.getPropertyDetails(propertyId);
        if (propertyDetails == null) {
            return Principal.fromText("validation-failed-principal-id"); // Property does not exist
        };

        // Check if the investor exists
        let investorDetails = await investorsCanister.getInvestorDetails(Principal.toText(investorId));
        if (investorDetails == null) {
            return Principal.fromText("validation-failed-principal-id"); // Investor does not exist
        };

        // Validate that the user's principal is not linked to another contract
        let existingContract = await rentToOwnFactoryCanister.checkUserContract(Principal.toText(youngLatinoId));
        if (existingContract != null) {
            return Principal.fromText("validation-failed-principal-id"); // User is already linked to a contract
        };

        // If all checks pass, return a success principal
        return Principal.fromText("aaaaa-aa");
    };

    public shared(_) func validateAndDeployContract(contract: Types.RentToOwnContract): async Principal {
        let validation = await prepareAndValidateRentToOwnContract(contract.youngLatinoId, contract.propertyId, contract.investorId);
        if (validation == Principal.fromText("aaaaa-aa")) {
            return await rentToOwnFactoryCanister.createRentToOwnContract(contract);
        } else {
            return Principal.fromText("validation-failed-principal-id");
        }
    };
};