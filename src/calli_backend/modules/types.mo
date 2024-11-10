//Types for CalliBackend module
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
module Types{
    public type WaitlistUser = {
        name: Text;
        email: Text;
        country: Text;
        };
    // Define the management canister interface
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

    public type RentToOwnContract = {
        propertyID: Principal;
        tenant: Principal;
        landlord: Principal;
        monthlyAmount: Float;
        duration: Int;
        startDate: Text;
    };
};