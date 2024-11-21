import HashMap "mo:base/HashMap";
import Debug "mo:base/Debug";
import Types "modules/types";
import Buffer "mo:base/Buffer";
import Text "mo:base/Text";

actor Investors {

    private var investors: HashMap.HashMap<Text, Types.Investor> = HashMap.HashMap<Text, Types.Investor>(10, Text.equal, Text.hash);

    public func addInvestor(investor: Types.Investor): async Text {
        investors.put(investor.id, investor);
        Debug.print("Investor added: " # investor.id);
        return "Investor added successfully with ID: " # investor.id;
    };

    public func getInvestor(id: Text): async ?Types.Investor {
        return investors.get(id);
    };

    public func getAllInvestors(): async [Types.Investor] {
        let entries = investors.entries();
        let array = Buffer.Buffer<Types.Investor>(investors.size());
        for ((_, investor) in entries) {
            array.add(investor);
        };
        return Buffer.toArray(array);
    };
};