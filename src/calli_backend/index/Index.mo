import Cycles "mo:base/ExperimentalCycles";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Buffer "mo:stablebuffer/StableBuffer";
import Admin "mo:candb/CanDBAdmin";
import CA "mo:candb/CanisterActions";
import CanisterMap "mo:candb/CanisterMap";
import Waitlist "../waitlist/WaitlistService";
import Utils "mo:candb/Utils";

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
  
  /// Helper function that creates a waitlist service canister for a given PK
  func createWaitlistServiceCanister(pk: Text, controllers: ?[Principal]): async Text {
    Debug.print("creating new waitlist service canister with pk=" # pk);
    Cycles.add(300_000_000_000);
    let newWaitlistServiceCanister = await Waitlist.WaitlistService({
      partitionKey = pk;
      scalingOptions = {
        autoScalingHook = autoScaleWaitlistServiceCanister;
        sizeLimit = #count(3);
      };
      owners = ?[owner, Principal.fromActor(this)];
    });
    let newWaitlistServiceCanisterPrincipal = Principal.fromActor(newWaitlistServiceCanister);
    await CA.updateCanisterSettings({
      canisterId = newWaitlistServiceCanisterPrincipal;
      settings = {
        controllers = controllers;
        compute_allocation = ?0;
        memory_allocation = ?0;
        freezing_threshold = ?2592000;
      }
    });

    let newWaitlistServiceCanisterId = Principal.toText(newWaitlistServiceCanisterPrincipal);
    pkToCanisterMap := CanisterMap.add(pkToCanisterMap, pk, newWaitlistServiceCanisterId);

    newWaitlistServiceCanisterId;
  };

  /// This hook is called by CanDB for AutoScaling the Waitlist Service Actor.
  ///
  /// If the developer does not spin up an additional Waitlist service canister in the same partition within this method, auto-scaling will NOT work
  public shared ({caller = caller}) func autoScaleWaitlistServiceCanister(pk: Text): async Text {
    // Auto-Scaling Authorization - ensure the request to auto-scale the partition is coming from an existing canister in the partition, otherwise reject it
    if (Utils.callingCanisterOwnsPK(caller, pkToCanisterMap, pk)) {
      await createWaitlistServiceCanister(pk, ?[owner, Principal.fromActor(this)]);
    } else {
      Debug.trap("error, called by non-controller=" # debug_show(caller));
    };
  };
  
  /// Public API endpoint for spinning up a canister from the Waitlist Service Actor
  public shared({caller = creator}) func createWaitlistService(): async ?Text {
    let callerPrincipalId = Principal.toText(creator);
    let waitlistPk = "waitlist#" # callerPrincipalId;
    let canisterIds = getCanisterIdsIfExists(waitlistPk);
    // does not exist
    if (canisterIds == []) {
      ?(await createWaitlistServiceCanister(waitlistPk, ?[owner, Principal.fromActor(this)]));
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
    let canisterIds = getCanisterIdsIfExists(waitlistPk);
    if (canisterIds == []) {
      Debug.print("canister for user with principal=" # callerPrincipalId # " pk=" # waitlistPk # " does not exist");
    } else {
      // can choose to use this statusMap for to detect failures and prompt retries if desired 
      let statusMap = await Admin.transferCyclesStopAndDeleteCanisters(canisterIds);
      pkToCanisterMap := CanisterMap.delete(pkToCanisterMap, waitlistPk);
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

  /// Upgrade waitlist service canisters in a PK range, i.e. rolling upgrades (limit is fixed at upgrading the canisters of 5 PKs per call)
  public shared({ caller = caller }) func upgradeWaitlistServiceCanistersInPKRange(wasmModule: Blob): async Admin.UpgradePKRangeResult {
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
        autoScalingHook = autoScaleWaitlistServiceCanister;
        sizeLimit = #count(20)
      };
      owners = ?[owner, Principal.fromActor(this)];
    });
  };
}