const Voucher = artifacts.require("Voucher");
const FlyingCashProxy = artifacts.require("FlyingCashProxy");
const FlyingCash = artifacts.require("FlyingCash");
const FeeManager = artifacts.require("FeeManager");
const FeeManagerNoAsset = artifacts.require("FeeManagerNoAsset");
const FlyingCashAdapterFilda = artifacts.require("FlyingCashAdapterFilda");
const FlyingCashAdapterNoAsset = artifacts.require("FlyingCashAdapterNoAsset");
const FlyingCashToken = artifacts.require("FlyingCashToken");

const {deployProxy} = require('@openzeppelin/truffle-upgrades');
const BigNumber = require('bignumber.js');

const argv = require('minimist')(process.argv.slice(2),
        {string: ['ftoken', 'lockToken', 'vsymbol', 'vname', 'gov', 'tokenName', 'tokenSymbol']});

module.exports = async function (deployer, network, accounts) {
  const zeroAddr = "0x0000000000000000000000000000000000000000";

  console.log("argv: ", argv);
  if (network == "heco") {

    const ftoken = argv['ftoken'];
    const lockToken = argv['lockToken'];
    const vsymbol = argv['vsymbol'];
    const vname = argv['vname'];
    const gov = argv['gov'];
    const feelowerLimit = new BigNumber(argv['feelowerLimit']);
    const feeupperLimit = new BigNumber(argv['feeupperLimit']);

    console.log("deploying Voucher...");
    await deployer.deploy(Voucher, vname, vsymbol);
    console.log("voucher address: ", Voucher.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManager, feelowerLimit, feeupperLimit);
    console.log("FeeManager address: ", FeeManager.address);

    console.log("deploying Adapter...");
    const adapter = await deployProxy(
        FlyingCashAdapterFilda,
        [gov, ftoken],
        {
          deployer,
          unsafeAllow: 'delegatecall',
          initializer: 'init'
        });
    console.log('Adapter address: ', adapter.address);

    console.log("deploying FlyingCash...");
    const flyingCash = await deployProxy(FlyingCash,
      [
        gov,    // _governance
        adapter.address, //_adapter
        lockToken, // _lockToken
        Voucher.address,    // _voucher
        FeeManager.address
      ],
      { deployer,
        unsafeAllow: 'delegatecall',
        initializer: 'init'
      }
      );
    console.log('FlyingCash address: ', flyingCash.address);

    console.log("Voucher set FlyingCash...");
    const voucher = await Voucher.deployed();
    await voucher.setFlyingCash(flyingCash.address);

    console.log("set adapter whitelist...");
    await adapter.setWhitelist(flyingCash.address, true);

  } else if (network == "esc") {
    const vsymbol = argv['vsymbol'];
    const vname = argv['vname'];
    const gov = argv['gov'];
    const tokenName = argv['tokenName'];
    const tokenSymbol = argv['tokenSymbol'];

    console.log("deploying Voucher...");
    await deployer.deploy(Voucher, vname, vsymbol);
    console.log("voucher address: ", Voucher.address);

    console.log("deploying Token...");
    await deployer.deploy(FlyingCashToken, tokenName, tokenSymbol);
    console.log("Token address: ", FlyingCashToken.address);

    console.log("deploying Adapter...");
    const adapter = await deployProxy(FlyingCashAdapterNoAsset,
      [gov, FlyingCashToken.address],
      {
        deployer,
        unsafeAllow: 'delegatecall',
        initializer: 'init'
      });
    console.log('Adapter address: ', adapter.address);

    console.log("set token minter...");
    const token = await FlyingCashToken.deployed();
    await token.setMinter(adapter.address);

    console.log("deploying FeeManager...");
    await deployer.deploy(FeeManagerNoAsset, FlyingCashToken.address);
    console.log("FeeManagerNoAsset address: ", FeeManagerNoAsset.address);

    console.log("deploying FlyingCash...");
    const flyingCash = await deployProxy(FlyingCash,
      [
        gov,    // _governance
        adapter.address, //_adapter
        FlyingCashToken.address, // _lockToken
        Voucher.address,    // _voucher
        FeeManagerNoAsset.address
      ],
      { deployer,
        unsafeAllow: 'delegatecall',
        initializer: 'init'
      });
    console.log('FlyingCash address: ', flyingCash.address);

    console.log("Voucher set FlyingCash...");
    const voucher = await Voucher.deployed();
    await voucher.setFlyingCash(flyingCash.address);

    console.log("set adapter whitelist...");
    await adapter.setWhitelist(flyingCash.address, true);
  } else if (network == 'bsc') {

  }
};
