const Web3 = require('web3');
const HDWalletProvider = require('@truffle/hdwallet-provider');
const fs = require('fs');
const BigNumber = require('bignumber.js');
const FlyingCash = require('../build/contracts/FlyingCash.json');
const ERC20 = require('../build/contracts/ERC20.json');
const Voucher = require('../build/contracts/Voucher.json');
const FlyingCashAdapterFilda = require('../build/contracts/FlyingCashAdapterFilda.json');

const mnemonic = fs.readFileSync(".secret").toString().trim();

const heco = "https://http-mainnet.hecochain.com"
const bsc = "https://bsc-dataseed.binance.org/"
const esc = "https://escnode.filda.org"

const web3Heco = new Web3(new HDWalletProvider(mnemonic, heco));
const web3Bsc = new Web3(new HDWalletProvider(mnemonic, bsc));
const web3Esc = new Web3(new HDWalletProvider(mnemonic, esc));

// Heco info
const flyingCashHeco = "0x3725Ff107752e73eB2b56BBF97eBd96BD4Fc989B";
const usdtHeco = '0xa71EdC38d189767582C38A3145b5873052c3e47a';
const voucherHeco = '0x714812e9fdA4e95c6E0E04c41149414ca1A886d3';
const voucherEscToHecoUsdt = '0xbb571194A374b8e087e826071856C7bF11d3b987';
const voucherBscToHecoUsdt = '0xa4e3f3d67b0B1DcC12D3b3ea998b30b3d922BeFE';
const adapterHeco = '0x09481A835CfC0237c364C0E724298AC38a604C79';
const feeManagerHeco = '0x069676C85dc0d175987fE1B4445E2ddE47732Cec';


// Bsc info
const flyingCashBsc = '0xDD5e6D18696059B699905111c2F15DB99D8C9fB9';
const usdtBsc = '0x55d398326f99059fF775485246999027B3197955';
const voucherBsc = '0xbF77c6805B529833AB26e86C8F6EEb9aF7C02A26';
const voucherEscToBscUsdt = '0xeCCAa159C922D89f11367c9961b6d97281A25C22';
const voucherHecoToBscUsdt = '0x5DeA211BaaEe0ADA406185be14B6d670966ee156';
const adapterBsc = '0xb8dB16D770dDBaE79545664461231ec2EA02c502';
const feeManagerBsc = '0x267267059034bAd6Fcb89295B6DF052022E8551F';


// Esc info
const flyingCashEsc = '0xDA16B22d8334435b51F5899ad4C06BdBBa506A99';
const usdtEsc = '0x5D028e9140eeA62291a0b6cf99F99786c1Ed584e';
const voucherEsc = '0x0cFE9604bCF541B77BD1c4206E5229db62D0b9f8';
const voucherBscToEscUsdt = '0x260659902038Df0A31761c6931Fa1488c6991276';
const voucherHecoToEscUsdt = '0x60aa2e4665A2E60447a7aF39D3a2A05617eEC007';
const adapterEsc = '0xBf12a64e6ac871e2EB3C6875cFeb5320F7435189';
const feeManagerEsc = '0xd14737eBF15f562BdFb131D6C5e3D84C42ed43cF';


const ensureApprove = async (web3, token, account, spender) => {
    const contract = new web3.eth.Contract(ERC20.abi, token);
    let approved = await contract.methods.allowance(account, spender).call();
    if (approved == 0) {
        await contract.methods.approve(spender, new BigNumber(2).pow(256).minus(1)).send({from: account});
    }
}

