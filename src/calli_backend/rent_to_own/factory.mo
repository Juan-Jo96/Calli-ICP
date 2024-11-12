import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Entity "mo:candb/Entity";
import Types "../modules/types";
import Float "mo:base/Float";
import Array "mo:base/Array";

actor class RentToOwnFactory(dbRentToOwn: Principal) {
    var paymentHistory: [(Text, Float)] = [];
    var totalPaid: Float = 0.0;

    // Import the management canister interface
    let managementCanister: Types.ManagementCanister = actor("aaaaa-aa");

    // Function to create and deploy a rent-to-own contract
    public shared ({caller}) func createRentToOwnContract(contract: Types.RentToOwnContract): async Text {
        // Set the required attributes for the contract
        let attributePairs: [(Entity.AttributeKey, Entity.AttributeValue)] = [
            ("propertyID", #text(Principal.toText(contract.propertyID))),
            ("tenant", #text(Principal.toText(contract.tenant))),
            ("landlord", #text(Principal.toText(contract.landlord))),
            ("monthlyAmount", #int(Float.toInt(contract.monthlyAmount))),
            ("duration", #int(contract.duration)),
            ("startDate", #text(contract.startDate))
        ];

        // Attempt to create a new canister for the contract
        try {
            Debug.print("Creating new canister...");
            let newContract = await managementCanister.create_canister({
                settings = ?{
                    controller = ?caller;
                    compute_allocation = ?100000000;
                    memory_allocation = ?100000000;
                    freezing_threshold = ?500000000000;
                };
            });

            // Optionally add cycles if needed
            //Cycles.add(200_000_000_000); // Adjust as needed

            type RTOContractCanister = actor {
                initContract: ([(Entity.AttributeKey, Entity.AttributeValue)]) -> async ();
            };

            let contractCanister = actor(Principal.toText(newContract.canister_id)) : RTOContractCanister;

            // Initialize the contract
            Debug.print("Initializing contract...");
            await contractCanister.initContract(attributePairs);

            // Add deployed contract to centralized db_rent_to_own canister
            let dbRentToOwnCanister = actor(Principal.toText(dbRentToOwn)) : actor {
                addContract: (Principal, [(Entity.AttributeKey, Entity.AttributeValue)]) -> async ();
            };
            await dbRentToOwnCanister.addContract(Principal.fromActor(contractCanister), attributePairs);

            Debug.print("Contract created successfully!");
            return Principal.toText(newContract.canister_id);

        }
        
        catch (_) {
            Debug.print("Failed to create or initialize contract canister.");
            return "Error in contract creation";
        };
    };

    // Make a payment
    public shared ({caller}) func makePayment(amount: Float): async Text {
        // Record the payment
        paymentHistory := Array.append(paymentHistory, [(Float.toText(amount), amount)]);
        totalPaid += amount;

        Debug.print("Payment made: " # Float.toText(amount));
        return "Payment of " # Float.toText(amount) # " made successfully.";
    };

    // Get payment history
    public shared ({caller}) func getPaymentHistory(contractID: Principal): async [(Text, Float)] {
        let contractCanister = actor(Principal.toText(contractID)) : actor {
            getPaymentHistory: () -> async [(Text, Float)];
        };
        return await contractCanister.getPaymentHistory();
    };

    // Terminate contract
    public shared ({caller}) func terminateContract(contractID: Principal): async Text {
        let contractCanister = actor(Principal.toText(contractID)) : actor {
            terminateContract: () -> async Text;
        };
        return await contractCanister.terminateContract();
    };

    // Transfer ownership
    public shared ({caller}) func transferOwnership(contractID: Principal): async Text {
        let contractCanister = actor(Principal.toText(contractID)) : actor {
            transferOwnership: () -> async Text;
        };
        return await contractCanister.transferOwnership();
    };

    // Update contract terms
    public shared ({caller}) func updateContractTerms(contractID: Principal, newMonthlyAmount: ?Float, newDuration: ?Int): async Text {
        let contractCanister = actor(Principal.toText(contractID)) : actor {
            updateContractTerms: (?Float, ?Int) -> async Text;
        };
        return await contractCanister.updateContractTerms(newMonthlyAmount, newDuration);
    };
};