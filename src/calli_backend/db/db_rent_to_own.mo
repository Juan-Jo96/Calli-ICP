import Principal "mo:base/Principal";
import CanDB "mo:candb/CanDB";
import Types "../modules/types";
import Array "mo:base/Array";

shared ({ caller = owner }) actor class RentToOwnDB({
  partitionKey: Text;
  scalingOptions: CanDB.ScalingOptions;
  _owners: ?[Principal]
}) {
  stable var contractCanisters: [Principal] = [];

  /// Initialize CanDB
  stable let db = CanDB.init({
    pk = partitionKey;
    scalingOptions = scalingOptions;
    btreeOrder = null;
  });

  // Get the partition key
  public query func getPK(): async Text { return db.pk; };

  // Check if a specific contract exists
  public query func skExists(sk: Text): async Bool { 
    return CanDB.skExists(db, sk);
  };

  // Register a new contract canister
  public shared({ caller }) func registerContractCanister(canisterId: Principal): async () {
    if (caller == owner) {
      contractCanisters := Array.append(contractCanisters, [canisterId]);
    };
  };

  // Get a specific contract
  public func getContract(canisterId: Principal, sk: Text): async ?Types.RentToOwnContract {
    // Assuming each contract canister exposes a `getContract` method
    let contractCanister = actor(Principal.toText(canisterId)) : actor { getContract: (Text) -> async ?Types.RentToOwnContract };
    await contractCanister.getContract(sk);
  };

  // Get all contracts
  public func getAllContracts(): async [Types.RentToOwnContract] {
    var flattenedContracts : [Types.RentToOwnContract] = [];
    for (canisterId in contractCanisters.vals()) {
      let contractCanister = actor(Principal.toText(canisterId)) : actor { getAllContracts: () -> async [Types.RentToOwnContract] };
      let contracts = await contractCanister.getAllContracts();
      flattenedContracts := Array.append(flattenedContracts, contracts);
    };
    return flattenedContracts;
  };
};