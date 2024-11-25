// Types for CalliBackend module
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";

module Types {
    // User information type
    public type YoungLatino = {
        id: Principal; //Principal of the young Latino
        name: Text;
        age: Nat; // Field for age
        verifiedProfile: Bool; // Field for verified profile status
        xLink: ?Text; // Field for link to X account
        linkedInLink: ?Text; // Field for link to LinkedIn account
        aboutMe: Text; // Field for a paragraph about the young Latino
        interests: [Text]; // Field for list of interests/tags
        email: Text;
        phoneNumber: Text; // Field for phone number including dial code
        location: Text; // Field for location
        creditScore: Nat; // Field for credit score
        monthlyIncome: Nat; // Field for monthly income
        monthlyPaymentCapacity: Nat; // Field for monthly payment capacity
        totalSavings: Nat; // Field for total savings
        legalInformation: Bool; // Field for legal information verification
        backgroundCheck: Bool; // Field for background check status
        creditReport: Bool; // Field for credit report status
        identityVerification: Bool; // Field for identity verification status
        propertyOwnershipDocuments: Bool; // Field for property ownership documents verification
    };

    // Property information type
    public type Property = {
        propertyId: Text; // Unique identifier for the property
        requestorPrincipal: Principal; // Principal of the young Latino requesting the property
        location: Text; // City and country
        address: Text; // Detailed address
        price: Nat; // Price in USD
        historicAnnualAppreciation: Float; // Annual appreciation percentage
        brickValue: Nat; // Value of each brick (1% of property value)
        brickAPR: Float; // Annual percentage rate for bricks
        monthlyRentToOwnPayment: Nat; // Monthly payment for rent-to-own
        propertyDetails: Text; // Description of property features
        propertyImages: [Text]; // Array of image URLs
        propertyLink: Text; // Link to online listing
    };

    // Investor information type
    public type Investor = {
        id: Text;
        name: Text;
        email: Text;
        principal: Principal;
    };

    // Rent-to-Own Contract type
    public type RentToOwnContract = {
        contractId: Principal;
        propertyId: Text; // References Property.id from properties.mo
        youngLatinoId: Principal; // References YoungLatino.id from young_latinos.mo 
        investorId: Principal; // References Investor.id from investors.mo
        monthlyPayment: Nat;
        contractDurationMonths: Nat;
        startDate: Int; // Timestamp in nanoseconds
        paymentDueDay: Nat; // Day of month when payment is due (1-31)
    };

    // Waitlist user type
    public type WaitlistUser = {
        name: Text;
        email: Text;
        country: Text;
    };

    // Management canister interface types
    public type CanisterSettings = {
        controller: ?Principal;
        compute_allocation: ?Nat;
        memory_allocation: ?Nat;
        freezing_threshold: ?Nat;
    };

    public type CreateCanisterArgs = {
        settings: ?CanisterSettings;
    };

    public type CanisterIdRecord = {
        canister_id: Principal;
    };

    public type InstallCodeArgs = {
        mode: {#install};
        canister_id: Principal;
        wasm_module: Blob;
        arg: Blob;
    };

    public type ManagementCanister = actor {
        create_canister: (CreateCanisterArgs) -> async CanisterIdRecord;
        install_code: (InstallCodeArgs) -> ();
        start_canister: (CanisterIdRecord) -> ();
    };

    // Extended user information type for detailed profiles
    public type UserInfo = {
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
};