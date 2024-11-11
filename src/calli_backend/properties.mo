import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor Propiedades {
    type Propiedad = {
        id: Text;
        direccion: Text;
        precio: Nat;
        descripcion: Text;
        propietario: Principal;
    };

    private let propiedades = HashMap.HashMap<Text, Propiedad>(10, Text.equal, Text.hash);

    public shared(msg) func listarPropiedad(prop : Propiedad) : async Text {
        propiedades.put(prop.id, prop);
        return "Propiedad listada con éxito";
    };

    public func obtenerPropiedad(id : Text) : async ?Propiedad {
        return propiedades.get(id);
    };

    public func obtenerTodasPropiedades() : async [Propiedad] {
        return Array.map(Iter.toArray(propiedades.vals()), func (x: Propiedad) : Propiedad { x });
    };
}
