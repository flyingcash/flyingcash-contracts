const Voucher = artifacts.require("Voucher");
const FlyingCashProxy = artifacts.require("FlyingCashProxy");
const FlyingCash = artifacts.require("FlyingCash");
const FeeManager = artifacts.require("FeeManager");
const FeeManagerNoAsset = artifacts.require("FeeManagerNoAsset");
const AdapterProxy = artifacts.require("AdapterProxy");
const FlyingCashAdapterFilda = artifacts.require("FlyingCashAdapterFilda");
const FlyingCashAdapterNoAsset = artifacts.require("FlyingCashAdapterNoAsset");
const FlyingCashToken = artifacts.require("FlyingCashToken");

const argv = require('minimist')(process.argv.slice(2),
        {string: ['ftoken', 'lockToken', 'vsymbol', 'vname', 'admin', 'gov', 'tokenName', 'tokenSymbol']});

module.exports = async function (deployer, network, accounts) {
  const zeroAddr = "0x0000000000000000000000000000000000000000";

  console.log("argv: ", argv);
  if (network == "heco") {

    const ftoken = argv['ftoken'];
    const lockToken = argv['lockToken'];
    const vsymbol = argv['vsymbol'];
    const vname = argv['vname'];
    const admin = argv['admin'];
    const gov = argv['gov'];
    const feelowerLimit = argv['feelowerLimit'];
    const feeupperLimit = argv['feeupperLimit'];

    console.log("deploying FlyingCash...");
    await deployer.deploy(FlyingCash);
    console.log("FlyingCash implement address: ", FlyingCash.address);
    await deployer.deploy(FlyingCashProxy, FlyingCash.address, admin, []);
    console.log("FlyingCash proxy address: ", FlyingCashProxy.address);

    const flyingCash = await FlyingCash.at(FlyingCashProxy.address);

    console.log("deploying Voucher...");
    await deployer.deploy(Voucher, flyingCash.address, vname, vsymbol);
    console.log("voucher address: ", Voucher.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManager, feelowerLimit, feeupperLimit);
    console.log("FeeManager address: ", FeeManager.address);


    console.log("deploying Adapter...");
    await deployer.deploy(FlyingCashAdapterFilda);
    console.log("FlyingCashAdapterFilda implement address: ", FlyingCashAdapterFilda.address);
    await deployer.deploy(AdapterProxy, FlyingCashAdapterFilda.address, admin, []);
    console.log("Adapter proxy address: ", AdapterProxy.address);

    console.log("init Adapter...");
    const adapter = await FlyingCashAdapterFilda.at(AdapterProxy.address);
    await adapter.init(gov, fToken);

    console.log("init FlyingCash...");
    await flyingCash.init(
      gov,    // _governance
      AdapterProxy.address, //_adapter
      lockToken,    // _lockToken
      Voucher.address, // _voucher
      FeeManager.address);

    console.log("set adapter whitelist...");
    await adapter.setWhitelist(FlyingCashProxy.address, true);

  } else if (network == "esc") {
    const vsymbol = argv['vsymbol'];
    const vname = argv['vname'];
    const admin = argv['admin'];
    const gov = argv['gov'];
    const tokenName = argv['tokenName'];
    const tokenSymbol = argv['tokenSymbol'];

    console.log("deploying FlyingCash...");
    await deployer.deploy(FlyingCash);
    console.log("FlyingCash implement address: ", FlyingCash.address);
    await deployer.deploy(FlyingCashProxy, FlyingCash.address, admin, []);
    console.log("FlyingCash proxy address: ", FlyingCashProxy.address);

    const flyingCash = await FlyingCash.at(FlyingCashProxy.address);

    console.log("deploying Voucher...");
    await deployer.deploy(Voucher, flyingCash.address, vname, vsymbol);
    console.log("voucher address: ", Voucher.address);

    console.log("deploying Token...");
    await deployer.deploy(FlyingCashToken, vname, vsymbol);
    console.log("Token address: ", FlyingCashToken.address);

    console.log("deploying Adapter...");
    await deployer.deploy(FlyingCashAdapterNoAsset);
    console.log("FlyingCashAdapterNoAsset implement address: ", FlyingCashAdapterNoAsset.address);
    await deployer.deploy(AdapterProxy, FlyingCashAdapterNoAsset.address, admin, []);
    console.log("Adapter proxy address: ", AdapterProxy.address);

    console.log("init Adapter...");
    const adapter = await FlyingCashAdapterNoAsset.at(AdapterProxy.address);
    await adapter.init(gov, FlyingCashToken.address);

    console.log("set token minter...");
    const token = await FlyingCashToken.deployed();
    await token.setMinter(AdapterProxy.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManagerNoAsset, FlyingCashToken.address);
    console.log("FeeManagerNoAsset address: ", FeeManagerNoAsset.address);

    console.log("init FlyingCash...");
    await flyingCash.init(
      gov,    // _governance
      AdapterProxy.address, //_adapter
      FlyingCashToken.address, // _lockToken
      Voucher.address,    // _voucher
      FeeManagerNoAsset.address);

    console.log("set adapter whitelist...");
    await adapter.setWhitelist(FlyingCashProxy.address, true);
  }
};
