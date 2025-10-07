// //SPDX-License-Identifier: Apache-2.0
// pragma solidity >=0.8.20;

// import "./BancorFormula.sol";
// import "../../../utils/ValidGasPrice.sol";
// import "./IBondingCurve.sol";

// abstract contract BancorBondingCurve is IBondingCurve, BancorFormula {
//     /*
//         reserve ratio, represented in ppm, 1-1000000
//         1/3 corresponds to y= multiple * x^2
//         1/2 corresponds to y= multiple * x
//         2/3 corresponds to y= multiple * x^1/2
//     */
//     //! 需要在继承的合约中设置此值
//     uint32 public reserveRatio;
//     using Math for uint256;

//     constructor() {}

//     /**
//      * @notice This function is only callable after the curve contract has been initialized.
//      * @param  _reserveTokenAmount The amount of tokens a user wants to buy
//      * @return collateralRequired The cost to buy the _amount of tokens in the collateral currency (see collateral token).
//      */
//     function getContinuousMintReward(
//         uint256 _reserveTokenAmount
//     ) public view returns (uint256) {
//         return
//             calculatePurchaseReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _reserveTokenAmount
//             );
//     }

//     /**
//      * @notice This function is only callable after the curve contract has been initialized.
//      * @param  _continuousTokenAmount The amount of tokens a user wants to sell
//      * @return collateralReward The reward for selling the _amount of tokens in the collateral currency (see collateral token).
//      */
//     function getContinuousBurnRefund(
//         uint256 _continuousTokenAmount
//     ) public view returns (uint256) {
//         return
//             calculateSaleReturn(
//                 continuousSupply(),
//                 reserveBalance(),
//                 reserveRatio,
//                 _continuousTokenAmount
//             );
//     }

//     /**
//      * @dev Abstract method that returns continuous token supply
//      */
//     function continuousSupply() public view virtual returns (uint256);

//     /**
//      * @dev Abstract method that returns reserve token balance
//      */
//     function reserveBalance() public view virtual returns (uint256);
// }
