// Types for CalliBackend module
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";

module Types {
    // User information type
    public type YoungLatino = {
        id: Text;
        name: Text;
        email: Text;
        principal: Principal;
    };

    // Property information type
    public type Property = {
        id: Text;
        address: Text;
        price: Nat;
        description: Text;
        owner: Principal;
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
        contractId: Text;
        propertyId: Text; // References Property.id from properties.mo
        youngLatinoId: Text; // References YoungLatino.id from young_latinos.mo 
        investorId: Text; // References Investor.id from investors.mo
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