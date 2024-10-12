import React, { useState } from 'react';
import { pagos } from '../../../declarations/pagos';

function Pagos() {
  const [pago, setPago] = useState({ para: '', monto: 0 });
  const [mensaje, setMensaje] = useState('');

  const realizarPago = async () => {
    try {
      const resultado = await pagos.realizarPago(pago.para, pago.monto);
      setMensaje(resultado);
    } catch (error) {
      setMensaje('Error al realizar pago: ' + error.message);
    }
  };

  return (
    <div>
      <h2>Pagos</h2>
      <input
        type="text"
        value={pago.para}
        onChange={(e) => setPago({...pago, para: e.target.value})}
        placeholder="Para (ID del destinatario)"
      />
      <input
        type="number"
        value={pago.monto}
        onChange={(e) => setPago({...pago, monto: parseInt(e.target.value)})}
        placeholder="Monto"
      />
      <button onClick={realizarPago}>Realizar Pago</button>
      <p>{mensaje}</p>
    </div>
  );
}

export default Pagos;
