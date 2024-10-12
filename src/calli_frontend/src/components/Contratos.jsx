import React, { useState } from 'react';
import { contratos } from '../../../declarations/contratos';

function Contratos() {
  const [contrato, setContrato] = useState({ 
    id: '', 
    propiedadId: '', 
    arrendatario: '', 
    arrendador: '', 
    montoMensual: 0, 
    duracion: 0, 
    fechaInicio: '' 
  });
  const [mensaje, setMensaje] = useState('');

  const crearContrato = async () => {
    try {
      const resultado = await contratos.crearContrato(contrato);
      setMensaje(resultado);
    } catch (error) {
      setMensaje('Error al crear contrato: ' + error.message);
    }
  };

  return (
    <div>
      <h2>Contratos</h2>
      <input
        type="text"
        value={contrato.id}
        onChange={(e) => setContrato({...contrato, id: e.target.value})}
        placeholder="ID del Contrato"
      />
      <input
        type="text"
        value={contrato.propiedadId}
        onChange={(e) => setContrato({...contrato, propiedadId: e.target.value})}
        placeholder="ID de la Propiedad"
      />
      <input
        type="text"
        value={contrato.arrendatario}
        onChange={(e) => setContrato({...contrato, arrendatario: e.target.value})}
        placeholder="Arrendatario"
      />
      <input
        type="text"
        value={contrato.arrendador}
        onChange={(e) => setContrato({...contrato, arrendador: e.target.value})}
        placeholder="Arrendador"
      />
      <input
        type="number"
        value={contrato.montoMensual}
        onChange={(e) => setContrato({...contrato, montoMensual: parseInt(e.target.value)})}
        placeholder="Monto Mensual"
      />
      <input
        type="number"
        value={contrato.duracion}
        onChange={(e) => setContrato({...contrato, duracion: parseInt(e.target.value)})}
        placeholder="Duración (meses)"
      />
      <input
        type="date"
        value={contrato.fechaInicio}
        onChange={(e) => setContrato({...contrato, fechaInicio: e.target.value})}
        placeholder="Fecha de Inicio"
      />
      <button onClick={crearContrato}>Crear Contrato</button>
      <p>{mensaje}</p>
    </div>
  );
}

export default Contratos;
