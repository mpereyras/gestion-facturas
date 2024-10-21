// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract GestionFacturas {
    IERC20 public usdcToken;

    struct Factura {
        string numeroFactura;
        address proveedor;
        address cliente;
        uint256 fechaEmision;
        uint256 fechaVencimiento;
        uint256 importe;
        string correoElectronico;
        string estado; // "R" = Registrado, "P" = Pendiente, "V" = Vendido, "C" = Cobrado
        address comprador;
    }

    mapping(string => Factura) public facturas;
    string[] public listaFacturas;

    uint256 public constant DESCUENTO_DIARIO = 15; // 0.15% en base 10000
    uint256 public constant COMISION = 500; // 5% en base 10000

    event FacturaRegistrada(string numeroFactura, address proveedor);
    event FacturaValidada(string numeroFactura);
    event FacturaComprada(
        string numeroFactura,
        address comprador,
        uint256 importePagado
    );
    event FacturaCobrada(
        string numeroFactura,
        uint256 importeCobrado,
        uint256 comision
    );

    constructor(address _usdcAddress) {
        usdcToken = IERC20(_usdcAddress);
    }

    function registrarFactura(
        string memory _numeroFactura,
        address _cliente,
        uint256 _fechaEmision,
        uint256 _fechaVencimiento,
        uint256 _importe,
        string memory _correoElectronico
    ) public {
        require(
            facturas[_numeroFactura].fechaEmision == 0,
            "Factura ya existe"
        );

        Factura memory nuevaFactura = Factura({
            numeroFactura: _numeroFactura,
            proveedor: msg.sender,
            cliente: _cliente,
            fechaEmision: _fechaEmision,
            fechaVencimiento: _fechaVencimiento,
            importe: _importe,
            correoElectronico: _correoElectronico,
            estado: "R",
            comprador: address(0)
        });

        facturas[_numeroFactura] = nuevaFactura;
        listaFacturas.push(_numeroFactura);

        emit FacturaRegistrada(_numeroFactura, msg.sender);
    }

    function validarFactura(string memory _numeroFactura) public {
        require(
            keccak256(abi.encodePacked(facturas[_numeroFactura].estado)) ==
                keccak256(abi.encodePacked("R")),
            "Factura no esta en estado Registrado"
        );
        facturas[_numeroFactura].estado = "P";
        emit FacturaValidada(_numeroFactura);
    }

    function comprarFactura(string memory _numeroFactura) public {
        Factura storage factura = facturas[_numeroFactura];
        require(
            keccak256(abi.encodePacked(factura.estado)) ==
                keccak256(abi.encodePacked("P")),
            "Factura no esta disponible para compra"
        );

        uint256 diasHastaVencimiento = (factura.fechaVencimiento -
            block.timestamp) / 1 days;
        uint256 descuento = (factura.importe *
            DESCUENTO_DIARIO *
            diasHastaVencimiento) / 10000;
        uint256 importeConDescuento = factura.importe - descuento;

        require(
            usdcToken.balanceOf(msg.sender) >= importeConDescuento,
            "Saldo USDC insuficiente"
        );
        require(
            usdcToken.allowance(msg.sender, address(this)) >=
                importeConDescuento,
            "Allowance USDC insuficiente"
        );

        factura.estado = "V";
        factura.comprador = msg.sender;

        require(
            usdcToken.transferFrom(
                msg.sender,
                factura.proveedor,
                importeConDescuento
            ),
            "Transferencia USDC fallida"
        );

        emit FacturaComprada(_numeroFactura, msg.sender, importeConDescuento);
    }

    function cobrarFactura(string memory _numeroFactura) public {
        Factura storage factura = facturas[_numeroFactura];
        require(
            msg.sender == factura.cliente,
            "Solo el cliente puede pagar la factura"
        );
        require(
            keccak256(abi.encodePacked(factura.estado)) ==
                keccak256(abi.encodePacked("V")),
            "Factura no esta vendida"
        );
        require(
            block.timestamp >= factura.fechaVencimiento,
            "Factura aun no ha vencido"
        );

        uint256 importeTotal = factura.importe;
        require(
            usdcToken.balanceOf(msg.sender) >= importeTotal,
            "Saldo USDC insuficiente"
        );
        require(
            usdcToken.allowance(msg.sender, address(this)) >= importeTotal,
            "Allowance USDC insuficiente"
        );

        uint256 ganancia = importeTotal - factura.importe;
        uint256 comision = (ganancia * COMISION) / 10000;
        uint256 pagoComprador = importeTotal - comision;

        factura.estado = "C";

        require(
            usdcToken.transferFrom(
                msg.sender,
                factura.comprador,
                pagoComprador
            ),
            "Transferencia USDC al comprador fallida"
        );
        require(
            usdcToken.transferFrom(msg.sender, address(this), comision),
            "Transferencia USDC de comision fallida"
        );

        emit FacturaCobrada(_numeroFactura, importeTotal, comision);
    }

    function getFacturasPendientes() public view returns (string[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < listaFacturas.length; i++) {
            if (
                keccak256(
                    abi.encodePacked(facturas[listaFacturas[i]].estado)
                ) == keccak256(abi.encodePacked("P"))
            ) {
                count++;
            }
        }

        string[] memory facturasPendientes = new string[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < listaFacturas.length; i++) {
            if (
                keccak256(
                    abi.encodePacked(facturas[listaFacturas[i]].estado)
                ) == keccak256(abi.encodePacked("P"))
            ) {
                facturasPendientes[index] = listaFacturas[i];
                index++;
            }
        }

        return facturasPendientes;
    }
}
