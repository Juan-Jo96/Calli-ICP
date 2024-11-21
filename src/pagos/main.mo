import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";

actor Pagos {
    type Pago = {
        de: Principal;
        para: Principal;
        monto: Nat;
        fecha: Text;
    };

    private let pagos = HashMap.HashMap<Text, Pago>(10, Text.equal, Text.hash);

    public shared(msg) func realizarPago(para : Principal, monto : Nat) : async Text {
        let pagoId = Text.concat(Principal.toText(msg.caller), Principal.toText(para));
        let nuevoPago : Pago = {
            de = msg.caller;
            para = para;
            monto = monto;
            fecha = "Fecha actual"; // Aquí deberías usar una función para obtener la fecha actual
        };
        pagos.put(pagoId, nuevoPago);
        return "Pago realizado con éxito";
    };

    public func obtenerPago(id : Text) : async ?Pago {
        return pagos.get(id);
    };

    public func obtenerTodosPagos() : async [Pago] {
        return Iter.toArray(pagos.vals());
    };
};