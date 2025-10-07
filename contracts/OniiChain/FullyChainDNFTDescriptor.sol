// // SPDX-License-Identifier: MIT
// pragma solidity >=0.8.20;

// // pragma abicoder v2;

// import "./libraries/details/BackgroundDetail.sol";
// import "./libraries/details/BodyDetail.sol";
// import "./libraries/details/HairDetail.sol";
// import "./libraries/details/MouthDetail.sol";
// import "./libraries/details/NoseDetail.sol";
// import "./libraries/details/EyesDetail.sol";
// import "./libraries/details/EyebrowDetail.sol";
// import "./libraries/details/MarkDetail.sol";
// import "./libraries/details/AccessoryDetail.sol";
// import "./libraries/details/EarringsDetail.sol";
// import "./libraries/details/MaskDetail.sol";
// import "./interfaces/IFullyChainDNFTDescriptor.sol";
// import "./interfaces/IFullyChainDNFT.sol";
// import "base64-sol/base64.sol";
// import "@openzeppelin/contracts/utils/math/SafeCast.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

// /// @title Describes Onii
// /// @notice Produces a string containing the data URI for a JSON metadata string
// contract FullyChainDNFTDescriptor is IFullyChainDNFTDescriptor {
//     /// @dev Max value for defining probabilities
//     uint256 internal constant MAX = 100000;

//     address public eyesDetail;
//     address public hairDetail;
//     address public markDetail;
//     address public maskDetail;
//     address public bodyDetail;
//     address public earringsDetail;
//     address public accessoryDetail;
//     address public mouthDetail;
//     address public backgroundDetail;
//     address public eyebrowDetail;
//     address public noseDetail;

//     struct SVGParams {
//         uint8 hair;
//         uint8 eye;
//         uint8 eyebrow;
//         uint8 nose;
//         uint8 mouth;
//         uint8 mark;
//         uint8 earring;
//         uint8 accessory;
//         uint8 mask;
//         uint8 background;
//         uint8 skin;
//         bool original;
//         uint256 timestamp;
//         address creator;
//     }

//     struct DetailAddress {
//         address eyesDetail;
//         address hairDetail;
//         address markDetail;
//         address maskDetail;
//         address bodyDetail;
//         address earringsDetail;
//         address accessoryDetail;
//         address mouthDetail;
//         address backgroundDetail;
//         address eyebrowDetail;
//         address noseDetail;
//     }

//     uint256[] internal BACKGROUND_ITEMS = [
//         4000,
//         3400,
//         3080,
//         2750,
//         2400,
//         1900,
//         1200,
//         0
//     ];
//     uint256[] internal SKIN_ITEMS = [2000, 1000, 0];
//     uint256[] internal NOSE_ITEMS = [10, 0];
//     uint256[] internal MARK_ITEMS = [
//         50000,
//         40000,
//         31550,
//         24550,
//         18550,
//         13550,
//         9050,
//         5550,
//         2550,
//         550,
//         50,
//         10,
//         0
//     ];
//     uint256[] internal EYEBROW_ITEMS = [65000, 40000, 20000, 10000, 4000, 0];
//     uint256[] internal MASK_ITEMS = [
//         20000,
//         14000,
//         10000,
//         6000,
//         2000,
//         1000,
//         100,
//         0
//     ];
//     uint256[] internal EARRINGS_ITEMS = [
//         50000,
//         38000,
//         28000,
//         20000,
//         13000,
//         8000,
//         5000,
//         2900,
//         1000,
//         100,
//         30,
//         0
//     ];
//     uint256[] internal ACCESSORY_ITEMS = [
//         50000,
//         43000,
//         36200,
//         29700,
//         23400,
//         17400,
//         11900,
//         7900,
//         4400,
//         1400,
//         400,
//         200,
//         11,
//         1,
//         0
//     ];
//     uint256[] internal MOUTH_ITEMS = [
//         80000,
//         63000,
//         48000,
//         36000,
//         27000,
//         19000,
//         12000,
//         7000,
//         4000,
//         2000,
//         1000,
//         500,
//         50,
//         0
//     ];
//     uint256[] internal HAIR_ITEMS = [
//         97000,
//         94000,
//         91000,
//         88000,
//         85000,
//         82000,
//         79000,
//         76000,
//         73000,
//         70000,
//         67000,
//         64000,
//         61000,
//         58000,
//         55000,
//         52000,
//         49000,
//         46000,
//         43000,
//         40000,
//         37000,
//         34000,
//         31000,
//         28000,
//         25000,
//         22000,
//         19000,
//         16000,
//         13000,
//         10000,
//         3000,
//         1000,
//         0
//     ];
//     uint256[] internal EYE_ITEMS = [
//         98000,
//         96000,
//         94000,
//         92000,
//         90000,
//         88000,
//         86000,
//         84000,
//         82000,
//         80000,
//         78000,
//         76000,
//         74000,
//         72000,
//         70000,
//         68000,
//         60800,
//         53700,
//         46700,
//         39900,
//         33400,
//         27200,
//         21200,
//         15300,
//         10600,
//         6600,
//         3600,
//         2600,
//         1700,
//         1000,
//         500,
//         100,
//         10,
//         0
//     ];

