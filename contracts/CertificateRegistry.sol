// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Registro di certificati (scheletro iniziale di PoliCert)
/// @notice On-chain solo hash e metadati minimi, nessun dato personale.
contract CertificateRegistry {
    struct Certificate {
        address issuer;
        uint64 issuedAt;
        bool revoked;
    }

    address public admin;
    mapping(address => bool) public issuers;
    mapping(bytes32 => Certificate) private certificates;

    event IssuerAdded(address indexed issuer);
    event IssuerRemoved(address indexed issuer);
    event CertificateIssued(bytes32 indexed hash, address indexed issuer);
    event CertificateRevoked(bytes32 indexed hash, string reason);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Solo admin");
        _;
    }

    modifier onlyIssuer() {
        require(issuers[msg.sender], "Emittente non accreditato");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function addIssuer(address issuer) external onlyAdmin {
        issuers[issuer] = true;
        emit IssuerAdded(issuer);
    }

    function removeIssuer(address issuer) external onlyAdmin {
        issuers[issuer] = false;
        emit IssuerRemoved(issuer);
    }

    function issue(bytes32 hash) external onlyIssuer {
        require(certificates[hash].issuer == address(0), "Gia emesso");
        certificates[hash] = Certificate(msg.sender, uint64(block.timestamp), false);
        emit CertificateIssued(hash, msg.sender);
    }

    function revoke(bytes32 hash, string calldata reason) external onlyIssuer {
        Certificate storage c = certificates[hash];
        require(c.issuer == msg.sender, "Non emesso da te");
        require(!c.revoked, "Gia revocato");
        c.revoked = true;
        emit CertificateRevoked(hash, reason);
    }

    function verify(bytes32 hash)
        external
        view
        returns (bool exists, bool revoked, address issuer, uint64 issuedAt)
    {
        Certificate storage c = certificates[hash];
        return (c.issuer != address(0), c.revoked, c.issuer, c.issuedAt);
    }
}
