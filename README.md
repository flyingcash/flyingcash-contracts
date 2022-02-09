# FlyingCash

## Deploy command

* `--ftoken` - FlyingCashAdapterFilda constructor parameter.

* `--lockToken` - FlyingCash init parameter. The lock token of flyingcash.

* `--vname` - Voucher constructor parameter, voucher name.

* `--vsymbol` - Voucher constructor parameter, voucher symbol.

* `--admin` - FlyingCashProxy constructor parameter, the upgrade admin account of proxy.

* `--gov` - FlyingCash init parameter, the governance of flyingcash. 
    <span style="color: red;">The governance account and the admin account cannot be the same. </span>

* `--feelowerLimit --feeupperLimit` - FeeManager constructor parameter, the lowerLimit and the upperLimit amount of token for FeeManager.

* `--tokenName, --tokenSymbol` - FlyingCashAdapterNoAsset constructor parameter, the token name and token symbol for the asset.

### heco sample
truffle migrate --network heco --ftoken 0xB16Df14C53C4bcfF220F4314ebCe70183dD804c0 --lockToken 0x0298c2b32eae4da002a15f36fdf7615bea3da047 --vname 'HECO HUSD voucher' --vsymbol 'vHUSD' --admin 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --gov 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --feelowerLimit 1000000 --feeupperLimit 20000000

### esc sample
truffle migrate --network esc --vname 'ESC HUSD voucher' --vsymbol 'vESCHUSD' --admin 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --gov 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --tokenName 'ESC HUSD' --tokenSymbol 'escHUSD'
