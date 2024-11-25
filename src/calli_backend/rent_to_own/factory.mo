import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Array "mo:base/Array";

actor class RentToOwnFactory(_dbRentToOwn: Principal, selfPrincipal: Principal, _owner: Principal, mainCanister: Principal) {
    type MainCanister = actor {
        prepareAndValidateRentToOwnContract: (Text, Text, Text) -> async { validation: Principal; additionalData: Text; };
    };

    private var createdCanisters: [Principal] = [];

    public shared ({caller = _owner}) func createRentToOwnContract(
        youngLatinoId: Principal, 
        propertyId: Text, 
        investorId: Principal, 
        paymentAmount: Nat, 
        startDate: Int, 
        contractDuration: Nat, 
        interestRate: Float
    ): async Principal {
        // First, validate the details by calling the Main canister and validating existing data
        let mainActor = actor(Principal.toText(mainCanister)) : MainCanister;
        let result = await mainActor.prepareAndValidateRentToOwnContract(Principal.toText(youngLatinoId), propertyId, Principal.toText(investorId));
        if (result.validation == Principal.fromText("aaaaa-aa")) {
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
                initContract: (Text, Text, Text, Nat, Int, Nat, Float) -> async ();
            };
            await contractCanister.initContract(Principal.toText(youngLatinoId), propertyId, Principal.toText(investorId), paymentAmount, startDate, contractDuration, interestRate);
            Debug.print("Contract created for User: " # Principal.toText(youngLatinoId) # ", Property: " # propertyId # ", Investor: " # Principal.toText(investorId));
            createdCanisters := Array.append(createdCanisters, [newCanisterId.canister_id]);
            let dbCanister = actor "db-canister-id" : actor {
                registerContractCanister: (Principal) -> async ();
            };
            await dbCanister.registerContractCanister(newCanisterId.canister_id);
            return newCanisterId.canister_id;
        } else {
            return Principal.fromText("aaaaa-aa"); // Return the validation failure Principal
        }
    };

    public query func listCreatedCanisters() : async [Principal] {
        return createdCanisters;
    };
};