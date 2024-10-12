import React, { useState, useEffect } from 'react';
import { mensajeria } from '../../../declarations/mensajeria';

function Mensajeria() {
  const [mensaje, setMensaje] = useState({ para: '', contenido: '' });
  const [listaMensajes, setListaMensajes] = useState([]);
  const [statusMensaje, setStatusMensaje] = useState('');

  useEffect(() => {
    cargarMensajes();
  }, []);

  const cargarMensajes = async () => {
    try {
      const mensajesList = await mensajeria.obtenerMensajes();
      setListaMensajes(mensajesList);
    } catch (error) {
      setStatusMensaje('Error al cargar mensajes: ' + error.message);
    }
  };

  const enviarMensaje = async () => {
    try {
      const resultado = await mensajeria.enviarMensaje(mensaje.para, mensaje.contenido);
      setStatusMensaje(resultado);
      cargarMensajes();
    } catch (error) {
      setStatusMensaje('Error al enviar mensaje: ' + error.message);
    }
  };

  return (
    <div>
      <h2>Mensajería</h2>
      <input
        type="text"
        value={mensaje.para}
        onChange={(e) => setMensaje({...mensaje, para: e.target.value})}
        placeholder="Para (ID del destinatario)"
      />
      <textarea
        value={mensaje.contenido}
        onChange={(e) => setMensaje({...mensaje, contenido: e.target.value})}
        placeholder="Contenido del mensaje"
      />
      <button onClick={enviarMensaje}>Enviar Mensaje</button>
      <p>{statusMensaje}</p>
      <h3>Mensajes:</h3>
      <ul>
        {listaMensajes.map((msg, index) => (
          <li key={index}>{msg.de} {'->'} {msg.para}: {msg.contenido}</li>
        ))}
      </ul>
    </div>
  );
}

export default Mensajeria;
