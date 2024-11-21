import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Types "modules/types";
import Buffer "mo:base/Buffer";
actor YoungLatinos {

    private var YoungLatinos: HashMap.HashMap<Text, Types.YoungLatino> = HashMap.HashMap<Text, Types.YoungLatino>(10, Text.equal, Text.hash);

    public func addYongLatino(YongLatino: Types.YoungLatino): async Text {
        YoungLatinos.put(YongLatino.id, YongLatino);
        Debug.print("YongLatino added: " # YongLatino.id);
        return "YongLatino added successfully with ID: " # YongLatino.id;
    };

    public func getYongLatino(id: Text): async ?Types.YoungLatino {
        return YoungLatinos.get(id);
    };

    public func getAllYoungLatinos(): async [Types.YoungLatino] {
        let entries = YoungLatinos.entries();
        let array = Buffer.Buffer<Types.YoungLatino>(YoungLatinos.size());
        for ((_, YongLatino) in entries) {
            array.add(YongLatino);
        };
        return Buffer.toArray(array);
    };
};