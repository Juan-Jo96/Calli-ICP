import Principal "mo:base/Principal";
import Types "./modules/types";
import Result "mo:base/Result";

actor Main {

//Canisters

    // Initialize actor references with actual Principal IDs obtained from your deployment environment
    let youngLatinosCanister = actor("asrmz-lmaaa-aaaaa-qaaeq-cai") : actor { //TODO: Change this to the actual principal ID for the Young Latinos canister
        addYoungLatino: Types.YoungLatino -> async Text;
        getYoungLatino: Principal -> async ?Types.YoungLatino;
        getAllYoungLatinos: () -> async [Types.YoungLatino];
        updateYoungLatino: Types.YoungLatino -> async Text;
    };
    let investorsCanister = actor("avqkn-guaaa-aaaaa-qaaea-cai") : actor { // TODO: Change this to the actual principal ID for the Investors canister
        addInvestor: Types.Investor -> async Text;
        getInvestor: Principal -> async ?Types.Investor;
        getAllInvestors: () -> async [Types.Investor];
        updateInvestor: Types.Investor -> async Text;
    };
    let propertiesCanister = actor("by6od-j4aaa-aaaaa-qaadq-cai") : actor { //TODO: Change this to the actual principal ID for the Properties canister
        listProperty: Types.Property -> async Text;
        getPropertyDetails: Text -> async ?Types.Property;
        getPropertyByRequestorPrincipal: Principal -> async ?Types.Property;
        getAllProperties: () -> async [Types.Property];
        updateProperty: Types.Property -> async Text;
    };
    let rentToOwnFactoryCanister = actor("b77ix-eeaaa-aaaaa-qaada-cai") : actor { // Factory canister for rent-to-own contracts
        createRentToOwnContract: ({
            contractId: Principal;
            propertyId: Text;
            youngLatinoId: Principal;
            investorId: Principal;
            monthlyPayment: Nat;
            contractDurationMonths: Nat;
            startDate: Int;
            paymentDueDay: Nat;
        }) -> async Principal;
        listCreatedCanisters: () -> async [Principal];
    };
    let waitlistDBCanister = actor("be2us-64aaa-aaaaa-qaabq-cai") : actor { // TODO: Change this to the actual principal ID for the WaitlistDB canister
        addUserWaitlist: Types.WaitlistUser -> async Text;
        getUserWaitlist: Text -> async ?Types.WaitlistUser;
        getAllUsers: () -> async [Types.WaitlistUser];
        removeUserWaitlist: Text -> async ();
    };
    let rentToOwnDBCanister = actor("br5f7-7uaaa-aaaaa-qaaca-cai") : actor { // TODO: Change this to the actual principal ID for the RentToOwnDB canister
        registerContractCanister: Principal -> async ();
        getContract: (Principal, Text) -> async ?Types.RentToOwnContract;
        getAllContracts: () -> async [Types.RentToOwnContract];
    };

    // Helper function to safely convert Principal to Text
    private func safePrincipalToText(principal: Principal): async ?Text {
        try {
            ?Principal.toText(principal)
        } catch (_) {
            null // Return null if the principal is invalid
        }
    };

//Young Latinos
    
    //Register Young Latino
    // Ensure other functions also use safePrincipalToText where necessary
    public shared(msg) func registerYoungLatino(youngLatino: Types.YoungLatino): async Text {
        // Extract the caller's principal and convert it to text
        let callerPrincipalText = Principal.toText(msg.caller);

        // Create a new YoungLatino record with the caller's principal as the ID
        let youngLatinoWithCallerId = {
            id = callerPrincipalText;
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
        // Convert the text ID to Principal before calling addYoungLatino
        let youngLatinoPrincipalId = {
            youngLatinoWithCallerId with
            id = Principal.fromText(callerPrincipalText);
        };

        // Call the addYoungLatino function on the youngLatinosCanister with the modified youngLatino record
        let result = await youngLatinosCanister.addYoungLatino(youngLatinoPrincipalId);
        return result;
    };

    //Get Young Latino profile information
    // Modify existing functions to use safePrincipalToText and handle invalid Principals
    public shared(_) func getYoungLatinoInfo(youngLatinoId: Principal): async ?Types.YoungLatino {
        let youngLatinoIdText = await safePrincipalToText(youngLatinoId);
        if (youngLatinoIdText == null) {
            // Handle error: Invalid principal
            return null;
        };
        switch (youngLatinoIdText) {
            case (null) { null };
            case (?id) { await youngLatinosCanister.getYoungLatino(Principal.fromText(id)) };
        };
    };

    //Get all Young Latinos registered in the system
    public shared(_) func getAllYoungLatinos(): async [Types.YoungLatino] {
        return await youngLatinosCanister.getAllYoungLatinos();
    };

    //Update Young Latino profile settings
    public shared(_) func updateYoungLatino(updatedLatino: Types.YoungLatino): async Text {
        return await youngLatinosCanister.updateYoungLatino(updatedLatino);
    };


//Investors

    //Register Investor
    public shared(_) func registerInvestor(investor: Types.Investor): async Text {
        let result = await investorsCanister.addInvestor(investor);
        return result;
    };

    //Get Investor profile information
    public shared(_) func getInvestorInfo(investorId: Principal): async ?Types.Investor {
        let investorIdText = await safePrincipalToText(investorId);
        if (investorIdText == null) {
            // Handle error: Invalid principal
            return null;
        };
        switch (investorIdText) {
            case (null) { null };
            case (?id) { await investorsCanister.getInvestor(Principal.fromText(id)) };
        };
    };

    //Get all Investors registered in the system
    public shared(_) func getAllInvestors(): async [Types.Investor] {
        return await investorsCanister.getAllInvestors();
    };

    //Update Investor profile settings
    public shared(_) func updateInvestor(updatedInvestor: Types.Investor): async Text {
        return await investorsCanister.updateInvestor(updatedInvestor);
    };

//Properties

    //Add property to the system
    public shared(_) func addProperty(property: Types.Property): async Text {
        let result = await propertiesCanister.listProperty(property);
        return result;
    };

    //Get property information
    public shared(_) func getPropertyInfo(propertyId: Text): async ?Types.Property {
        return await propertiesCanister.getPropertyDetails(propertyId);
    };

    //Get property by requestor principal ID (Young Latino who is listing the property)
    public shared(_) func getPropertyByRequestorPrincipal(requestorPrincipal: Principal): async ?Types.Property {
        return await propertiesCanister.getPropertyByRequestorPrincipal(requestorPrincipal);
    };

    //Get all properties listed in the system
    public shared(_) func getAllProperties(): async [Types.Property] {
        return await propertiesCanister.getAllProperties();
    };

    //Update property information
    public shared(_) func updateProperty(updatedProperty: Types.Property): async Text {
        return await propertiesCanister.updateProperty(updatedProperty);
    };

//Rent-to-Own Contract Factory

    // Function to validate contract conditions are met before deploying the contract
    private func prepareAndValidateRentToOwnContract(youngLatinoId: Principal, propertyId: Text, investorId: Principal): async Result.Result<Bool, Text> {
        // Check if the YoungLatino exists
        let youngLatino = await youngLatinosCanister.getYoungLatino(youngLatinoId);
        if (youngLatino == null) {
            return #err "YoungLatino does not exist";
        };

        // Check if the property exists
        let propertyDetails = await propertiesCanister.getPropertyDetails(propertyId);
        if (propertyDetails == null) {
            return #err "Property does not exist";
        };

        // Check if the investor exists
        let investorDetails = await investorsCanister.getInvestor(investorId);
        if (investorDetails == null) {
            return #err "Investor does not exist";
        };

        // Validate that the user's principal is not linked to another contract
        //let existingContract = await rentToOwnFactoryCanister.checkUserContract(Principal.toText(youngLatinoId));
        //if (existingContract != null) {
        //    return #err "User is already linked to a contract";
        //};

        // If all checks pass, return true indicating success
        return #ok true;
    };

    // Function to confirms validations and deploys the contract
    public shared(_) func validateAndDeployContract(contract: Types.RentToOwnContract): async Result.Result<Principal, Text> {
        let validation = await prepareAndValidateRentToOwnContract(contract.youngLatinoId, contract.propertyId, contract.investorId);
        switch (validation) {
            case (#ok(_)) {
                let principal = await rentToOwnFactoryCanister.createRentToOwnContract({
                    contractId = contract.contractId;
                    propertyId = contract.propertyId;
                    youngLatinoId = contract.youngLatinoId;
                    investorId = contract.investorId;
                    monthlyPayment = contract.monthlyPayment;
                    contractDurationMonths = contract.contractDurationMonths;
                    startDate = contract.startDate;
                    paymentDueDay = contract.paymentDueDay;
                    active = true;
                });
                return #ok principal;
            };
            case (#err(msg)) {
                return #err(msg);
            };
        };
    };

//Rent-to-Own Contracts
    //TODO: Add functions to interact with the Rent-to-Own Contracts
    
//Centralized DB Canisters

//Waitlist

    //Add user to waitlist
    public shared(_) func addUserWaitlist(waitlistUser: Types.WaitlistUser): async Text {
        return await waitlistDBCanister.addUserWaitlist(waitlistUser);
    };

    //Get user from waitlist
    public shared(_) func getUserWaitlist(userId: Text): async ?Types.WaitlistUser {
        return await waitlistDBCanister.getUserWaitlist(userId);
    };

    //Get all users from waitlist
    public shared(_) func getAllUsersWaitlist(): async [Types.WaitlistUser] {
        return await waitlistDBCanister.getAllUsers();
    };

    //Remove user from waitlist
    public shared(_) func removeUserWaitlist(userId: Text): async () {
        await waitlistDBCanister.removeUserWaitlist(userId);
    };

//Rent-to-Own Contracts DB

    //Register contract canister
    public shared(_) func registerContractCanister(contractId: Principal): async () {
        await rentToOwnDBCanister.registerContractCanister(contractId);
    };

    //Get contract
    public shared(_) func getContract(contractId: Principal, propertyId: Text): async ?Types.RentToOwnContract {
        return await rentToOwnDBCanister.getContract(contractId, propertyId);
    };

    //Get all contracts
    public shared(_) func getAllContracts(): async [Types.RentToOwnContract] {
        return await rentToOwnDBCanister.getAllContracts();
    };
};