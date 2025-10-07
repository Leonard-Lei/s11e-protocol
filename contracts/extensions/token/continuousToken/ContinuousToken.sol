// // SPDX-License-Identifier: Apache-2.0

// pragma solidity >=0.8.20;

// // import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// // import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
// import "../erc20/ERC20Capped.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/utils/Context.sol";
// import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";
// import "@openzeppelin/contracts/utils/math/Math.sol";

// import "./BancorBondingCurve.sol";
// import "./CurveFormula.sol";
// import "../../../utils/ValidGasPrice.sol";
// import "../../../utils/S11eAcl.sol";

// import "hardhat/console.sol";

// abstract contract ContinuousToken is
//     ERC20Capped,
//     AccessControl,
//     BancorFormula,
//     CurveFormula,
//     ValidGasPrice
// {
//     using Math for uint256;

//     uint32 public reserveRatio;
//     uint256 public totalBurnt;
//     // 曲线类型： 0-bancor  1-bonding
//     uint8 public curveType;
//     bool private initialized = false;

//     constructor() {}

//     function initializeContinuousToken(
//         string memory _name,
//         string memory _symbol,
//         uint8 _decimals,
//         uint256 _cap
//     ) public {
//         require(
//             !initialized,
//             "ContinuousToken::initializeContinuousToken already initialized"
//         );
//         initialized = true;
//         initializeERC20Capped(_cap);
//         initializeERC20(_name, _symbol, _decimals);
//     }

//     function continuousSupply() public view virtual returns (uint256) {
//         return totalSupply();
//     }

//     function _continuousMint(
//         address _to,
//         uint256 _deposit
//     ) internal validGasPrice returns (uint256) {
//         require(_deposit > 0, "Deposit must be non-zero.");
//         console.log("_deposit:", uint256(_deposit));
//         uint256 rewardAmount;
//         if (curveType == uint8(S11eAcl.ContinuosCurveType.BANCOR_CURVE)) {
//             rewardAmount = calculatePurchaseReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _deposit
//             );
//         } else {
//             rewardAmount = calculateCurvePurchaseReturn(
//                 continuousSupply(),
//                 _deposit
//             );
//         }
//         _mint(_to, rewardAmount);
//         return rewardAmount;
//     }

//     function _continuousMint(
//         address _to,
//         uint256 _deposit,
//         uint256 _maxCollateralSpend
//     ) internal validGasPrice returns (uint256) {
//         require(_deposit > 0, "Deposit must be non-zero.");
//         console.log("_deposit:", uint256(_deposit));
//         uint256 rewardAmount;
//         if (curveType == uint8(S11eAcl.ContinuosCurveType.BANCOR_CURVE)) {
//             rewardAmount = calculatePurchaseReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _deposit
//             );
//         } else {
//             rewardAmount = calculateCurvePurchaseReturn(
//                 continuousSupply(),
//                 _deposit
//             );
//         }
//         // Checks the price has not risen above the max amount the user wishes
//         // to spend.
//         require(_deposit <= _maxCollateralSpend, "Price exceeds max spend");
//         _mint(_to, rewardAmount);
//         return rewardAmount;
//     }

//     function _continuousBurn(
//         address _from,
//         uint256 _amount
//     ) internal validGasPrice returns (uint256) {
//         require(_amount > 0, "Amount must be non-zero.");
//         require(balanceOf(_from) >= _amount, "Insufficient tokens to burn.");
//         uint256 refundAmount;
//         if (curveType == uint8(S11eAcl.ContinuosCurveType.BANCOR_CURVE)) {
//             refundAmount = calculateSaleReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _amount
//             );
//         } else {
//             (refundAmount, ) = calculateCurveSaleReturn(
//                 continuousSupply(),
//                 _amount
//             );
//         }
//         _burn(_from, _amount);
//         return refundAmount;
//     }

//     function _continuousBurn(
//         address _from,
//         uint256 _amount,
//         uint256 _minCollateralReward
//     ) internal validGasPrice returns (uint256) {
//         require(_amount > 0, "Amount must be non-zero.");
//         require(balanceOf(_from) >= _amount, "Insufficient tokens to burn.");
//         uint256 refundAmount;
//         if (curveType == uint8(S11eAcl.ContinuosCurveType.BANCOR_CURVE)) {
//             refundAmount = calculateSaleReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _amount
//             );
//         } else {
//             (refundAmount, ) = calculateCurveSaleReturn(
//                 continuousSupply(),
//                 _amount
//             );
//         }
//         // Checks the reward has not slipped below the min amount the user
//         // wishes to receive.
//         require(refundAmount >= _minCollateralReward, "Reward under min sell");
//         _burn(_from, _amount);
//         return refundAmount;
//     }

//     function sponsoredBurn(address _from, uint256 _amount) public {
//         _burn(_from, _amount);
//     }

//     function sponsoredBurnFrom(address _from, uint256 _amount) public {
//         //TODO: 是否需要授权？？？
//         uint256 currentAllowance = allowance(_from, _msgSender());
//         require(
//             currentAllowance >= _amount,
//             "ERC20: burn amount exceeds allowance"
//         );
//         unchecked {
//             _approve(_from, _msgSender(), currentAllowance - _amount);
//         }
//         _burn(_from, _amount);
//     }

//     /**
//      * @dev Abstract method that returns reserve token balance
//      */
//     function reserveBalance() public view virtual returns (uint256);

//     /**
//      * @dev Abstract method that returns current token mint price， 当前买入价格  = deposit(抵押代币)/rewardAmount
//      */
//     function getBuyPrice(
//         uint256 _deposit
//     ) public view virtual returns (uint256) {
//         uint256 rewardAmount;
//         if (curveType == uint8(S11eAcl.ContinuosCurveType.BANCOR_CURVE)) {
//             rewardAmount = calculatePurchaseReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _deposit
//             );
//         } else {
//             rewardAmount = calculateCurvePurchaseReturn(
//                 continuousSupply(),
//                 _deposit
//             );
//         }
//         return rewardAmount;
//     }

//     /**
//      * @dev Abstract method that returns current token burn price， 当前卖出价格  = refundAmount(抵押代币)/_amount
//      */
//     function getSellPrice(
//         uint256 _amount
//     ) public view virtual returns (uint256) {
//         uint256 refundAmount;
//         if (curveType == uint8(S11eAcl.ContinuosCurveType.BANCOR_CURVE)) {
//             refundAmount = calculateSaleReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _amount
//             );
//         } else {
//             (refundAmount, ) = calculateCurveSaleReturn(
//                 continuousSupply(),
//                 _amount
//             );
//         }
//         return refundAmount;
//     }

//     function setCurveType(uint8 _curveType) public virtual {
//         curveType = _curveType;
//     }
// }
