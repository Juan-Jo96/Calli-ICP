import React, { useState, useEffect } from 'react';
import { propiedades } from '../../../declarations/propiedades';

function Propiedades() {
  const [propiedad, setPropiedad] = useState({ id: '', direccion: '', precio: 0, descripcion: '' });
  const [listaPropiedades, setListaPropiedades] = useState([]);
  const [mensaje, setMensaje] = useState('');

  useEffect(() => {
    cargarPropiedades();
  }, []);

  const cargarPropiedades = async () => {
    try {
      const propiedadesList = await propiedades.obtenerTodasPropiedades();
      setListaPropiedades(propiedadesList);
    } catch (error) {
      setMensaje('Error al cargar propiedades: ' + error.message);
    }
  };

  const listarPropiedad = async () => {
    try {
      const resultado = await propiedades.listarPropiedad(propiedad);
      setMensaje(resultado);
      cargarPropiedades();
    } catch (error) {
      setMensaje('Error al listar propiedad: ' + error.message);
    }
  };

  return (
    <div>
      <h2>Propiedades</h2>
      <input
        type="text"
        value={propiedad.id}
        onChange={(e) => setPropiedad({...propiedad, id: e.target.value})}
        placeholder="ID"
      />
      <input
        type="text"
        value={propiedad.direccion}
        onChange={(e) => setPropiedad({...propiedad, direccion: e.target.value})}
        placeholder="Dirección"
      />
      <input
        type="number"
        value={propiedad.precio}
        onChange={(e) => setPropiedad({...propiedad, precio: parseInt(e.target.value)})}
        placeholder="Precio"
      />
      <input
        type="text"
        value={propiedad.descripcion}
        onChange={(e) => setPropiedad({...propiedad, descripcion: e.target.value})}
        placeholder="Descripción"
      />
      <button onClick={listarPropiedad}>Listar Propiedad</button>
      <p>{mensaje}</p>
      <h3>Propiedades Listadas:</h3>
      <ul>
        {listaPropiedades.map((prop) => (
          <li key={prop.id}>{prop.direccion} - ${prop.precio}</li>
        ))}
      </ul>
    </div>
  );
}

export default Propiedades;
