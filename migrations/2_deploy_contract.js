const Voucher = artifacts.require("Voucher");
const FlyingCashProxy = artifacts.require("FlyingCashProxy");
const FlyingCash = artifacts.require("FlyingCash");
const FeeManager = artifacts.require("FeeManager");
const FlyingCashAdapterFilda = artifacts.require("FlyingCashAdapterFilda");
const FlyingCashAdapterNoAsset = artifacts.require("FlyingCashAdapterNoAsset");

module.exports = async function (deployer, network, accounts) {
  const zeroAddr = "0x0000000000000000000000000000000000000000";

  if (network == "heco") {

    const fToken = '0xB16Df14C53C4bcfF220F4314ebCe70183dD804c0'; // fHUSD
    const lockToken = '0x0298c2b32eae4da002a15f36fdf7615bea3da047'; // HUSD

    console.log("deploying FlyingCash...");
    await deployer.deploy(FlyingCash);
    console.log("FlyingCash implement address: ", FlyingCash.address);
    await deployer.deploy(FlyingCashProxy, FlyingCash.address, accounts[1], []);
    console.log("FlyingCash proxy address: ", FlyingCashProxy.address);

    const flyingCash = await FlyingCash.at(FlyingCashProxy.address);

    console.log("deploying Voucher...");
    await deployer.deploy(Voucher, flyingCash.address, "Voucher HUSD TEST", "vHustT");
    console.log("voucher address: ", Voucher.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManager);
    console.log("FeeManager address: ", FeeManager.address);


    console.log("deploying Adapter...");
    await deployer.deploy(FlyingCashAdapterFilda, fToken);
    console.log("FlyingCashAdapterFilda address: ", FlyingCashAdapterFilda.address);

    console.log("init FlyingCash...");
    await flyingCash.init(
      accounts[0],    // _governance
      FlyingCashAdapterFilda.address, //_adapter
      lockToken,    // _lockToken
      Voucher.address, // _voucher
      FeeManager.address);

    console.log("set adapter whitelist...");
    const adapter = await FlyingCashAdapterFilda.deployed();
    await adapter.setWhitelist(FlyingCashProxy.address, true);

  } else if (network == "esc") {

    console.log("deploying FlyingCash...");
    await deployer.deploy(FlyingCash);
    console.log("FlyingCash implement address: ", FlyingCash.address);
    await deployer.deploy(FlyingCashProxy, FlyingCash.address, accounts[1], []);
    console.log("FlyingCash proxy address: ", FlyingCashProxy.address);

    const flyingCash = await FlyingCash.at(FlyingCashProxy.address);

    console.log("deploying Voucher...");
    await deployer.deploy(Voucher, flyingCash.address, "Voucher HUSD ESC TEST", "vHusdEscT");
    console.log("voucher address: ", Voucher.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManager);
    console.log("FeeManager address: ", FeeManager.address);


    console.log("deploying Adapter...");
    await deployer.deploy(FlyingCashAdapterNoAsset, "HUSD ESC TEST", "husdEscT");
    console.log("FlyingCashAdapterNoAsset address: ", FlyingCashAdapterNoAsset.address);

    console.log("init FlyingCash...");
    await flyingCash.init(
      accounts[0],    // _governance
      FlyingCashAdapterNoAsset.address, //_adapter
      FlyingCashAdapterNoAsset.address, // _lockToken
      Voucher.address,    // _voucher
      FeeManager.address);

    console.log("set adapter whitelist...");
    const adapter = await FlyingCashAdapterNoAsset.deployed();
    await adapter.setWhitelist(FlyingCashProxy.address, true);
  }
};
