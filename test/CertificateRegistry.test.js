const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CertificateRegistry", function () {
  let registry, admin, issuer, other;
  const hash = ethers.keccak256(ethers.toUtf8Bytes("certificato-1"));

  beforeEach(async function () {
    [admin, issuer, other] = await ethers.getSigners();
    registry = await ethers.deployContract("CertificateRegistry");
    await registry.addIssuer(issuer.address);
  });

  it("emette e verifica un certificato", async function () {
    await registry.connect(issuer).issue(hash);
    const r = await registry.verify(hash);
    expect(r.exists).to.equal(true);
    expect(r.revoked).to.equal(false);
    expect(r.issuer).to.equal(issuer.address);
  });

  it("rifiuta l'emissione da un non accreditato", async function () {
    await expect(registry.connect(other).issue(hash)).to.be.revertedWith(
      "Emittente non accreditato"
    );
  });

  it("permette la revoca all'emittente", async function () {
    await registry.connect(issuer).issue(hash);
    await registry.connect(issuer).revoke(hash, "errore di emissione");
    const r = await registry.verify(hash);
    expect(r.revoked).to.equal(true);
  });

  it("restituisce exists=false per un hash sconosciuto", async function () {
    const r = await registry.verify(hash);
    expect(r.exists).to.equal(false);
  });
});
