import Principal "mo:base/Principal";
import CA "mo:candb/CanisterActions";
import CanDB "mo:candb/CanDB";
import Entity "mo:candb/Entity";
import Types "../modules/types";
import Float "mo:base/Float";
import Option "mo:base/Option";
import Array "mo:base/Array";

shared ({ caller = owner }) actor class RentToOwnService({
  partitionKey: Text;
  scalingOptions: CanDB.ScalingOptions;
  owners: ?[Principal]
}) {

  /// @required (may wrap, but must be present in some form in the canister)
  ///
  /// Initialize CanDB
  stable let db = CanDB.init({
    pk = partitionKey;
    scalingOptions = scalingOptions;
    btreeOrder = null;
  });

  /// @recommended (not required) public API
  public query func getPK(): async Text { db.pk };

  /// @required public API (Do not delete or change)
  public query func skExists(sk: Text): async Bool { 
    CanDB.skExists(db, sk);
  };

  /// @required public API (Do not delete or change)
  public shared({ caller = caller }) func transferCycles(): async () {
    if (caller == owner) {
      await CA.transferCycles(caller);
    };
  };

  // Add rent-to-own contract
  public shared({ caller = caller }) func addContract(contract: Types.RentToOwnContract): async Text {
    let attributePairs: [(Entity.AttributeKey, Entity.AttributeValue)] = [
      ("propertyID", #text(Principal.toText(contract.propertyID))),
      ("tenant", #text(Principal.toText(contract.tenant))),
      ("landlord", #text(Principal.toText(contract.landlord))),
      (("monthlyAmount"), #int(Float.toInt(contract.monthlyAmount))),
      (("duration"), #int(contract.duration)),
      (("startDate"), #text(contract.startDate))
    ];
    let entity = { attributes = attributePairs; sk = Principal.toText(contract.propertyID) };
    await* CanDB.put(db, entity);
    return "Contract added successfully.";
  };

  // Get rent-to-own contract by property ID
  public query func getContract(propertyId: Text): async ?Types.RentToOwnContract {
    let entity = CanDB.get(db, { sk = propertyId });
    return Option.map(entity, func(e: Entity.Entity): Types.RentToOwnContract {
      {
        propertyID = Principal.fromText(e.sk);
        tenant = Principal.fromText(switch (Entity.getAttributeMapValueForKey(e.attributes, "tenant")) {
          case (?#text(t)) t;
          case _ "";
        });
        landlord = Principal.fromText(switch (Entity.getAttributeMapValueForKey(e.attributes, "landlord")) {
          case (?#text(t)) t;
          case _ "";
        });
        monthlyAmount = switch (Entity.getAttributeMapValueForKey(e.attributes, "monthlyAmount")) {
          case (?#int(amount)) Float.fromInt(amount);
          case _ 0.0;
        };
        duration = switch (Entity.getAttributeMapValueForKey(e.attributes, "duration")) {
          case (?#int(dur)) dur;
          case _ 0;
        };
        startDate = switch (Entity.getAttributeMapValueForKey(e.attributes, "startDate")) {
          case (?#text(date)) date;
          case _ "";
        };
      }
    });
  };

  // Get all rent-to-own contracts
  public query func getAllContracts(): async [Types.RentToOwnContract] {
    let scanResult = CanDB.scan(db, { 
      limit = 999999; 
      skLowerBound = ""; 
      skUpperBound = "ZZZZZZZZZZ"; 
      ascending = ?true 
    });
    var contracts: [Types.RentToOwnContract] = [];
    let iter = scanResult.entities.vals();
    var next = iter.next();
    while (Option.isSome(next)) {
      let e = Option.get(next, { pk = ""; sk = ""; attributes = Entity.createAttributeMapFromKVPairs([]) });
      contracts := Array.append<Types.RentToOwnContract>(contracts, [{
        propertyID = Principal.fromText(e.sk);
        tenant = Principal.fromText(switch (Entity.getAttributeMapValueForKey(e.attributes, "tenant")) {
          case (?#text(t)) t;
          case _ "";
        });
        landlord = Principal.fromText(switch (Entity.getAttributeMapValueForKey(e.attributes, "landlord")) {
          case (?#text(t)) t;
          case _ "";
        });
        monthlyAmount = switch (Entity.getAttributeMapValueForKey(e.attributes, "monthlyAmount")) {
          case (?#int(amount)) Float.fromInt(amount);
          case _ 0.0;
        };
        duration = switch (Entity.getAttributeMapValueForKey(e.attributes, "duration")) {
          case (?#int(dur)) dur;
          case _ 0;
        };
        startDate = switch (Entity.getAttributeMapValueForKey(e.attributes, "startDate")) {
          case (?#text(date)) date;
          case _ "";
        };
      }]);
      next := iter.next();
    };
    return contracts;
  };

  // Remove rent-to-own contract by property ID
  public shared({ caller = caller }) func removeContract(propertyId: Text): async () {
    await async { CanDB.delete(db, { sk = propertyId }) };
    return ();
  };
}