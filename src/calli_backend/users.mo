import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor Perfiles {
    type Perfil = {
        nombre: Text;
        edad: Nat;
        ocupacion: Text;
        ingresoMensual: Nat;
    };

    private let perfiles = HashMap.HashMap<Principal, Perfil>(10, Principal.equal, Principal.hash);

    public shared(msg) func crearPerfil(perfil : Perfil) : async Text {
        perfiles.put(msg.caller, perfil);
        return "Perfil creado con éxito";
    };

    public func obtenerPerfil(usuario : Principal) : async ?Perfil {
        return perfiles.get(usuario);
    };

    public func obtenerTodosPerfiles() : async [(Principal, Perfil)] {
        return Iter.toArray(perfiles.entries());
    };
}