import Principal "mo:base/Principal";
import Array "mo:base/Array";

actor class RentToOwnFactory(selfPrincipal: Principal, _owner: Principal) {
    // Simplify the actor class to focus solely on rent-to-own contract management
    private var createdCanisters: [Principal] = [];
    //TODO: Add a function to check if the caller is the owner
    public shared ({caller = _owner}) func createRentToOwnContract(
        contractSettings: {
            contractId: Principal;
            propertyId: Text;
            youngLatinoId: Principal;
            investorId: Principal;
            monthlyPayment: Nat;
            contractDurationMonths: Nat;
            startDate: Int;
            paymentDueDay: Nat;
            active: Bool;
        }
    ): async Principal {
        let settings = {
            controllers = ?[selfPrincipal];
            memory_allocation = null;
            compute_allocation = null;
            freezing_threshold = null;
        };
        let managementCanister = actor "aaaaa-aa" : actor {
            create_canister: ({
                controllers: ?[Principal];
                memory_allocation: ?Nat;
                compute_allocation: ?Nat;
                freezing_threshold: ?Nat;
            }) -> async ({canister_id: Principal});
        };
        let newCanisterId = await managementCanister.create_canister(settings);
        let contractCanister = actor(Principal.toText(newCanisterId.canister_id)) : actor {
            initContract: (Principal, Text, Principal, Principal, Nat, Nat, Int, Nat, Bool) -> async Bool;
        };
        let _ = await contractCanister.initContract(
            contractSettings.contractId,
            contractSettings.propertyId,
            contractSettings.youngLatinoId,
            contractSettings.investorId,
            contractSettings.monthlyPayment,
            contractSettings.contractDurationMonths,
            contractSettings.startDate,
            contractSettings.paymentDueDay,
            contractSettings.active
        );
        createdCanisters := Array.append(createdCanisters, [newCanisterId.canister_id]);
        return newCanisterId.canister_id;
    };

    public query func listCreatedCanisters() : async [Principal] {
        return createdCanisters;
    };
};