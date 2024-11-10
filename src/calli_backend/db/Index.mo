import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Text "mo:base/Text";
import Buffer "mo:stablebuffer/StableBuffer";
import Admin "mo:candb/CanDBAdmin";
import CA "mo:candb/CanisterActions";
import CanisterMap "mo:candb/CanisterMap";
import WaitlistDB "/db_Waitlist";
import RentToOwnDB "/db_rent_to_own";
import Utils "mo:candb/Utils";
import Array "mo:base/Array";

shared ({caller = owner}) actor class IndexCanister() = this {
  stable var pkToCanisterMap = CanisterMap.init();

  /// @required API (Do not delete or change)
  ///
  /// Get all canisters for a specific PK
  ///
  /// This method is called often by the candb-client query & update methods. 
  public shared query({caller = caller}) func getCanistersByPK(pk: Text): async [Text] {
    getCanisterIdsIfExists(pk);
  };
  
  /// Helper function that creates a waitlist DB canister for a given PK
  func createWaitlistDBCanister(pk: Text, controllers: ?[Principal]): async Text {
    Debug.print("creating new waitlist DB canister with pk=" # pk);
    Cycles.add(300_000_000_000);
    let newWaitlistDBCanister = await WaitlistDB.WaitlistDB({
      partitionKey = pk;
      scalingOptions = {
        autoScalingHook = autoScaleWaitlistDBCanister;
        sizeLimit = #count(3);
      };
      owners = ?[owner, Principal.fromActor(this)];
    });
    let newWaitlistDBCanisterPrincipal = Principal.fromActor(newWaitlistDBCanister);
    await CA.updateCanisterSettings({
      canisterId = newWaitlistDBCanisterPrincipal;
      settings = {
        controllers = controllers;
        compute_allocation = ?0;
        memory_allocation = ?0;
        freezing_threshold = ?2592000;
      }
    });

    let newWaitlistDBCanisterId = Principal.toText(newWaitlistDBCanisterPrincipal);
    pkToCanisterMap := CanisterMap.add(pkToCanisterMap, pk, newWaitlistDBCanisterId);

    newWaitlistDBCanisterId;
  };

  /// Helper function that creates a rent-to-own DB canister for a given PK
  func createRentToOwnDBCanister(pk: Text, controllers: ?[Principal]): async Text {
    Debug.print("creating new rent-to-own DB canister with pk=" # pk);
    Cycles.add(300_000_000_000);
    let newRentToOwnDBCanister = await RentToOwnDB.RentToOwnDB({
      partitionKey = pk;
      scalingOptions = {
        autoScalingHook = autoScaleRentToOwnDBCanister;
        sizeLimit = #count(3);
      };
      owners = ?[owner, Principal.fromActor(this)];
    });
    let newRentToOwnDBCanisterPrincipal = Principal.fromActor(newRentToOwnDBCanister);
    await CA.updateCanisterSettings({
      canisterId = newRentToOwnDBCanisterPrincipal;
      settings = {
        controllers = controllers;
        compute_allocation = ?0;
        memory_allocation = ?0;
        freezing_threshold = ?2592000;
      }
    });

    let newRentToOwnDBCanisterId = Principal.toText(newRentToOwnDBCanisterPrincipal);
    pkToCanisterMap := CanisterMap.add(pkToCanisterMap, pk, newRentToOwnDBCanisterId);

    newRentToOwnDBCanisterId;
  };

  /// This hook is called by CanDB for AutoScaling the Waitlist DB Actor.
  ///
  /// If the developer does not spin up an additional Waitlist DB canister in the same partition within this method, auto-scaling will NOT work
  public shared ({caller = caller}) func autoScaleWaitlistDBCanister(pk: Text): async Text {
    // Auto-Scaling Authorization - ensure the request to auto-scale the partition is coming from an existing canister in the partition, otherwise reject it
    if (Utils.callingCanisterOwnsPK(caller, pkToCanisterMap, pk)) {
      await createWaitlistDBCanister(pk, ?[owner, Principal.fromActor(this)]);
    } else {
      Debug.trap("error, called by non-controller=" # debug_show(caller));
    };
  };

  /// This hook is called by CanDB for AutoScaling the RentToOwn DB Actor.
  ///
  /// If the developer does not spin up an additional RentToOwn DB canister in the same partition within this method, auto-scaling will NOT work
  public shared ({caller = caller}) func autoScaleRentToOwnDBCanister(pk: Text): async Text {
    // Auto-Scaling Authorization - ensure the request to auto-scale the partition is coming from an existing canister in the partition, otherwise reject it
    if (Utils.callingCanisterOwnsPK(caller, pkToCanisterMap, pk)) {
      await createRentToOwnDBCanister(pk, ?[owner, Principal.fromActor(this)]);
    } else {
      Debug.trap("error, called by non-controller=" # debug_show(caller));
    };
  };

  /// Public API endpoint for spinning up a canister from the Waitlist DB Actor
  public shared({caller = creator}) func createWaitlistDB(): async ?Text {
    let callerPrincipalId = Principal.toText(creator);
    let waitlistPk = "waitlist#" # callerPrincipalId;
    let canisterIds = getCanisterIdsIfExists(waitlistPk);
    // does not exist
    if (canisterIds == []) {
      ?(await createWaitlistDBCanister(waitlistPk, ?[owner, Principal.fromActor(this)]));
    // already exists
    } else {
      Debug.print("already exists, not creating and returning null");
      null 
    };
  };

  /// Public API endpoint for spinning up a canister from the RentToOwn DB Actor
  public shared({caller = creator}) func createRentToOwnDB(): async ?Text {
    let callerPrincipalId = Principal.toText(creator);
    let rentToOwnPk = "renttoown#" # callerPrincipalId;
    let canisterIds = getCanisterIdsIfExists(rentToOwnPk);
    // does not exist
    if (canisterIds == []) {
      ?(await createRentToOwnDBCanister(rentToOwnPk, ?[owner, Principal.fromActor(this)]));
    // already exists
    } else {
      Debug.print("already exists, not creating and returning null");
      null 
    };
  };

  /// Spins down all canisters belonging to a specific user (transfers cycles back to the index canister, and stops/deletes all canisters)
  public shared({caller = caller}) func deleteLoggedInUser(): async () {
    let callerPrincipalId = Principal.toText(caller);
    let waitlistPk = "waitlist#" # callerPrincipalId;
    let rentToOwnPk = "renttoown#" # callerPrincipalId;
    let canisterIds = Array.append(getCanisterIdsIfExists(waitlistPk), getCanisterIdsIfExists(rentToOwnPk));
    if (canisterIds == []) {
      Debug.print("canister for user with principal=" # callerPrincipalId # " pk=" # waitlistPk # " or " # rentToOwnPk # " does not exist");
    } else {
      // can choose to use this statusMap for to detect failures and prompt retries if desired 
      let statusMap = await Admin.transferCyclesStopAndDeleteCanisters(canisterIds);
      pkToCanisterMap := CanisterMap.delete(pkToCanisterMap, waitlistPk);
      pkToCanisterMap := CanisterMap.delete(pkToCanisterMap, rentToOwnPk);
    };
  };

  /// @required function (Do not delete or change)
  ///
  /// Helper method acting as an interface for returning an empty array if no canisters
  /// exist for the given PK
  func getCanisterIdsIfExists(pk: Text): [Text] {
    switch(CanisterMap.get(pkToCanisterMap, pk)) {
      case null { [] };
      case (?canisterIdsBuffer) { Buffer.toArray(canisterIdsBuffer) } 
    }
  };

  /// Upgrade waitlist DB canisters in a PK range, i.e. rolling upgrades (limit is fixed at upgrading the canisters of 5 PKs per call)
  public shared({ caller = caller }) func upgradeWaitlistDBCanistersInPKRange(wasmModule: Blob): async Admin.UpgradePKRangeResult {
    if (caller != owner) { // basic authorization
      return {
        upgradeCanisterResults = [];
        nextKey = null;
      }
    }; 

    await Admin.upgradeCanistersInPKRange({
      canisterMap = pkToCanisterMap;
      lowerPK = "waitlist#";
      upperPK = "waitlist#:";
      limit = 5;
      wasmModule = wasmModule;
      scalingOptions = {
        autoScalingHook = autoScaleWaitlistDBCanister;
        sizeLimit = #count(20)
      };
      owners = ?[owner, Principal.fromActor(this)];
    });
  };

  /// Upgrade rent-to-own DB canisters in a PK range, i.e. rolling upgrades (limit is fixed at upgrading the canisters of 5 PKs per call)
  public shared({ caller = caller }) func upgradeRentToOwnDBCanistersInPKRange(wasmModule: Blob): async Admin.UpgradePKRangeResult {
    if (caller != owner) { // basic authorization
      return {
        upgradeCanisterResults = [];
        nextKey = null;
      }
    }; 

    await Admin.upgradeCanistersInPKRange({
      canisterMap = pkToCanisterMap;
      lowerPK = "renttoown#";
      upperPK = "renttoown#:";
      limit = 5;
      wasmModule = wasmModule;
      scalingOptions = {
        autoScalingHook = autoScaleRentToOwnDBCanister;
        sizeLimit = #count(20)
      };
      owners = ?[owner, Principal.fromActor(this)];
    });
  };
}