//     constructor(DetailAddress memory detailAddress) {
//         eyesDetail = detailAddress.eyesDetail;
//         hairDetail = detailAddress.hairDetail;
//         markDetail = detailAddress.markDetail;
//         maskDetail = detailAddress.maskDetail;
//         bodyDetail = detailAddress.bodyDetail;
//         earringsDetail = detailAddress.earringsDetail;
//         accessoryDetail = detailAddress.accessoryDetail;
//         mouthDetail = detailAddress.mouthDetail;
//         backgroundDetail = detailAddress.backgroundDetail;
//         eyebrowDetail = detailAddress.eyebrowDetail;
//         noseDetail = detailAddress.noseDetail;
//     }

//     /// @dev Combine all the SVGs to generate the final image
//     function generateSVGImage(
//         SVGParams memory params
//     ) internal view returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     generateSVGHead(),
//                     getBackgroundDetailSVG(params.background),
//                     generateSVGFace(params),
//                     getEarringsDetailSVG(params.earring),
//                     getHairDetailSVG(params.hair),
//                     getMaskDetailSVG(params.mask),
//                     getAccessoryDetailSVG(params.accessory),
//                     generateCopy(params.original),
//                     "</svg>"
//                 )
//             );
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getBackgroundDetailSVG(
//         uint8 id
//     ) internal view returns (string memory) {
//         if (id == 1) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem1();
//         } else if (id == 2) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem2();
//         } else if (id == 3) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem3();
//         } else if (id == 4) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem1();
//         } else if (id == 5) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem5();
//         } else if (id == 6) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem6();
//         } else if (id == 7) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem7();
//         } else if (id == 8) {
//             return BackgroundDetail(backgroundDetail).backgroundDetailItem8();
//         } else {
//             revert("No background item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getEarringsDetailSVG(
//         uint8 id
//     ) internal view returns (string memory) {
//         if (id == 1) {
//             return EarringsDetail(earringsDetail).earringsDetailItem1();
//         } else if (id == 2) {
//             return EarringsDetail(earringsDetail).earringsDetailItem2();
//         } else if (id == 3) {
//             return EarringsDetail(earringsDetail).earringsDetailItem3();
//         } else if (id == 4) {
//             return EarringsDetail(earringsDetail).earringsDetailItem4();
//         } else if (id == 5) {
//             return EarringsDetail(earringsDetail).earringsDetailItem5();
//         } else if (id == 6) {
//             return EarringsDetail(earringsDetail).earringsDetailItem6();
//         } else if (id == 7) {
//             return EarringsDetail(earringsDetail).earringsDetailItem7();
//         } else if (id == 8) {
//             return EarringsDetail(earringsDetail).earringsDetailItem8();
//         } else if (id == 9) {
//             return EarringsDetail(earringsDetail).earringsDetailItem9();
//         } else if (id == 10) {
//             return EarringsDetail(earringsDetail).earringsDetailItem10();
//         } else if (id == 11) {
//             return EarringsDetail(earringsDetail).earringsDetailItem11();
//         } else if (id == 12) {
//             return EarringsDetail(earringsDetail).earringsDetailItem12();
//         } else {
//             revert("No earrings item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getHairDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return HairDetail(hairDetail).hairDetailItem1();
//         } else if (id == 2) {
//             return HairDetail(hairDetail).hairDetailItem2();
//         } else if (id == 3) {
//             return HairDetail(hairDetail).hairDetailItem2();
//         } else if (id == 4) {
//             return HairDetail(hairDetail).hairDetailItem4();
//         } else if (id == 5) {
//             return HairDetail(hairDetail).hairDetailItem5();
//         } else if (id == 6) {
//             return HairDetail(hairDetail).hairDetailItem6();
//         } else if (id == 7) {
//             return HairDetail(hairDetail).hairDetailItem7();
//         } else if (id == 8) {
//             return HairDetail(hairDetail).hairDetailItem8();
//         } else if (id == 9) {
//             return HairDetail(hairDetail).hairDetailItem9();
//         } else if (id == 10) {
//             return HairDetail(hairDetail).hairDetailItem10();
//         } else if (id == 11) {
//             return HairDetail(hairDetail).hairDetailItem11();
//         } else if (id == 12) {
//             return HairDetail(hairDetail).hairDetailItem12();
//         } else if (id == 13) {
//             return HairDetail(hairDetail).hairDetailItem13();
//         } else if (id == 14) {
//             return HairDetail(hairDetail).hairDetailItem14();
//         } else if (id == 15) {
//             return HairDetail(hairDetail).hairDetailItem15();
//         } else if (id == 16) {
//             return HairDetail(hairDetail).hairDetailItem16();
//         } else if (id == 17) {
//             return HairDetail(hairDetail).hairDetailItem17();
//         } else if (id == 18) {
//             return HairDetail(hairDetail).hairDetailItem18();
//         } else if (id == 19) {
//             return HairDetail(hairDetail).hairDetailItem19();
//         } else if (id == 20) {
//             return HairDetail(hairDetail).hairDetailItem20();
//         } else if (id == 21) {
//             return HairDetail(hairDetail).hairDetailItem21();
//         } else if (id == 22) {
//             return HairDetail(hairDetail).hairDetailItem22();
//         } else if (id == 23) {
//             return HairDetail(hairDetail).hairDetailItem23();
//         } else if (id == 24) {
//             return HairDetail(hairDetail).hairDetailItem24();
//         } else if (id == 25) {
//             return HairDetail(hairDetail).hairDetailItem25();
//         } else if (id == 26) {
//             return HairDetail(hairDetail).hairDetailItem26();
//         } else if (id == 27) {
//             return HairDetail(hairDetail).hairDetailItem27();
//         } else if (id == 28) {
//             return HairDetail(hairDetail).hairDetailItem28();
//         } else if (id == 29) {
//             return HairDetail(hairDetail).hairDetailItem29();
//         } else if (id == 30) {
//             return HairDetail(hairDetail).hairDetailItem30();
//         } else if (id == 31) {
//             return HairDetail(hairDetail).hairDetailItem31();
//         } else if (id == 32) {
//             return HairDetail(hairDetail).hairDetailItem32();
//         } else if (id == 33) {
//             return HairDetail(hairDetail).hairDetailItem33();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getMaskDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return MaskDetail(maskDetail).maskDetailItem1();
//         } else if (id == 2) {
//             return MaskDetail(maskDetail).maskDetailItem2();
//         } else if (id == 3) {
//             return MaskDetail(maskDetail).maskDetailItem3();
//         } else if (id == 4) {
//             return MaskDetail(maskDetail).maskDetailItem4();
//         } else if (id == 5) {
//             return MaskDetail(maskDetail).maskDetailItem5();
//         } else if (id == 6) {
//             return MaskDetail(maskDetail).maskDetailItem6();
//         } else if (id == 7) {
//             return MaskDetail(maskDetail).maskDetailItem7();
//         } else if (id == 8) {
//             return MaskDetail(maskDetail).maskDetailItem8();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getAccessoryDetailSVG(
//         uint8 id
//     ) internal view returns (string memory) {
//         if (id == 1) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem1();
//         } else if (id == 2) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem2();
//         } else if (id == 3) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem3();
//         } else if (id == 4) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem4();
//         } else if (id == 5) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem5();
//         } else if (id == 6) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem6();
//         } else if (id == 7) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem7();
//         } else if (id == 8) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem8();
//         } else if (id == 9) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem9();
//         } else if (id == 10) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem10();
//         } else if (id == 11) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem11();
//         } else if (id == 12) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem12();
//         } else if (id == 13) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem13();
//         } else if (id == 14) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem14();
//         } else if (id == 15) {
//             return AccessoryDetail(accessoryDetail).accessoryDetailItem15();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @dev Combine face items
//     function generateSVGFace(
//         SVGParams memory params
//     ) private view returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     getBodyDetailSVG(params.skin),
//                     getMarkDetailSVG(params.mark),
//                     getMouthDetailSVG(params.mouth),
//                     getNoseDetailSVG(params.nose),
//                     getEyesDetailSVG(params.eye),
//                     getEyebrowDetailSVG(params.eyebrow)
//                 )
//             );
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getBodyDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return BodyDetail(bodyDetail).bodyDetailItem1();
//         } else if (id == 2) {
//             return BodyDetail(bodyDetail).bodyDetailItem2();
//         } else if (id == 3) {
//             return BodyDetail(bodyDetail).bodyDetailItem3();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getMarkDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return MarkDetail(markDetail).markDetailItem1();
//         } else if (id == 2) {
//             return MarkDetail(markDetail).markDetailItem2();
//         } else if (id == 3) {
//             return MarkDetail(markDetail).markDetailItem3();
//         } else if (id == 4) {
//             return MarkDetail(markDetail).markDetailItem4();
//         } else if (id == 5) {
//             return MarkDetail(markDetail).markDetailItem5();
//         } else if (id == 6) {
//             return MarkDetail(markDetail).markDetailItem6();
//         } else if (id == 7) {
//             return MarkDetail(markDetail).markDetailItem1();
//         } else if (id == 8) {
//             return MarkDetail(markDetail).markDetailItem8();
//         } else if (id == 9) {
//             return MarkDetail(markDetail).markDetailItem9();
//         } else if (id == 10) {
//             return MarkDetail(markDetail).markDetailItem10();
//         } else if (id == 11) {
//             return MarkDetail(markDetail).markDetailItem11();
//         } else if (id == 12) {
//             return MarkDetail(markDetail).markDetailItem12();
//         } else if (id == 13) {
//             return MarkDetail(markDetail).markDetailItem13();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getMouthDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return MouthDetail(mouthDetail).mouthDetailItem1();
//         } else if (id == 2) {
//             return MouthDetail(mouthDetail).mouthDetailItem2();
//         } else if (id == 3) {
//             return MouthDetail(mouthDetail).mouthDetailItem3();
//         } else if (id == 4) {
//             return MouthDetail(mouthDetail).mouthDetailItem4();
//         } else if (id == 5) {
//             return MouthDetail(mouthDetail).mouthDetailItem5();
//         } else if (id == 6) {
//             return MouthDetail(mouthDetail).mouthDetailItem6();
//         } else if (id == 7) {
//             return MouthDetail(mouthDetail).mouthDetailItem7();
//         } else if (id == 8) {
//             return MouthDetail(mouthDetail).mouthDetailItem8();
//         } else if (id == 9) {
//             return MouthDetail(mouthDetail).mouthDetailItem9();
//         } else if (id == 10) {
//             return MouthDetail(mouthDetail).mouthDetailItem10();
//         } else if (id == 11) {
//             return MouthDetail(mouthDetail).mouthDetailItem11();
//         } else if (id == 12) {
//             return MouthDetail(mouthDetail).mouthDetailItem12();
//         } else if (id == 13) {
//             return MouthDetail(mouthDetail).mouthDetailItem13();
//         } else if (id == 14) {
//             return MouthDetail(mouthDetail).mouthDetailItem14();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getNoseDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return NoseDetail(noseDetail).noseDetailItem1();
//         } else if (id == 2) {
//             return NoseDetail(noseDetail).noseDetailItem2();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getEyesDetailSVG(uint8 id) internal view returns (string memory) {
//         if (id == 1) {
//             return EyesDetail(eyesDetail).eyesDetailItem1();
//         } else if (id == 2) {
//             return EyesDetail(eyesDetail).eyesDetailItem2();
//         } else if (id == 3) {
//             return EyesDetail(eyesDetail).eyesDetailItem3();
//         } else if (id == 4) {
//             return EyesDetail(eyesDetail).eyesDetailItem4();
//         } else if (id == 5) {
//             return EyesDetail(eyesDetail).eyesDetailItem5();
//         } else if (id == 6) {
//             return EyesDetail(eyesDetail).eyesDetailItem6();
//         } else if (id == 7) {
//             return EyesDetail(eyesDetail).eyesDetailItem7();
//         } else if (id == 8) {
//             return EyesDetail(eyesDetail).eyesDetailItem8();
//         } else if (id == 9) {
//             return EyesDetail(eyesDetail).eyesDetailItem9();
//         } else if (id == 10) {
//             return EyesDetail(eyesDetail).eyesDetailItem10();
//         } else if (id == 11) {
//             return EyesDetail(eyesDetail).eyesDetailItem11();
//         } else if (id == 12) {
//             return EyesDetail(eyesDetail).eyesDetailItem12();
//         } else if (id == 13) {
//             return EyesDetail(eyesDetail).eyesDetailItem13();
//         } else if (id == 14) {
//             return EyesDetail(eyesDetail).eyesDetailItem14();
//         } else if (id == 15) {
//             return EyesDetail(eyesDetail).eyesDetailItem15();
//         } else if (id == 16) {
//             return EyesDetail(eyesDetail).eyesDetailItem16();
//         } else if (id == 17) {
//             return EyesDetail(eyesDetail).eyesDetailItem17();
//         } else if (id == 18) {
//             return EyesDetail(eyesDetail).eyesDetailItem18();
//         } else if (id == 19) {
//             return EyesDetail(eyesDetail).eyesDetailItem19();
//         } else if (id == 20) {
//             return EyesDetail(eyesDetail).eyesDetailItem20();
//         } else if (id == 21) {
//             return EyesDetail(eyesDetail).eyesDetailItem21();
//         } else if (id == 22) {
//             return EyesDetail(eyesDetail).eyesDetailItem22();
//         } else if (id == 23) {
//             return EyesDetail(eyesDetail).eyesDetailItem23();
//         } else if (id == 24) {
//             return EyesDetail(eyesDetail).eyesDetailItem24();
//         } else if (id == 25) {
//             return EyesDetail(eyesDetail).eyesDetailItem25();
//         } else if (id == 26) {
//             return EyesDetail(eyesDetail).eyesDetailItem26();
//         } else if (id == 27) {
//             return EyesDetail(eyesDetail).eyesDetailItem27();
//         } else if (id == 28) {
//             return EyesDetail(eyesDetail).eyesDetailItem28();
//         } else if (id == 29) {
//             return EyesDetail(eyesDetail).eyesDetailItem29();
//         } else if (id == 30) {
//             return EyesDetail(eyesDetail).eyesDetailItem30();
//         } else if (id == 31) {
//             return EyesDetail(eyesDetail).eyesDetailItem31();
//         } else if (id == 32) {
//             return EyesDetail(eyesDetail).eyesDetailItem32();
//         } else if (id == 33) {
//             return EyesDetail(eyesDetail).eyesDetailItem33();
//         } else if (id == 34) {
//             return EyesDetail(eyesDetail).eyesDetailItem34();
//         } else {
//             revert("No hair item");
//         }
//     }

//     /// @notice Call the library item function
//     /// @param id The item ID
//     function getEyebrowDetailSVG(
//         uint8 id
//     ) internal view returns (string memory) {
//         if (id == 1) {
//             return EyebrowDetail(eyebrowDetail).eyebrowDetailItem1();
//         } else if (id == 2) {
//             return EyebrowDetail(eyebrowDetail).eyebrowDetailItem2();
//         } else if (id == 3) {
//             return EyebrowDetail(eyebrowDetail).eyebrowDetailItem3();
//         } else if (id == 4) {
//             return EyebrowDetail(eyebrowDetail).eyebrowDetailItem4();
//         } else if (id == 5) {
//             return EyebrowDetail(eyebrowDetail).eyebrowDetailItem5();
//         } else if (id == 6) {
//             return EyebrowDetail(eyebrowDetail).eyebrowDetailItem6();
//         } else {
//             revert("No hair item");
//         }
//     }

//     // /// @notice Call the library item function
//     // /// @param lib The library address
//     // /// @param id The item ID
//     // function getDetailSVG(
//     //     address lib,
//     //     uint8 id
//     // ) internal view returns (string memory) {
//     //     (bool success, bytes memory data) = lib.staticcall(
//     //         abi.encodeWithSignature(
//     //             string(abi.encodePacked("item_", Strings.toString(id), "()"))
//     //         )
//     //     );
//     //     require(success);
//     //     return abi.decode(data, (string));
//     // }

//     /// @dev generate Json Metadata name
//     function generateName(
//         SVGParams memory params,
//         uint256 tokenId
//     ) internal pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     // BackgroundDetail.getItemNameById(params.background),
//                     "--",
//                     " Onii ",
//                     Strings.toString(tokenId)
//                 )
//             );
//     }

//     /// @dev generate Json Metadata description
//     function generateDescription(
//         SVGParams memory params
//     ) internal pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     "Generated by ",
//                     Strings.toHexString(uint256(uint160(params.creator))),
//                     " at ",
//                     Strings.toString(params.timestamp)
//                 )
//             );
//     }

//     /// @dev generate SVG header
//     function generateSVGHead() private pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" x="0px" y="0px"',
//                     ' viewBox="0 0 420 420" style="enable-background:new 0 0 420 420;" xml:space="preserve">'
//                 )
//             );
//     }

//     /// @dev generate the "Copy" SVG if the onii is not the original
//     function generateCopy(bool original) private pure returns (string memory) {
//         return
//             !original
//                 ? string(
//                     abi.encodePacked(
//                         '<g id="Copy">',
//                         '<path fill="none" stroke="#F26559" stroke-width="0.5" stroke-miterlimit="10" d="M239.5,300.6c-4.9,1.8-5.9,8.1,1.3,4.1"/>',
//                         '<path fill="none" stroke="#F26559" stroke-width="0.5" stroke-miterlimit="10" d="M242.9,299.5c-2.6,0.8-1.8,4.3,0.8,4.2 C246.3,303.1,245.6,298.7,242.9,299.5"/>',
//                         '<path fill="none" stroke="#F26559" stroke-width="0.5" stroke-miterlimit="10" d="M247.5,302.9c0.2-1.6-1.4-4-0.8-5.4 c0.4-1.2,2.5-1.4,3.2-0.3c0.1,1.5-0.9,2.7-2.3,2.5"/>',
//                         '<path fill="none" stroke="#F26559" stroke-width="0.5" stroke-miterlimit="10" d="M250.6,295.4c1.1-0.1,2.2,0,3.3,0.1 c0.5-0.8,0.7-1.7,0.5-2.7"/>',
//                         '<path fill="none" stroke="#F26559" stroke-width="0.5" stroke-miterlimit="10" d="M252.5,299.1c0.5-1.2,1.2-2.3,1.4-3.5"/>',
//                         "</g>"
//                     )
//                 )
//                 : "";
//     }

//     /// @dev generate Json Metadata attributes
//     function generateAttributes(
//         SVGParams memory params
//     ) internal pure returns (string memory) {
//         return
//             string(
//                 abi.encodePacked(
//                     "[",
//                     getJsonAttribute(
//                         "Body",
//                         // BodyDetail.getItemNameById(params.skin),
//                         "1",
//                         false
//                     ),
//                     getJsonAttribute(
//                         "Hair",
//                         // HairDetail.getItemNameById(params.hair),
//                         "1",
//                         false
//                     ),
//                     getJsonAttribute(
//                         "Mouth",
//                         // MouthDetail.getItemNameById(params.mouth),
//                         "1",
//                         false
//                     ),
//                     getJsonAttribute(
//                         "Nose",
//                         // NoseDetail.getItemNameById(params.nose),
//                         "1",
//                         false
//                     ),
//                     getJsonAttribute(
//                         "Eyes",
//                         // EyesDetail.getItemNameById(params.eye),
//                         "1",
//                         false
//                     ),
//                     getJsonAttribute(
//                         "Eyebrow",
//                         // EyebrowDetail.getItemNameById(params.eyebrow),
//                         "1",
//                         false
//                     ),
//                     abi.encodePacked(
//                         getJsonAttribute(
//                             "Mark",
//                             // MarkDetail.getItemNameById(params.mark),
//                             "1",
//                             false
//                         ),
//                         getJsonAttribute(
//                             "Accessory",
//                             // AccessoryDetail.getItemNameById(params.accessory),
//                             "1",
//                             false
//                         ),
//                         getJsonAttribute(
//                             "Earrings",
//                             // EarringsDetail.getItemNameById(params.earring),
//                             "1",
//                             false
//                         ),
//                         getJsonAttribute(
//                             "Mask",
//                             // MaskDetail.getItemNameById(params.mask),
//                             "1",
//                             false
//                         ),
//                         getJsonAttribute(
//                             "Background",
//                             // BackgroundDetail.getItemNameById(params.background),
//                             "1",
//                             false
//                         ),
//                         getJsonAttribute(
//                             "Original",
//                             params.original ? "true" : "false",
//                             true
//                         ),
//                         "]"
//                     )
//                 )
//             );
//     }

//     /// @dev Get the json attribute as
//     ///    {
//     ///      "trait_type": "Skin",
//     ///      "value": "Human"
//     ///    }
//     function getJsonAttribute(
//         string memory trait,
//         string memory value,
//         bool end
//     ) private pure returns (string memory json) {
//         return
//             string(
//                 abi.encodePacked(
//                     '{ "trait_type" : "',
//                     trait,
//                     '", "value" : "',
//                     value,
//                     '" }',
//                     end ? "" : ","
//                 )
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function tokenURI(
//         IFullyChainDNFT oniiChain,
//         uint256 tokenId
//     ) external view override returns (string memory) {
//         SVGParams memory params = getSVGParams(oniiChain, tokenId);
//         params.background = getBackgroundId(params);
//         string memory image = Base64.encode(bytes(generateSVGImage(params)));
//         string memory name = generateName(params, tokenId);
//         string memory description = generateDescription(params);
//         string memory attributes = generateAttributes(params);

//         return
//             string(
//                 abi.encodePacked(
//                     "data:application/json;base64,",
//                     Base64.encode(
//                         bytes(
//                             abi.encodePacked(
//                                 '{"name":"',
//                                 name,
//                                 '", "description":"',
//                                 description,
//                                 '", "attributes":',
//                                 attributes,
//                                 ', "image": "',
//                                 "data:image/svg+xml;base64,",
//                                 image,
//                                 '"}'
//                             )
//                         )
//                     )
//                 )
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateHairId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 HAIR_ITEMS,
//                 this.generateHairId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateEyeId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 EYE_ITEMS,
//                 this.generateEyeId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateEyebrowId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 EYEBROW_ITEMS,
//                 this.generateEyebrowId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateNoseId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 NOSE_ITEMS,
//                 this.generateNoseId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateMouthId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 MOUTH_ITEMS,
//                 this.generateMouthId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateMarkId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 MARK_ITEMS,
//                 this.generateMarkId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateEarringsId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 EARRINGS_ITEMS,
//                 this.generateEarringsId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateAccessoryId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 ACCESSORY_ITEMS,
//                 this.generateAccessoryId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateMaskId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 MASK_ITEMS,
//                 this.generateMaskId.selector,
//                 tokenId
//             );
//     }

//     /// @inheritdoc IFullyChainDNFTDescriptor
//     function generateSkinId(
//         uint256 tokenId,
//         uint256 seed
//     ) external view override returns (uint8) {
//         return
//             generate(
//                 MAX,
//                 seed,
//                 SKIN_ITEMS,
//                 this.generateSkinId.selector,
//                 tokenId
//             );
//     }

//     /// @notice Generate a random number and return the index from the
//     ///         corresponding interval.
//     /// @param max The maximum value to generate
//     /// @param seed Used for the initialization of the number generator
//     /// @param intervals the intervals
//     /// @param selector Caller selector
//     /// @param tokenId the current tokenId
//     function generate(
//         uint256 max,
//         uint256 seed,
//         uint256[] memory intervals,
//         bytes4 selector,
//         uint256 tokenId
//     ) internal view returns (uint8) {
//         uint256 generated = generateRandom(max, seed, tokenId, selector);
//         return pickItems(generated, intervals);
//     }

//     /// @notice Generate random number between 1 and max
//     /// @param max Maximum value of the random number
//     /// @param seed Used for the initialization of the number generator
//     /// @param tokenId Current tokenId used as seed
//     /// @param selector Caller selector used as seed
//     function generateRandom(
//         uint256 max,
//         uint256 seed,
//         uint256 tokenId,
//         bytes4 selector
//     ) private view returns (uint256) {
//         return
//             (uint256(
//                 keccak256(
//                     abi.encodePacked(
//                         block.difficulty,
//                         block.number,
//                         tx.origin,
//                         tx.gasprice,
//                         selector,
//                         seed,
//                         tokenId
//                     )
//                 )
//             ) % (max + 1)) + 1;
//     }

//     /// @notice Pick an item for the given random value
//     /// @param val The random value
//     /// @param intervals The intervals for the corresponding items
//     /// @return the item ID where : intervals[] index + 1 = item ID
//     function pickItems(
//         uint256 val,
//         uint256[] memory intervals
//     ) internal pure returns (uint8) {
//         for (uint256 i; i < intervals.length; i++) {
//             if (val > intervals[i]) {
//                 return SafeCast.toUint8(i + 1);
//             }
//         }
//         revert("pickItems: No item");
//     }

//     /// @dev Get SVGParams from OniiChain.Detail
//     function getSVGParams(
//         IFullyChainDNFT oniiChain,
//         uint256 tokenId
//     ) private view returns (SVGParams memory) {
//         IFullyChainDNFT.Detail memory detail = oniiChain.details(tokenId);
//         return
//             SVGParams({
//                 hair: detail.hair,
//                 eye: detail.eye,
//                 eyebrow: detail.eyebrow,
//                 nose: detail.nose,
//                 mouth: detail.mouth,
//                 mark: detail.mark,
//                 earring: detail.earrings,
//                 accessory: detail.accessory,
//                 mask: detail.mask,
//                 skin: detail.skin,
//                 original: detail.original,
//                 background: 0,
//                 timestamp: detail.timestamp,
//                 creator: detail.creator
//             });
//     }

//     function getBackgroundId(
//         SVGParams memory params
//     ) private view returns (uint8) {
//         uint256 score = itemScorePosition(params.hair, HAIR_ITEMS) +
//             itemScoreProba(params.accessory, ACCESSORY_ITEMS) +
//             itemScoreProba(params.earring, EARRINGS_ITEMS) +
//             itemScoreProba(params.mask, MASK_ITEMS) +
//             itemScorePosition(params.mouth, MOUTH_ITEMS) +
//             (itemScoreProba(params.skin, SKIN_ITEMS) / 2) +
//             itemScoreProba(params.skin, SKIN_ITEMS) +
//             itemScoreProba(params.nose, NOSE_ITEMS) +
//             itemScoreProba(params.mark, MARK_ITEMS) +
//             itemScorePosition(params.eye, EYE_ITEMS) +
//             itemScoreProba(params.eyebrow, EYEBROW_ITEMS);
//         return pickItems(score, BACKGROUND_ITEMS);
//     }

//     /// @dev Get item score based on his probability
//     function itemScoreProba(
//         uint8 item,
//         uint256[] memory ITEMS
//     ) private pure returns (uint256) {
//         uint256 raw = ((item == 1 ? MAX : ITEMS[item - 2]) - ITEMS[item - 1]);
//         return ((raw >= 1000) ? raw * 6 : raw) / 1000;
//     }

//     /// @dev Get item score based on his index
//     function itemScorePosition(
//         uint8 item,
//         uint256[] memory ITEMS
//     ) private pure returns (uint256) {
//         uint256 raw = ITEMS[item - 1];
//         return ((raw >= 1000) ? raw * 6 : raw) / 1000;
//     }
// }
