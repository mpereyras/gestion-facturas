const hre = require("hardhat");

async function main() {
  const usdcAddress = "0x036CbD53842c5426634e7929541eC2318f3dCF7e"; // Reemplaza con la dirección real de USDC en Base Sepolia

  const GestionFacturas = await hre.ethers.getContractFactory("GestionFacturas");
  const gestionFacturas = await GestionFacturas.deploy(usdcAddress);

  await gestionFacturas.deployed();

  console.log("GestionFacturas desplegado en:", gestionFacturas.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });