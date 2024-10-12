import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";

actor Contratos {
    type Contrato = {
        id: Text;
        propiedadId: Text;
        arrendatario: Principal;
        arrendador: Principal;
        montoMensual: Nat;
        duracion: Nat;
        fechaInicio: Text;
    };

    private let contratos = HashMap.HashMap<Text, Contrato>(10, Text.equal, Text.hash);

    public shared(msg) func crearContrato(contrato : Contrato) : async Text {
        contratos.put(contrato.id, contrato);
        return "Contrato creado con éxito";
    };

    public func obtenerContrato(id : Text) : async ?Contrato {
        return contratos.get(id);
    };

    public func obtenerTodosContratos() : async [Contrato] {
        return Iter.toArray(contratos.vals());
    };
}
