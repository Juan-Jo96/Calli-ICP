import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Entity "mo:candb/Entity";
import Types "../modules/types";
import Float "mo:base/Float";
import Option "mo:base/Option";
import Array "mo:base/Array";

actor RentToOwnContract {

    stable var paymentHistory: [(Text, Float)] = [];
    stable var totalPaid: Float = 0.0;

    // Initialize the contract with the required attributes
    public shared ({caller}) func initContract(attributePairs: [(Entity.AttributeKey, Entity.AttributeValue)]): async () {
        // Initialize contract attributes (e.g., propertyID, tenant, landlord, etc.)
        let attributeList: [(Entity.AttributeKey, Entity.AttributeValue)] = attributePairs;
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
    public query func getPaymentHistory(): async [(Text, Float)] {
        return paymentHistory;
    };

    // Terminate contract
    public shared ({caller}) func terminateContract(): async Text {
        // Logic to terminate the contract
        Debug.print("Contract terminated.");
        return "Contract terminated successfully.";
    };

    // Transfer ownership
    public shared ({caller}) func transferOwnership(): async Text {
        // Logic to transfer ownership
        Debug.print("Ownership transferred.");
        return "Ownership transferred successfully.";
    };

    // Update contract terms
    public shared ({caller}) func updateContractTerms(newMonthlyAmount: ?Float, newDuration: ?Int): async Text {
        // Logic to update contract terms
        Debug.print("Contract terms updated.");
        return "Contract terms updated successfully.";
    };
}