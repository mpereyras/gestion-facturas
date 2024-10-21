const fs = require('fs');
const solc = require('solc');

// Lee el contenido del archivo del contrato
const content = fs.readFileSync('GestionFacturas.sol', 'utf8');

// Prepara el input para el compilador
const input = {
    language: 'Solidity',
    sources: {
        'GestionFacturas.sol': {
            content: content,
        },
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['abi']
            }
        }
    }
};

// Compila el contrato
const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Extrae el ABI
const contractFile = output.contracts['GestionFacturas.sol'];
const contractName = Object.keys(contractFile)[0];
const abi = contractFile[contractName].abi;

// Imprime el ABI
console.log(JSON.stringify(abi, null, 2));

// Opcionalmente, guarda el ABI en un archivo
fs.writeFileSync('ContractABI.json', JSON.stringify(abi, null, 2));