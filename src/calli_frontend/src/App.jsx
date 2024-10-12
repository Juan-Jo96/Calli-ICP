import React from 'react';
import Autenticacion from './components/Autenticacion';
import Perfiles from './components/Perfiles';
import Propiedades from './components/Propiedades';
import Contratos from './components/Contratos';
import Mensajeria from './components/Mensajeria';
import Pagos from './components/Pagos';

function App() {
  return (
    <div className="App">
      <h1>Bienvenido a Calli</h1>
      <Autenticacion />
      <Perfiles />
      <Propiedades />
      <Contratos />
      <Mensajeria />
      <Pagos />
    </div>
  );
}

export default App;
