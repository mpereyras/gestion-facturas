Gestión de Factoring en Blockchain
  Este contrato implementa un sistema de factoring utilizando tecnología blockchain. 
  Permite registrar, validar y comprar facturas, todo gestionado a través de smart contracts en la red Base (testnet Sepolia).

Características
  Registro de facturas con información detallada
  Validación de facturas
  Compra de facturas

Tecnologías Utilizadas

Solidity: para escribir smart contracts
Hardhat: entorno de desarrollo para Ethereum
JavaScript: para scripts de despliegue y pruebas
Base Sepolia: red de prueba para desplegar y probar los contratos

Estructura del Proyecto
Copygestion-facturas/
├── contracts/
│   └── FactoringSystemERC20.sol
├── scripts/
│   ├── deploy.js
│   └── verify.js
├── test/
│   └── FactoringSystem.test.js
├── hardhat.config.js
└── README.md

Prerequisitos

Node.js (v14.0.0 o superior)
npm (v6.0.0 o superior)
Una wallet con ETH en Base Sepolia testnet
