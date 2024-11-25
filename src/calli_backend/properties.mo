// src/calli_backend/properties.mo
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Types "./modules/types";
import Debug "mo:base/Debug";

actor Properties {
    private var propertiesMap: HashMap.HashMap<Text, Types.Property> = HashMap.HashMap<Text, Types.Property>(10, Text.equal, Text.hash);

    // Function to list a new property or update an existing one
    public shared(msg) func listProperty(property: Types.Property): async Text {
        let callerPrincipal = Principal.toText(msg.caller);
        let existingProperty = propertiesMap.get(callerPrincipal);
        switch (existingProperty) {
            case (null) {
                // No existing property, proceed to add a new one
                let propertyRecord = {
                    propertyId = property.propertyId;
                    requestorPrincipal = msg.caller;
                    address = property.address;
                    brickAPR = property.brickAPR;
                    brickValue = property.brickValue;
                    historicAnnualAppreciation = property.historicAnnualAppreciation;
                    location = property.location;
                    monthlyRentToOwnPayment = property.monthlyRentToOwnPayment;
                    price = property.price;
                    propertyDetails = property.propertyDetails;
                    propertyImages = property.propertyImages;
                    propertyLink = property.propertyLink;
                };
                propertiesMap.put(callerPrincipal, propertyRecord);
                Debug.print("Property listed by: " # callerPrincipal);
                return "Property listed successfully with ID: " # property.propertyId;
            };
            case (?existing) {
                // Existing property found, update if the same principal
                if (property.propertyId == existing.propertyId) {
                    let updatedProperty = {
                        propertyId = property.propertyId;
                        requestorPrincipal = msg.caller;
                        address = property.address;
                        brickAPR = property.brickAPR;
                        brickValue = property.brickValue;
                        historicAnnualAppreciation = property.historicAnnualAppreciation;
                        location = property.location;
                        monthlyRentToOwnPayment = property.monthlyRentToOwnPayment;
                        price = property.price;
                        propertyDetails = property.propertyDetails;
                        propertyImages = property.propertyImages;
                        propertyLink = property.propertyLink;
                    };
                    propertiesMap.put(callerPrincipal, updatedProperty);
                    return "Property updated successfully.";
                } else {
                    return "A property is already listed by this principal.";
                }
            };
        };
    };

    // Function to retrieve the property listed by the caller
    public shared(msg) func getProperty(): async ?Types.Property {
        let callerPrincipal = Principal.toText(msg.caller);
        return propertiesMap.get(callerPrincipal);
    };

    // Function to update the property details, only if the caller is the original lister
    public shared(msg) func updateProperty(updatedProperty: Types.Property): async Text {
        let callerPrincipal = Principal.toText(msg.caller);
        let maybeExistingProperty = propertiesMap.get(callerPrincipal);
        switch (maybeExistingProperty) {
            case (null){
                return "No property found for the caller.";
            };
            case (?existing) {
                if (updatedProperty.propertyId == existing.propertyId) {
                    propertiesMap.put(callerPrincipal, {
                        updatedProperty with
                        requestorPrincipal = msg.caller
                    });
                    return "Property updated successfully.";
                } else {
                    return "Property ID mismatch.";
                }
            };
        };
    };
};