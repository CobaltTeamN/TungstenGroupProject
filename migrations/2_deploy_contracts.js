const CHCToken = artifacts.require("CHCToken");
const WoodToken = artifacts.require("WoodToken");
const Smit = artifacts.require("SmitCoin");
const Slick = artifacts.require("Token");
const Ham = artifacts.require("HAM");
const Bank = artifacts.require("Bank");
const Oracle = artifacts.require("ExchangeOracle");
const NFTLoan = artifacts.require("NFTLoan");
const Chromium = artifacts.require("Chromium");

module.exports = async function (deployer) {
  // deploy my contracts
  await deployer.deploy(CHCToken, "1000000000000000000000000");
  const CHCtoken = await CHCToken.deployed();

  await deployer.deploy(WoodToken);
  const woodToken = await WoodToken.deployed();

  await deployer.deploy(Smit);
  const smitToken = await Smit.deployed();

  await deployer.deploy(Slick);
  const slickToken = await Smit.deployed();

  await deployer.deploy(Ham);
  const hamToken = await Smit.deployed();

  await deployer.deploy(Oracle);
  const oracle = await Oracle.deployed();

  await deployer.deploy(NFTLoan);

  await deployer.deploy(
    Bank,
    [
      CHCtoken.address,
      woodToken.address,
      smitToken.address,
      slickToken.address,
      hamToken.address,
    ],
    "0x433c6e3d2def6e1fb414cf9448724efb0399b698",
    oracle.address
  );
  const bank = await Bank.deployed();

  await deployer.deploy(
    Chromium,
    oracle.address,
    "0x433c6e3d2def6e1fb414cf9448724efb0399b698"
  );
  const chromium = await Chromium.deployed();
};
