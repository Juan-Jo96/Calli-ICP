import Principal "mo:base/Principal";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";

actor Mensajeria {
    type Mensaje = {
        de: Principal;
        para: Principal;
        contenido: Text;
        fecha: Text;
    };

    private let mensajes = HashMap.HashMap<Text, Mensaje>(10, Text.equal, Text.hash);

    public shared(msg) func enviarMensaje(para : Principal, contenido : Text) : async Text {
        let mensajeId = Text.concat(Principal.toText(msg.caller), Principal.toText(para));
        let nuevoMensaje : Mensaje = {
            de = msg.caller;
            para = para;
            contenido = contenido;
            fecha = "Fecha actual"; // Aquí deberías usar una función para obtener la fecha actual
        };
        mensajes.put(mensajeId, nuevoMensaje);
        return "Mensaje enviado con éxito";
    };

    public func obtenerMensaje(id : Text) : async ?Mensaje {
        return mensajes.get(id);
    };

    public func obtenerTodosMensajes() : async [Mensaje] {
        return Iter.toArray(mensajes.vals());
    };
}