//SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.20;

library Common {
    // 如果是固定大小字节数组转string，那么就需要先将字节数组转动态字节数组，再转字符串。
    // 但是，如果字符串不是占满32个字节。那么后面就会由0进行填充。所以我们需要将这些空字符去掉。
    function bytes32ToString(bytes32 b32name)
        public
        pure
        returns (string memory)
    {
        bytes memory bytesString = new bytes(32);
        // 定义一个变量记录字节数量
        uint256 charCount = 0;
        // 统计共有多少个字节数
        for (uint32 i = 0; i < 32; i++) {
            bytes1 char = bytes1(bytes32(uint256(b32name) * 2**(8 * i))); // 将b32name左移i位,参考下面算法
            // 获取到的始终是第0个字节。
            // 但为什么*2
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        // 初始化一动态数组，长度为charCount
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }

    // 字节数组转换为字符串
    // 当执行函数时不会去修改区块中的数据状态时，那么这个函数就可以被声明成constant的
    // view和constant效果是一样的。
    function bytes32ArrayToString(bytes32[] memory data)
        public
        pure
        returns (string memory)
    {
        bytes memory bytesString = new bytes(data.length * 32);
        uint256 urlLength;
        for (uint256 j = 0; j < data.length; j++) {
            for (uint256 k = 0; k < 32; k++) {
                bytes1 char = bytes1(bytes32(uint256(data[j]) * 2**(8 * k)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (uint256 j = 0; j < urlLength; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    // 解释bytes32(uint(b32name) * 2 ** (8 * i))算法
    // 0x6c
    // function uintValue() constant returns (uint) {
    //     return uint(0x6c);
    // }

    // function bytes32To0x6c() constant returns (bytes32) {
    //     return bytes32(0x6c);
    // }

    // function bytes32To0x6cLeft00() constant returns (bytes32) {
    //     return bytes32(uint(0x6c) * 2 ** (8 * 0));
    // }

    // function bytes32To0x6cLeft01() constant returns (bytes32) {
    //     return bytes32(uint(0x6c) * 2 ** (8 * 1));
    // }

    // function bytes32To0x6cLeft31() constant returns (bytes32) {
    //     return bytes32(uint(0x6c) * 2 ** (8 * 31));
    // }

    // MyMethod
    // Bytes32ToString
    function newBytes32ToString(bytes32 bname)
        public
        pure
        returns (string memory)
    {
        // 此处要加上memory
        // 先将有效字符计算出来
        // bytes memory bytesChar = new bytes(bname.length);
        uint256 charCount = 0;
        for (uint256 i = 0; i < bname.length; i++) {
            bytes1 char = bname[i];

            if (char != 0) {
                charCount++;
            }
        }

        // 新建数组，指定长度为有效字节长度
        bytes memory bytesName = new bytes(charCount);

        for (uint256 j = 0; j < charCount; j++) {
            bytesName[j] = bname[j];
        }
        return string(bytesName);
    }
}
