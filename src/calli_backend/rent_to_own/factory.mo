import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Main "canister:Main";

actor class RentToOwnFactory(_dbRentToOwn: Principal, selfPrincipal: Principal, _owner: Principal) {
    private var createdCanisters: [Principal] = [];

    public shared ({caller = _owner}) func createRentToOwnContract(
        user: Text, 
        property: Text, 
        investor: Text, 
        paymentAmount: Nat, 
        startDate: Int, 
        contractDuration: Nat, 
        interestRate: Float
    ): async Principal {
        // First, validate the details by calling the Main canister and getting validating existing data
        let validation = await Main.prepareAndValidateRentToOwnContract(user, property, investor);
        if (validation != Principal.fromText("aaaaa-aa")) {
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
            await contractCanister.initContract(user, property, investor, paymentAmount, startDate, contractDuration, interestRate);
            Debug.print("Contract created for User: " # user # ", Property: " # property # ", Investor: " # investor);
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
    }
};