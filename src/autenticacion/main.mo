import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";

actor Autenticacion {
    private let usuarios = HashMap.HashMap<Principal, Text>(10, Principal.equal, Principal.hash);

    public shared(msg) func registrar(nombre : Text) : async Text {
        usuarios.put(msg.caller, nombre);
        return "Usuario registrado con éxito";
    };

    public func obtenerNombre(usuario : Principal) : async ?Text {
        return usuarios.get(usuario);
    };

    public func obtenerTodosUsuarios() : async [(Principal, Text)] {
        return Iter.toArray(usuarios.entries());
    };
}