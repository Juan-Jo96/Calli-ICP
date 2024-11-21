import Principal "mo:base/Principal";
import CA "mo:candb/CanisterActions";
import CanDB "mo:candb/CanDB";
import Types "../modules/types";
import Option "mo:base/Option";
import Array "mo:base/Array";
import Entity "mo:candb/Entity";
import Debug "mo:base/Debug";

shared ({ caller = owner }) actor class WaitlistDB({
  partitionKey: Text;
  scalingOptions: CanDB.ScalingOptions;
  _owners: ?[Principal]
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

  // Add user to waitlist
  public shared({ caller = _caller }) func addUserWaitlist(user: Types.WaitlistUser): async Text {
    let entry = {
      sk = user.email;
      attributes = [
        ("name", #text(user.name)),
        ("email", #text(user.email)),
        ("country", #text(user.country))
      ];
    };
    await* CanDB.put(db, entry);
    return "Congratulations, #{user.name}! You have been added to the waitlist. We will keep in touch with you. 🇺🇸 /n ¡Felicidades, #{user.name}! Has sido añadido a la lista de espera. Nos mantendremos en contacto contigo. 🇲🇽";
  };

  // Get user from waitlist by email
  public query func getUserWaitlist(email: Text): async ?Types.WaitlistUser {
    let entity: ?Entity.Entity = CanDB.get(db, { sk = email });
    return Option.map<Entity.Entity, Types.WaitlistUser>(entity, func(e: Entity.Entity): Types.WaitlistUser {
      {
        name = switch (Entity.getAttributeMapValueForKey(e.attributes, "name")) {
          case (?value) {
            switch (value) {
              case (#text(t)) t;
              case (_) "";
            }
          };
          case (null) { "" };
        };
        email = switch (Entity.getAttributeMapValueForKey(e.attributes, "email")) {
          case (?value) {
            switch (value) {
              case (#text(t)) t;
              case (_) "";
            }
          };
          case (null) { "" };
        };
        country = switch (Entity.getAttributeMapValueForKey(e.attributes, "country")) {
          case (?value) {
            switch (value) {
              case (#text(t)) t;
              case (_) "";
            }
          };
          case (null) { "" };
        };
      }
    });
  };


  // Get all users from waitlist
public query func getAllUsers(): async [Types.WaitlistUser] {
    // Perform a scan with specific bounds if needed
    let scanResult = CanDB.scan(db, { 
        limit = 1000000;  // Large limit to retrieve as many as possible
        skLowerBound = "";  // Explicitly starting from the lowest key
        skUpperBound = "zzzzzzzzzzzzzzzzzz";  // Use a high upper bound that matches your data range
        ascending = ?true;  // Order results ascendingly for consistency
    });

    // Print out the entire scan result to debug the data retrieved
    Debug.print(debug_show(scanResult.entities));

    // Initialize an array to collect the users
    var users: [Types.WaitlistUser] = [];
    
    // Iterate over entities and add them to the list
    for (e in scanResult.entities.vals()) {
        Debug.print(debug_show(e));  // Print each entity to debug

        let user = {
            name = switch (Entity.getAttributeMapValueForKey(e.attributes, "name")) {
                case (?value) switch (value) {
                    case (#text(t)) t;
                    case (_) "";
                };
                case (null) "";
            };
            email = switch (Entity.getAttributeMapValueForKey(e.attributes, "email")) {
                case (?value) switch (value) {
                    case (#text(t)) t;
                    case (_) "";
                };
                case (null) "";
            };
            country = switch (Entity.getAttributeMapValueForKey(e.attributes, "country")) {
                case (?value) switch (value) {
                    case (#text(t)) t;
                    case (_) "";
                };
                case (null) "";
            };
        };
        
        users := Array.append(users, [user]);
    };

    // Print out the final list of users before returning
    Debug.print(debug_show(users));

    // Return the complete list of users
    return users;
};

  // Remove user from waitlist by email
  public shared({ caller = _caller }) func removeUserWaitlist(email: Text): async () {
    await async { CanDB.delete(db, {sk = email}) };
    return ();
  };
};