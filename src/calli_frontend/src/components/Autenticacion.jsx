import React, { useState } from 'react';
import { autenticacion } from '../../../declarations/autenticacion';

function Autenticacion() {
  const [nombre, setNombre] = useState('');
  const [mensaje, setMensaje] = useState('');

  const registrar = async () => {
    try {
      const resultado = await autenticacion.registrar(nombre);
      setMensaje(resultado);
    } catch (error) {
      setMensaje('Error al registrar: ' + error.message);
    }
  };

  return (
    <div>
      <h2>Autenticación</h2>
      <input
        type="text"
        value={nombre}
        onChange={(e) => setNombre(e.target.value)}
        placeholder="Ingrese su nombre"
      />
      <button onClick={registrar}>Registrar</button>
      <p>{mensaje}</p>
    </div>
  );
}

export default Autenticacion;
