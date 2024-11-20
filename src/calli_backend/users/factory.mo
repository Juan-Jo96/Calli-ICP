import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Entity "mo:candb/Entity";
import Types "../modules/types";
import Cycles "mo:base/ExperimentalCycles";

actor class UserFactory() {
    // Import the management canister interface
    let managementCanister: Types.ManagementCanister = actor("aaaaa-aa");

    public shared ({caller}) func createUserCanister(userInfo: Types.UserInfo): async Text {
        // Set user attributes
        let attributePairs: [(Entity.AttributeKey, Entity.AttributeValue)] = [
            ("firstName", #text(userInfo.firstName)),
            ("lastName", #text(userInfo.lastName)),
            ("email", #text(userInfo.email)),
            ("phoneNumber", #text(userInfo.phoneNumber)),
            ("country", #text(userInfo.country)),
            ("address", #text(userInfo.address))
        ];

        try {
            Debug.print("Creating new user canister...");
            let newUserCanister = await managementCanister.create_canister({
                settings = ?{
                    controller = ?caller;
                    compute_allocation = ?100000000;
                    memory_allocation = ?100000000;
                    freezing_threshold = ?500000000000;
                };
            });

            // Define user canister interface
            type UserCanisterInterface = actor {
                initUser: ([(Entity.AttributeKey, Entity.AttributeValue)]) -> async ();
            };

            let userCanister = actor(Principal.toText(newUserCanister.canister_id)) : UserCanisterInterface;

            // Initialize the user canister
            Debug.print("Initializing user canister...");
            await userCanister.initUser(attributePairs);

            return "User canister created successfully: " # Principal.toText(newUserCanister.canister_id);
        }
        catch(error) {
            throw error;
        };
    };

    // System functions for upgrades
    system func preupgrade() {
        // Add upgrade logic if needed
    };

    system func postupgrade() {
        // Add post-upgrade logic if needed
    };
}