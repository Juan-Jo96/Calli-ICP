import Array "mo:base/Array";
import Types "../modules/types";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Principal "mo:base/Principal";

actor RentToOwnContract {
    private var contractInfo: Types.RentToOwnContract = {
        contractId = Principal.fromText("");
        propertyId = "";
        youngLatinoId = Principal.fromText("");
        investorId = Principal.fromText("");
        monthlyPayment = 0;
        contractDurationMonths = 0;
        startDate = 0;
        paymentDueDay = 0;
    };

    public func initContract(contractId: Principal, propertyId: Text, youngLatinoId: Principal, investorId: Principal, monthlyPayment: Nat, contractDurationMonths: Nat, startDate: Int, paymentDueDay: Nat) {
        // Validation checks for input parameters
        assert Text.size(Principal.toText(contractId)) > 0 and Text.size(propertyId) > 0 and Text.size(Principal.toText(youngLatinoId)) > 0 and Text.size(Principal.toText(investorId)) > 0;
        assert monthlyPayment > 0 and contractDurationMonths > 0 and startDate > 0 and paymentDueDay > 0;

        contractInfo := {
            contractId = contractId;
            propertyId = propertyId;
            youngLatinoId = youngLatinoId;
            investorId = investorId;
            monthlyPayment = monthlyPayment;
            contractDurationMonths = contractDurationMonths;
            startDate = startDate;
            paymentDueDay = paymentDueDay;
        };
    };

    public query func getContractDetails() : async Types.RentToOwnContract {
        return contractInfo;
    };

    private var payments: [PaymentRecord] = [];

    private type PaymentRecord = {
        amount: Nat;
        timestamp: Int;
        status: {#completed; #failed};
    };

    public func processPayment(amount: Nat, paymentDate: Text) : async Bool {
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
    };

    public query func getPaymentHistory() : async [PaymentRecord] {
        return payments;
    };

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
};