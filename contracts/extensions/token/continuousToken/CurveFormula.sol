// //SPDX-License-Identifier: Apache-2.0
// pragma solidity >=0.8.20;

// import "@openzeppelin/contracts/utils/math/Math.sol";
// import "../../../utils/Power.sol"; // Efficient power function.

// /**
//  * @title Bancor formula by Bancor
//  *
//  * Licensed to the Apache Software Foundation (ASF) under one or more contributor license agreements;
//  * and to You under the Apache License, Version 2.0. "
//  */
// contract CurveFormula is Power {
//     using Math for uint256;
//     uint256 internal constant _N = 5;
//     uint256 public marketOpeningSupply;

//     // -------------------------------------------------------------------------
//     // Curve mathematical functions
//     // uint256 internal constant _BZZ_SCALE = 1e18;
//     // uint256 internal constant _N = 5;
//     // uint256 internal constant marketOpeningSupply = 10000 * _BZZ_SCALE;

//     // Equation for curve:
//     /**
//      * @param   x The supply to calculate at.
//      * @return  x^32/marketOpeningSupply^5
//      * @dev     Calculates the 32 power of `x` (`x` squared 5 times) times a 
//      *          constant. Each time it squares the function it divides by the 
//      *          `marketOpeningSupply` so when `x` = `marketOpeningSupply` 
//      *          it doesn't change `x`. 
//      *
//      *          `c*x^32` | `c` is chosen in such a way that 
//      *          `marketOpeningSupply` is the fixed point of the helper 
//      *          function.
//      *
//      *          The division by `marketOpeningSupply` also helps avoid an 
//      *          overflow.
//      *
//      *          The `_helper` function is separate to the `_primitiveFunction` 
//      *          as we modify `x`. 
//      计算“x”的32次方（“x”平方5倍）乘以常数。每次它将函数除以平方`marketOpeningSupply`
//      所以当 x=_MARKET_OPINING_SUPPLY 时，它不会改变`x`
//      `选择 c*x^32`|`c`的方式是，`marketOpeningSupply`是辅助函数的定点。
//      用`marketOpeningSupply`除法也有助于避免溢出。
//      当我们修改`x时，“_helper”函数与“_primitiveFunction”函数是分开的`
//      */
//     function _helper(uint256 x) internal view returns (uint256) {
//         for (uint256 index = 1; index <= _N; index++) {
//             //! x = (x*x /marketOpeningSupply)
//             x = (x.mul(x)).div(marketOpeningSupply);
//         }
//         return x;
//     }

//     /**
//      * @param   s The supply point being calculated for. 当前 时刻 bzz 的供应量
//      * @return  The amount of DAI required for the requested amount of BZZ (s). 当前要求的BZZ数量(s)所对应DAI的数量
//      * @dev     `s` is being added because it is the linear term in the.
//      *          polynomial (this ensures no free BUZZ tokens). 需要增加的 s 是多项式中的线性项
//      *
//      *          primitive function equation: s + c*s^32. 原始方程
//      *
//      *          See the helper function for the definition of `c`. c 为常量，_helper 方法中定义
//      *
//      *          Converts from something measured in BZZ (1e16) to dai atomic
//      *          units 1e18. 从BZZ（1e16）中测量的值转换为dai原子单位1e18。
//      */
//     function _primitiveFunction(uint256 s) internal view returns (uint256) {
//         return s.add(_helper(s));
//     }

//     /**
//      * @param  _supply The number of tokens that exist.
//      * @return uint256 The price for the next token up the curve.
//      */
//     function spotPrice(uint256 _supply) public view returns (uint256) {
//         return (
//             _primitiveFunction(_supply.add(1)).sub(_primitiveFunction(_supply))
//         );
//     }

//     /**
//      * @notice 计算在当前供应量(_currentSupply)时铸造 _depositAmount 数量的代币需要需要花费的 抵押代币数量
//      * @param  _depositAmount The amount of tokens to be minted：要铸造的代币数量
//      * @param  _currentSupply The current supply of tokens：当前代币供应量
//      * @return uint256 The cost for the tokens, uint256 The price being paid per token：代币成本，每个代币支付的价格
//      */
//     function calculateCurvePurchaseReturn(
//         uint256 _currentSupply,
//         uint256 _depositAmount
//     ) public view returns (uint256) {
//         uint256 deltaR = _primitiveFunction(_currentSupply.add(_depositAmount))
//             .sub(_primitiveFunction(_currentSupply));
//         return deltaR;
//     }

//     /**
//      * @param  _sellAmount The amount of tokens to be sold
//      * @param  _currentSupply The current supply of tokens
//      * @return uint256 The reward for the tokens
//      * @return uint256 The price being received per token
//      */
//     function calculateCurveSaleReturn(
//         uint256 _currentSupply,
//         uint256 _sellAmount
//     ) public view returns (uint256, uint256) {
//         assert(_currentSupply - _sellAmount > 0);
//         uint256 deltaR = _primitiveFunction(_currentSupply).sub(
//             _primitiveFunction(_currentSupply.sub(_sellAmount))
//         );
//         uint256 realized_price = deltaR.div(_sellAmount);
//         return (deltaR, realized_price);
//     }
// }
