const Voucher = artifacts.require("Voucher");
const FlyingCashProxy = artifacts.require("FlyingCashProxy");
const FlyingCash = artifacts.require("FlyingCash");
const FeeManager = artifacts.require("FeeManager");
const FeeManagerNoAsset = artifacts.require("FeeManagerNoAsset");
const FlyingCashAdapterFilda = artifacts.require("FlyingCashAdapterFilda");
const FlyingCashAdapterNoAsset = artifacts.require("FlyingCashAdapterNoAsset");

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
    await deployer.deploy(FlyingCashAdapterFilda, fToken);
    console.log("FlyingCashAdapterFilda address: ", FlyingCashAdapterFilda.address);

    console.log("init FlyingCash...");
    await flyingCash.init(
      gov,    // _governance
      FlyingCashAdapterFilda.address, //_adapter
      lockToken,    // _lockToken
      Voucher.address, // _voucher
      FeeManager.address);

    console.log("set adapter whitelist...");
    const adapter = await FlyingCashAdapterFilda.deployed();
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


    console.log("deploying Adapter...");
    await deployer.deploy(FlyingCashAdapterNoAsset, tokenName, tokenSymbol);
    console.log("FlyingCashAdapterNoAsset address: ", FlyingCashAdapterNoAsset.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManagerNoAsset, FlyingCashAdapterNoAsset.address);
    console.log("FeeManagerNoAsset address: ", FeeManagerNoAsset.address);

    console.log("init FlyingCash...");
    await flyingCash.init(
      gov,    // _governance
      FlyingCashAdapterNoAsset.address, //_adapter
      FlyingCashAdapterNoAsset.address, // _lockToken
      Voucher.address,    // _voucher
      FeeManagerNoAsset.address);

    console.log("set adapter whitelist...");
    const adapter = await FlyingCashAdapterNoAsset.deployed();
    await adapter.setWhitelist(FlyingCashProxy.address, true);
  }
};
