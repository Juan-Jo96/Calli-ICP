import YoungLatinos "canister:YoungLatinos";
import Properties "canister:Properties";
import Investors "canister:Investors";
import Principal "mo:base/Principal";
actor Main {
    public func getYoungLatinoDetails(YoungLatinoId: Text) : async {email : Text; id : Text; name : Text; principal : Principal} {
        let result = await YoungLatinos.getYongLatino(YoungLatinoId);
        switch (result) {
            case (?youngLatino) { return youngLatino };
            case null { return { 
                email = "";
                id = "";
                name = "";
                principal = Principal.fromText("aaaaa-aa"); 
            }};
        }
    };

    public func getPropertyDetails(propertyId: Text) : async ?Properties.Property {
        try {
            let result = await Properties.getProperty(propertyId);
            switch (result) {
                case (?property) { return ?property };
                case null { return null };
            }
        } catch (error) {
            return null;
        }
    };

    public func getInvestorDetails(investorId: Text) : async ?Investors.Investor {
        try {
            let result = await Investors.getInvestor(investorId);
            switch (result) {
                case (?investor) { return ?investor };
                case null { return null };
            }
        } catch (error) {
            return null;
        }
    };

    public func prepareAndValidateRentToOwnContract(YoungLatinoId: Text, propertyId: Text, investorId: Text): async Principal {
        try {
            let youngLatino = await getYoungLatinoDetails(YoungLatinoId);
            let propertyDetails = await getPropertyDetails(propertyId);
            let investorDetails = await getInvestorDetails(investorId);

            // Validate that all required data exists
            switch (propertyDetails, investorDetails) {
                case (?p, ?i) {
                    // Here we would create the contract
                    // For now returning a placeholder principal since RentToOwnFactory is not defined
                    return Principal.fromText("aaaaa-aa");
                };
                case (_, _) {
                    return Principal.fromText("aaaaa-aa"); // Return default principal instead of throwing error
                };
            };
        } catch (error) {
            return Principal.fromText("aaaaa-aa"); // Return default principal instead of throwing error
        }
    };
};