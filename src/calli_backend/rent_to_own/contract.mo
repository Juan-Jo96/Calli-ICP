import Array "mo:base/Array";
import Types "../modules/types";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";

actor RentToOwnContract {
    private var contractInfo: Types.RentToOwnContract = {
        contractId = Principal.fromText("aaaaa-aa");
        propertyId = "default-property-id";
        youngLatinoId = Principal.fromText("aaaaa-aa");
        investorId = Principal.fromText("aaaaa-aa");
        monthlyPayment = 1000;
        contractDurationMonths = 12;
        startDate = Time.now();
        paymentDueDay = 1;
        active = true;
    };

    // Initialize the contract
    public func initContract(contractId: Principal, propertyId: Text, youngLatinoId: Principal, investorId: Principal, monthlyPayment: Nat, contractDurationMonths: Nat, startDate: Int, paymentDueDay: Nat) : async Bool {
        // Validation checks for input parameters
        if (Principal.toText(contractId) == "" or Principal.toText(youngLatinoId) == "" or Principal.toText(investorId) == "") {
            Debug.print("Error: One or more principals are empty.");
            return false;
        };

        if (Principal.toText(contractId).size() < 29 or Principal.toText(youngLatinoId).size() < 29 or Principal.toText(investorId).size() < 29) {
            Debug.print("Error: One or more principals are too short.");
            return false;
        };

        // Proceed with contract initialization
        contractInfo := {
            contractId = contractId;
            propertyId = propertyId;
            youngLatinoId = youngLatinoId;
            investorId = investorId;
            monthlyPayment = monthlyPayment;
            contractDurationMonths = contractDurationMonths;
            startDate = startDate;
            paymentDueDay = paymentDueDay;
            active = true;
        };
        return true;
    };

    // Get the contract details
    public query func getContractDetails() : async Types.RentToOwnContract {
        return contractInfo;
    };

    private var payments: [PaymentRecord] = [];

    private type PaymentRecord = {
        amount: Nat;
        timestamp: Int;
        status: {#completed; #failed};
    };

    // Process the payment
    public func processPayment(amount: Nat, paymentDate: Text) : async Bool {
        // Check if the contract is currently active
        if (contractInfo.active) {
            if (amount < contractInfo.monthlyPayment) {
                let failedPayment = {
                    amount = amount;
                    timestamp = Time.now();
                    paymentDate = paymentDate;
                    status = #failed;
                };
                payments := Array.append(payments, [failedPayment]);
                return false; // Payment amount is less than required monthly payment
            };

            if (amount == contractInfo.monthlyPayment) {
                let successPayment = {
                    amount = amount;
                    timestamp = Time.now();
                    paymentDate = paymentDate;
                    status = #completed;
                };
                payments := Array.append(payments, [successPayment]);
                return true;
            };

            if (amount > contractInfo.monthlyPayment) {
                let failedPayment = {
                    amount = amount;
                    timestamp = Time.now();
                    paymentDate = paymentDate;
                    status = #failed;
                };
                payments := Array.append(payments, [failedPayment]);
                return false; // Payment amount exceeds monthly payment
            } else {
                let failedPayment = {
                    amount = amount;
                    timestamp = Time.now();
                    paymentDate = paymentDate;
                    status = #failed;
                };
                payments := Array.append(payments, [failedPayment]);
                return false; // Payment amount is less than monthly payment
            };
        } else {
            return false; // Cannot process payment if the contract is not active
        }
    };

    // Get the payment history
    public query func getPaymentHistory() : async [PaymentRecord] {
        return payments;
    };

    // Validate compliance with contract terms
    public func validateCompliance() : async Bool {
        if (payments.size() < 3) {
            return true; // Not enough payment history to determine non-compliance
        };
    
        let lastThreePayments = Array.subArray(
            payments, 
            payments.size() - 3, 
            3
        );

        let successfulPayments = Array.filter<PaymentRecord>(lastThreePayments, func (p : PaymentRecord) : Bool { p.status == #completed }).size();

        // Check if at least two out of the last three payments were successful
        return successfulPayments >= 2;
    };

    //Function that allows the investor to cancel the contract if compliance is not met
    public shared(msg) func cancelContract() : async Bool {
        if (msg.caller == contractInfo.investorId) {
            let isCompliant = await validateCompliance();
            if (not isCompliant) {
                // Create a new instance of the contractInfo with 'active' set to false
                contractInfo := {
                    contractId = contractInfo.contractId;
                    propertyId = contractInfo.propertyId;
                    youngLatinoId = contractInfo.youngLatinoId;
                    investorId = contractInfo.investorId;
                    monthlyPayment = contractInfo.monthlyPayment;
                    contractDurationMonths = contractInfo.contractDurationMonths;
                    startDate = contractInfo.startDate;
                    paymentDueDay = contractInfo.paymentDueDay;
                    active = false; // Set active to false
                };
                return true; // Indicate successful cancellation
            };
            return false; // Cannot cancel if compliant
        } else {
            return false; // Indicate failure to cancel due to unauthorized caller
        }
    };
};