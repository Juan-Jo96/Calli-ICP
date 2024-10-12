import React, { useState } from 'react';
import { perfiles } from '../../../declarations/perfiles';

function Perfiles() {
  const [perfil, setPerfil] = useState({ nombre: '', edad: 0, ocupacion: '', ingresoMensual: 0 });
  const [mensaje, setMensaje] = useState('');

  const crearPerfil = async () => {
    try {
      const resultado = await perfiles.crearPerfil(perfil);
      setMensaje(resultado);
    } catch (error) {
      setMensaje('Error al crear perfil: ' + error.message);
    }
  };

  return (
    <div>
      <h2>Perfiles</h2>
      <input
        type="text"
        value={perfil.nombre}
        onChange={(e) => setPerfil({...perfil, nombre: e.target.value})}
        placeholder="Nombre"
      />
      <input
        type="number"
        value={perfil.edad}
        onChange={(e) => setPerfil({...perfil, edad: parseInt(e.target.value)})}
        placeholder="Edad"
      />
      <input
        type="text"
        value={perfil.ocupacion}
        onChange={(e) => setPerfil({...perfil, ocupacion: e.target.value})}
        placeholder="Ocupación"
      />
      <input
        type="number"
        value={perfil.ingresoMensual}
        onChange={(e) => setPerfil({...perfil, ingresoMensual: parseInt(e.target.value)})}
        placeholder="Ingreso Mensual"
      />
      <button onClick={crearPerfil}>Crear Perfil</button>
      <p>{mensaje}</p>
    </div>
  );
}

export default Perfiles;
