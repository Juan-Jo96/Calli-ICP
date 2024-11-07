//Types for CalliBackend module
module Types{
    public type WaitlistUser = {
        name: Text;
        email: Text;
        country: Text;
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