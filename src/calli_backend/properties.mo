import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Types "modules/types";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";

actor Properties {

    private var properties: HashMap.HashMap<Text, Types.Property> = HashMap.HashMap<Text, Types.Property>(10, Text.equal, Text.hash);

    public func addProperty(prop: Types.Property): async Text {
        properties.put(prop.id, prop);
        Debug.print("Property added: " # prop.id);
        return "Property added successfully with ID: " # prop.id;
    };

    public func getProperty(id: Text): async ?Types.Property {
        return properties.get(id);
    };
    public func getAllProperties(): async [Types.Property] {
        let entries = properties.entries();
        let array = Buffer.Buffer<Types.Property>(properties.size());
        for ((_, property) in entries) {
            array.add(property);
        };
        return Buffer.toArray(array);
    };
};