const sleep = async (ms) => {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const deposit = async (web3, token, flyingCashContract, network, amount) => {
    const accounts = await web3.eth.getAccounts();

    await ensureApprove(web3, token, accounts[0], flyingCashContract);

    const flyingCash = new web3.eth.Contract(FlyingCash.abi, flyingCashContract);

    let gasEstimate = await flyingCash.methods.deposit(
        amount,
        network,
        accounts[0])
        .estimateGas({from: accounts[0]});
    console.log("gasEstimate:", gasEstimate);

    let ret = await flyingCash.methods.deposit(
        amount,
        network,
        accounts[0])
        .send({from: accounts[0], gasLimit: gasEstimate*2});
    // console.log(ret);
}

const withdraw = async (web3, voucher, flyingCashContract, amount) => {
    if (amount == 0) return;
    const accounts = await web3.eth.getAccounts();

    await ensureApprove(web3, voucher, accounts[0], flyingCashContract);

    const flyingCash = new web3.eth.Contract(FlyingCash.abi, flyingCashContract);

    let gasEstimate = await flyingCash.methods.withdraw(
        voucher,
        amount)
        .estimateGas({from: accounts[0]});
    console.log("gasEstimate:", gasEstimate);

    let ret =  await flyingCash.methods.withdraw(
        voucher,
        amount)
        .send({from: accounts[0], gasLimit: gasEstimate*2});
    // console.log(ret);
}

const balanceOf = async (web3, token, account) => {
    const contract = new web3.eth.Contract(ERC20.abi, token);
    let balance = await contract.methods.balanceOf(account).call();
    return balance;
}

const testCase1 = async () => {
    const accounts = await web3Heco.eth.getAccounts();

    const amountHecoToEsc = web3Heco.utils.toWei('1', 'ether');
    const amountBscToEsc = web3Heco.utils.toWei('2', 'ether');


    const amountEscToHeco = web3Heco.utils.toWei('2', 'ether');
    const amountEscToBsc = web3Heco.utils.toWei('1', 'ether');

    // Heco to Esc
    await deposit(web3Heco, usdtHeco, flyingCashHeco, 'ESC', amountHecoToEsc);
    console.log("send %s usdt from HECO to ESC", amountHecoToEsc.toString());

    // Bsc to Esc
    await deposit(web3Bsc, usdtBsc, flyingCashBsc, 'ESC', amountBscToEsc);
    console.log("send %s usdt from BSC to ESC", amountBscToEsc.toString());

    console.log("awit 1 minite");
    await sleep(60000);

    // Esc
    let bFeeBefore = await balanceOf(web3Esc, usdtEsc, feeManagerEsc);
    console.log("ESC feemanager usdt balance: ", bFeeBefore.toString());

    let bHecVoucher = await balanceOf(web3Esc, voucherHecoToEscUsdt, accounts[0]);
    console.log("voucher Heco to Esc balance: ", bHecVoucher.toString());

    let balance1 = await balanceOf(web3Esc, usdtEsc, accounts[0]);
    await withdraw(web3Esc, voucherHecoToEscUsdt, flyingCashEsc, bHecVoucher);
    let balance2 = await balanceOf(web3Esc, usdtEsc, accounts[0]);
    let withdrawn = new BigNumber(balance2).minus(balance1)
    console.log("ESC withdraw usdt from Heco vocher: ", withdrawn.toString());

    await sleep(2000);
    let bBscVoucher = await balanceOf(web3Esc, voucherBscToEscUsdt, accounts[0]);
    console.log("voucher Bsc to Esc balance: ", bBscVoucher.toString());

    await withdraw(web3Esc, voucherBscToEscUsdt, flyingCashEsc, bBscVoucher);
    let balance3 = await balanceOf(web3Esc, usdtEsc, accounts[0]);
    withdrawn = new BigNumber(balance3).minus(balance2)
    console.log("ESC withdraw usdt from bsc vocher: ", withdrawn.toString());

    let bFeeAfterWithdraw = await balanceOf(web3Esc, usdtEsc, feeManagerEsc);
    console.log("ESC feemanager usdt balance after withdraw: ", bFeeAfterWithdraw.toString());

    await deposit(web3Esc, usdtEsc, flyingCashEsc, 'HECO', amountEscToHeco);
    console.log("send %s usdt from ESC to HECO", amountEscToHeco.toString());
    let bFeeAfterHeco = await balanceOf(web3Esc, usdtEsc, feeManagerEsc);
    console.log("ESC feemanager usdt balance after send to Heco: ", bFeeAfterHeco.toString());

    let fee = new BigNumber(bFeeAfterHeco).minus(bFeeAfterWithdraw);
    if (!fee.isEqualTo(new BigNumber(amountEscToHeco).times(0.02))) {
        console.log("fee is erro: ", fee.toString());
        await sleep(2000);
    }

    await deposit(web3Esc, usdtEsc, flyingCashEsc, 'BSC', amountEscToBsc);
    console.log("send %s usdt from Esc to Bsc", amountEscToBsc.toString());
    let bFeeAfterBsc = await balanceOf(web3Esc, usdtEsc, feeManagerEsc);
    console.log("ESC feemanager usdt balance after send to Bsc: ", bFeeAfterBsc.toString());
    fee = new BigNumber(bFeeAfterBsc).minus(bFeeAfterHeco);
    if (!fee.isEqualTo(new BigNumber(amountEscToBsc).times(0.02))) {
        console.log("fee is erro: ", fee.toString());
        await sleep(2000);
    }

    console.log("awit 1 minite");
    await sleep(60000);


    // Heco withdraw
    let bEscVoucher = await balanceOf(web3Heco, voucherEscToHecoUsdt, accounts[0]);
    console.log("voucher Esc to Heco balance: ", bEscVoucher.toString());

    let bHecoUsdt1 = await balanceOf(web3Heco, usdtHeco, accounts[0]);
    try {
        await withdraw(web3Heco, voucherEscToHecoUsdt, flyingCashHeco, bEscVoucher);
    } catch(e) {
        console.log("Heco withdraw error: ", e);
    }
    let bHecoUsdt2 = await balanceOf(web3Heco, usdtHeco, accounts[0]);
    withdrawn = new BigNumber(bHecoUsdt2).minus(bHecoUsdt1)
    console.log("Heco withdraw usdt from ESC vocher: ", withdrawn.toString());

    // Bsc withdraw
    let bEscVoucherB = await balanceOf(web3Bsc, voucherEscToBscUsdt, accounts[0]);
    console.log("voucher Esc to Bsc balance: ", bEscVoucherB.toString());

    let bBscUsdt1 = await balanceOf(web3Bsc, usdtBsc, accounts[0]);
    try {
        await withdraw(web3Bsc, voucherEscToBscUsdt, flyingCashBsc, bEscVoucherB);
    } catch(e) {
        console.log("Bsc withdraw error: ", e);
    }

    let bBscUsdt2 = await balanceOf(web3Bsc, usdtBsc, accounts[0]);
    withdrawn = new BigNumber(bBscUsdt2).minus(bBscUsdt1)
    console.log("BSC withdraw usdt from ESC vocher: ", withdrawn.toString());
}

testCase1()

