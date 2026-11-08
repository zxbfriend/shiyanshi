/*
 Navicat Premium Dump SQL

 Source Server         : 3021DB
 Source Server Type    : MySQL
 Source Server Version : 50717 (5.7.17-log)
 Source Host           : 10.248.121.127:3306
 Source Schema         : IV_CDP_16

 Target Server Type    : MySQL
 Target Server Version : 50717 (5.7.17-log)
 File Encoding         : 65001

 Date: 09/06/2026 10:20:10
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for CDP_BioReactor_ItemSerials
-- ----------------------------
DROP TABLE IF EXISTS `CDP_BioReactor_ItemSerials`;
CREATE TABLE `CDP_BioReactor_ItemSerials`  (
  `BioReactorItemSerialsId` int(11) NOT NULL AUTO_INCREMENT,
  `ItemDefID` int(11) NOT NULL COMMENT '物料定义ID',
  `ItemSerialNumber` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '物料序号',
  `Description` varchar(128) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `LotNo` varchar(31) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Brand` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `MaxCapacity` decimal(18, 2) NOT NULL,
  `AssetNo` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  `Icon` varchar(64) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int(11) NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int(11) NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BioReactorItemSerialsId`) USING BTREE,
  INDEX `ItemDefID`(`ItemDefID`) USING BTREE,
  INDEX `ItemSerialNumber`(`ItemSerialNumber`) USING BTREE,
  INDEX `Status`(`Status`) USING BTREE,
  CONSTRAINT `cdp_bioreactor_itemserials_ibfk_1` FOREIGN KEY (`ItemDefID`) REFERENCES `CDP_Item_Def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 189 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of CDP_BioReactor_ItemSerials
-- ----------------------------
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (1, 8, '302119000000202112100001', '3L Bio-reactor', '20211210', '001', 2.50, NULL, 'images/public/img/tank-3L.png', b'1', b'1', 2, '2021-12-10 11:39:45', 14, '2022-08-12 13:38:26');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (2, 8, '302119000000202112100002', '3L Bio-reactor', '20211217', '001', 2.00, NULL, 'images/public/img/tank-3L.png', b'1', b'1', 13, '2021-12-17 16:48:58', 14, '2022-08-12 13:38:22');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (3, 9, 'FXCCPD-BXV-008', '15L Bio-reactor', '20211227', '002', 12.00, 'FXCCPD-BXV-008', 'images/public/img/tank-15L.png', b'1', b'0', 13, '2021-12-27 10:17:46', 13, '2021-12-27 10:17:46');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (4, 8, 'FXCCPD-BRX-001', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007892', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (5, 8, 'FXCCPD-BRX-002', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007893', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (6, 8, 'FXCCPD-BRX-003', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007894', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (7, 8, 'FXCCPD-BRX-004', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007895', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (8, 8, 'FXCCPD-BRX-005', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007896', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (9, 8, 'FXCCPD-BRX-006', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007897', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (10, 8, 'FXCCPD-BRX-007', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007898', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (11, 8, 'FXCCPD-BRX-008', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007899', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (12, 8, 'FXCCPD-BRX-009', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007900', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (13, 8, 'FXCCPD-BRX-010', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007901', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (14, 8, 'FXCCPD-BRX-011', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007902', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (15, 8, 'FXCCPD-BRX-012', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007903', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (16, 8, 'FXCCPD-BRX-013', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007904', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (17, 8, 'FXCCPD-BRX-014', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007905', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (18, 8, 'FXCCPD-BRX-015', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007906', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (19, 8, 'FXCCPD-BRX-016', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA007907', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (20, 8, 'FXCCPD-BRX-017', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096510', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (21, 8, 'FXCCPD-BRX-018', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096511', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (22, 8, 'FXCCPD-BRX-019', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096512', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (23, 8, 'FXCCPD-BRX-020', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096513', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (24, 8, 'FXCCPD-BRX-021', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096514', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (25, 8, 'FXCCPD-BRX-022', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096515', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (26, 8, 'FXCCPD-BRX-023', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096516', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (27, 8, 'FXCCPD-BRX-024', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096517', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (28, 8, 'FXCCPD-BRX-025', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096518', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (29, 8, 'FXCCPD-BRX-026', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096519', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (30, 8, 'FXCCPD-BRX-027', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096520', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (31, 8, 'FXCCPD-BRX-028', '3L生物反应器\r\n', NULL, '002', 2.40, 'FA2101096521', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (32, 8, 'FXCCPD-BRX-029', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (33, 8, 'FXCCPD-BRX-030', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (34, 8, 'FXCCPD-BRX-031', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (35, 8, 'FXCCPD-BRX-032', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (36, 8, 'FXCCPD-BRX-033', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (37, 8, 'FXCCPD-BRX-034', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (38, 8, 'FXCCPD-BRX-035', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (39, 8, 'FXCCPD-BRX-036', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (40, 8, 'FXCCPD-BRX-037', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (41, 8, 'FXCCPD-BRX-038', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (42, 8, 'FXCCPD-BRX-039', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (43, 8, 'FXCCPD-BRX-040', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (44, 8, 'FXCCPD-BRX-041', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (45, 8, 'FXCCPD-BRX-042', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (46, 8, 'FXCCPD-BRX-043', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (47, 8, 'FXCCPD-BRX-044', '3L生物反应器\r\n', NULL, '002', 2.40, '', 'images/public/img/tank-3L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (48, 9, 'FXCCPD-BXV-001', '15L生物反应器\r\n', NULL, '001', 12.00, 'FA007889', 'images/public/img/tank-15L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (49, 9, 'FXCCPD-BXV-002', '15L生物反应器\r\n', NULL, '001', 12.00, 'FA007890', 'images/public/img/tank-15L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (50, 9, 'FXCCPD-BXV-003', '15L生物反应器\r\n', NULL, '001', 12.00, 'FA2103000039', 'images/public/img/tank-15L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (51, 9, 'FXCCPD-BXV-004', '15L生物反应器\r\n', NULL, '001', 12.00, 'FA2103000040', 'images/public/img/tank-15L.png', b'1', b'0', NULL, NULL, NULL, NULL);
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (52, 9, 'FXCCPD-BXV-005', '15L Bio-reactor', '20220808', '001', 12.00, 'NA', 'images/public/img/tank-15L.png', b'1', b'0', 33, '2022-08-08 16:14:36', 33, '2022-08-08 16:14:36');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (53, 9, 'FXCCPD-BXV-006', '15L Bio-reactor', '20220808', '001', 12.00, 'NA', 'images/public/img/tank-15L.png', b'1', b'0', 33, '2022-08-08 16:14:58', 33, '2022-08-08 16:14:58');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (54, 9, 'FXCCPD-BXV-007', '15L Bio-reactor', '20220808', '001', 12.00, 'NA', 'images/public/img/tank-15L.png', b'1', b'0', 33, '2022-08-08 16:15:13', 33, '2022-08-08 16:15:13');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (55, 8, 'FXCCPD-BRX-055', '3L Bio-reactor', '20221010', '002', 2.40, 'NA', 'images/public/img/tank-3L.png', b'1', b'0', 16, '2022-10-10 13:23:09', 16, '2022-10-10 13:23:09');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (56, 8, 'FXCCPD-BRX-046', '3L Bio-reactor', '20221010', '002', 2.40, 'NA', 'images/public/img/tank-3L.png', b'1', b'0', 16, '2022-10-10 13:24:06', 16, '2022-10-10 13:24:06');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (57, 8, 'FXCCPD-BRX-059', '3L Bio-reactor', '20221010', '002', 2.40, 'NA', 'images/public/img/tank-3L.png', b'1', b'0', 16, '2022-10-10 13:25:23', 16, '2022-10-10 13:25:23');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (58, 8, 'FXCCPD-BRX-067', '3L Bio-reactor', '20230629', '002', 2.40, 'FA2201000457', 'images/public/img/tank-3L.png', b'1', b'0', 13, '2023-06-29 10:15:43', 13, '2023-06-29 10:15:43');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (59, 8, 'FXCCPD-BRX-056', '3L Bio-reactor', '20230629', '002', 2.40, 'FA2112002048', 'images/public/img/tank-3L.png', b'1', b'0', 13, '2023-06-29 10:16:15', 13, '2023-06-29 10:16:15');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (60, 9, 'FXCCPD-BRX-063', '15L Bio-reactor', '20230629', '002', 15.00, 'FA2201000453', 'images/public/img/tank-15L.png', b'1', b'0', 13, '2023-06-29 10:16:50', 43, '2025-05-29 14:14:20');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (61, 9, 'FXCCPD-BRX-045', '15L Bio-reactor', '20230901', '002', 15.00, 'FXCCPD-BRX-045', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:05:39', 43, '2025-05-29 14:20:13');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (62, 8, 'FXCCPD-BRX-047', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-047', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:05:58', 98, '2023-09-01 14:05:58');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (63, 8, 'FXCCPD-BRX-048', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-048', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:06:15', 98, '2023-09-01 14:06:15');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (64, 8, 'FXCCPD-BRX-049', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-049', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:06:29', 98, '2023-09-01 14:06:29');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (65, 8, 'FXCCPD-BRX-050', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-050', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:06:41', 98, '2023-09-01 14:06:41');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (66, 8, 'FXCCPD-BRX-051', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-051', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:06:52', 98, '2023-09-01 14:06:52');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (67, 8, 'FXCCPD-BRX-052', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-052', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:07:09', 98, '2023-09-01 14:07:09');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (68, 8, 'FXCCPD-BRX-053', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-053', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:07:22', 98, '2023-09-01 14:07:22');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (69, 8, 'FXCCPD-BRX-054', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-054', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:07:33', 98, '2023-09-01 14:07:33');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (70, 8, 'FXCCPD-BRX-057', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-057', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:08:35', 98, '2023-09-01 14:08:35');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (71, 8, 'FXCCPD-BRX-058', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-058', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:08:47', 98, '2023-09-01 14:08:47');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (72, 8, 'FXCCPD-BRX-060', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-060', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:09:03', 98, '2023-09-01 14:09:03');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (73, 8, 'FXCCPD-BRX-061', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-061', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:09:11', 98, '2023-09-01 14:09:11');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (74, 9, 'FXCCPD-BRX-062', '15L Bio-reactor', '20230901', '002', 15.00, 'FXCCPD-BRX-062', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:09:42', 43, '2025-05-29 14:17:35');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (75, 8, 'FXCCPD-BRX-064', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-064', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:10:02', 98, '2023-09-01 14:10:02');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (76, 8, 'FXCCPD-BRX-065', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-065', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:10:16', 98, '2023-09-01 14:10:16');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (77, 8, 'FXCCPD-BRX-066', '3L Bio-reactor', '20230901', '002', 2.40, 'FXCCPD-BRX-066', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-01 14:13:02', 98, '2023-09-01 14:13:02');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (78, 9, 'V-15-01', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-01', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:20:23', 98, '2023-09-01 14:20:23');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (79, 9, 'V-15-02', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-02', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:21:02', 98, '2023-09-01 14:21:02');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (80, 9, 'V-15-03', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-03', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:21:18', 98, '2023-09-01 14:21:18');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (81, 9, 'V-15-04', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-04', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:21:32', 98, '2023-09-01 14:21:32');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (82, 9, 'V-15-05', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-05', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:21:42', 98, '2023-09-01 14:21:42');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (83, 9, 'V-15-06', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-06', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:21:55', 98, '2023-09-01 14:21:55');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (84, 9, 'V-15-07', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-07', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:22:07', 98, '2023-09-01 14:22:07');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (85, 9, 'V-15-08', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-08', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:22:18', 98, '2023-09-01 14:22:18');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (86, 9, 'V-15-09', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-09', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:22:28', 98, '2023-09-01 14:22:28');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (87, 9, 'V-15-10', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-10', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:22:38', 98, '2023-09-01 14:22:38');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (88, 9, 'V-15-11', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-11', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:22:50', 98, '2023-09-01 14:22:50');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (89, 9, 'V-15-12', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-12', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:23:02', 98, '2023-09-01 14:23:02');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (90, 9, 'V-15-13', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-13', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:23:14', 98, '2023-09-01 14:23:14');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (91, 9, 'V-15-14', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-14', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:23:24', 98, '2023-09-01 14:23:24');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (92, 9, 'V-15-15', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-15', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:23:37', 98, '2023-09-01 14:23:37');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (93, 9, 'V-15-16', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-16', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:23:49', 98, '2023-09-01 14:23:49');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (94, 9, 'V-15-17', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-17', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:24:02', 98, '2023-09-01 14:24:02');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (95, 9, 'V-15-18', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-18', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:24:13', 98, '2023-09-01 14:24:13');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (96, 9, 'V-15-19', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-19', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:24:24', 98, '2023-09-01 14:24:24');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (97, 9, 'V-15-20', '15L Bio-reactor', '20230901', '002', 10.00, 'V-15-20', 'images/public/img/tank-15L.png', b'1', b'0', 98, '2023-09-01 14:24:35', 98, '2023-09-01 14:24:35');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (98, 8, 'FXCCPD-BRX-068', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-068', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:29:32', 98, '2023-09-02 15:29:32');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (99, 8, 'FXCCPD-BRX-069', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-069', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:29:43', 98, '2023-09-02 15:29:43');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (100, 8, 'FXCCPD-BRX-070', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-070', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:29:54', 98, '2023-09-02 15:29:54');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (101, 8, 'FXCCPD-BRX-071', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-071', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:30:06', 98, '2023-09-02 15:30:06');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (102, 8, 'FXCCPD-BRX-072', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-072', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:30:17', 98, '2023-09-02 15:30:17');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (103, 8, 'FXCCPD-BRX-073', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-073', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:30:32', 98, '2023-09-02 15:30:32');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (104, 8, 'FXCCPD-BRX-074', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-074', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:30:40', 98, '2023-09-02 15:30:40');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (105, 8, 'FXCCPD-BRX-075', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-075', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:30:51', 98, '2023-09-02 15:30:51');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (106, 8, 'FXCCPD-BRX-076', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-076', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:00', 98, '2023-09-02 15:31:00');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (107, 8, 'FXCCPD-BRX-077', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-077', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:09', 98, '2023-09-02 15:31:09');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (108, 8, 'FXCCPD-BRX-078', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-078', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:18', 98, '2023-09-02 15:31:18');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (109, 8, 'FXCCPD-BRX-079', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-079', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:26', 98, '2023-09-02 15:31:26');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (110, 8, 'FXCCPD-BRX-080', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-080', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:36', 98, '2023-09-02 15:31:36');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (111, 8, 'FXCCPD-BRX-081', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-081', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:46', 98, '2023-09-02 15:31:46');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (112, 8, 'FXCCPD-BRX-082', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-082', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:31:54', 98, '2023-09-02 15:31:54');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (113, 8, 'FXCCPD-BRX-083', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-083', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:32:01', 98, '2023-09-02 15:32:01');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (114, 8, 'FXCCPD-BRX-084', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-084', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:32:16', 98, '2023-09-02 15:32:16');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (115, 8, 'FXCCPD-BRX-085', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-085', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:32:24', 98, '2023-09-02 15:32:24');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (116, 8, 'FXCCPD-BRX-086', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-086', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:32:34', 98, '2023-09-02 15:32:34');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (117, 8, 'FXCCPD-BRX-087', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-087', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:32:44', 98, '2023-09-02 15:32:44');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (118, 8, 'FXCCPD-BRX-088', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-088', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:32:51', 98, '2023-09-02 15:32:51');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (119, 8, 'FXCCPD-BRX-089', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-089', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:00', 98, '2023-09-02 15:33:00');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (120, 8, 'FXCCPD-BRX-090', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-090', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:12', 98, '2023-09-02 15:33:12');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (121, 8, 'FXCCPD-BRX-091', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-091', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:19', 98, '2023-09-02 15:33:19');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (122, 8, 'FXCCPD-BRX-092', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-092', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:27', 98, '2023-09-02 15:33:27');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (123, 8, 'FXCCPD-BRX-093', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-093', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:35', 98, '2023-09-02 15:33:35');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (124, 8, 'FXCCPD-BRX-094', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-094', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:43', 98, '2023-09-02 15:33:43');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (125, 8, 'FXCCPD-BRX-095', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-095', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:33:53', 98, '2023-09-02 15:33:53');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (126, 8, 'FXCCPD-BRX-096', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-096', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:34:02', 98, '2023-09-02 15:34:02');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (127, 8, 'FXCCPD-BRX-097', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-097', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:34:10', 98, '2023-09-02 15:34:10');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (128, 8, 'FXCCPD-BRX-098', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-098', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:34:19', 98, '2023-09-02 15:34:19');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (129, 8, 'FXCCPD-BRX-099', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-099', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:34:28', 98, '2023-09-02 15:34:28');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (130, 8, 'FXCCPD-BRX-100', '3L Bio-reactor', '20230902', '002', 2.40, 'FXCCPD-BRX-100', 'images/public/img/tank-3L.png', b'1', b'0', 98, '2023-09-02 15:34:41', 98, '2023-09-02 15:34:41');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (131, 8, 'test-0911', '3L Bio-reactor', '20230911', '001', 2.00, 'test-0911', 'images/public/img/tank-3L.png', b'1', b'1', 33, '2023-09-11 16:43:17', 152, '2023-12-08 11:02:11');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (132, 8, 'FX033', '3L Bio-reactor', '20231110', '001', 2.00, 'TEST-033', 'images/public/img/tank-3L.png', b'1', b'1', 98, '2023-11-10 14:05:50', 152, '2023-12-08 11:02:48');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (133, 8, 'FX034', '3L Bio-reactor', '20231110', '001', 2.00, 'TEST-034', 'images/public/img/tank-3L.png', b'1', b'1', 98, '2023-11-10 14:06:33', 152, '2023-12-08 11:02:41');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (134, 8, 'FX035', '3L Bio-reactor', '20231110', '001', 2.00, 'TEST-035', 'images/public/img/tank-3L.png', b'1', b'1', 98, '2023-11-10 14:06:42', 152, '2023-12-08 11:02:46');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (135, 8, 'FX036', '3L Bio-reactor', '20231110', '001', 2.00, 'TEST-036', 'images/public/img/tank-3L.png', b'1', b'1', 98, '2023-11-10 14:06:48', 152, '2023-12-08 11:02:43');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (136, 8, 'FXCCPD-BRX-016_1', '3L Bio-reactor', '20231122', '001', 2.40, 'FXCCPD-BRX-016_1', 'images/public/img/tank-3L.png', b'1', b'0', 22, '2023-11-22 10:19:48', 22, '2023-11-22 10:19:48');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (138, 8, 'FXCCPD-BRX-054_1', '3L Bio-reactor', '20231122', '001', 2.40, 'FXCCPD-BRX-054_1', 'images/public/img/tank-3L.png', b'1', b'0', 22, '2023-11-22 10:23:12', 22, '2023-11-22 10:23:12');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (141, 8, 'FXCCPD-BRX-888', '3L Bio-reactor', '20231218', '001', 2.00, 'FXCCPD-BRX-098', 'images/public/img/tank-3L.png', b'1', b'1', 13, '2023-12-18 10:40:00', 13, '2023-12-18 10:40:22');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (143, 8, 'FXCCPDBRX042', '3L Bio-reactor', '20240417', '001', 2.00, 'NA', 'images/public/img/tank-3L.png', b'1', b'0', 132, '2024-04-17 16:02:45', 132, '2024-04-17 16:02:45');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (145, 8, 'FXCCPD-BRX-107', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-107', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:07:16', 28, '2024-09-25 11:07:16');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (147, 8, 'FXCCPD-BRX-108', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-108', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:08:14', 28, '2024-09-25 11:08:14');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (149, 8, 'FXCCPD-BRX-109', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-109', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:08:27', 28, '2024-09-25 11:08:27');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (151, 8, 'FXCCPD-BRX-110', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-110', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:08:55', 28, '2024-09-25 11:08:55');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (153, 8, 'FXCCPD-BRX-111', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-111', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:04', 28, '2024-09-25 11:09:04');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (155, 8, 'FXCCPD-BRX-112', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-112', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:13', 28, '2024-09-25 11:09:13');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (157, 8, 'FXCCPD-BRX-113', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-113', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:21', 28, '2024-09-25 11:09:21');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (159, 8, 'FXCCPD-BRX-114', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-114', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:29', 28, '2024-09-25 11:09:29');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (161, 8, 'FXCCPD-BRX-115', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-115', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:37', 28, '2024-09-25 11:09:37');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (163, 8, 'FXCCPD-BRX-116', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-116', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:45', 28, '2024-09-25 11:09:45');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (165, 8, 'FXCCPD-BRX-117', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-117', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:09:53', 28, '2024-09-25 11:09:53');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (167, 8, 'FXCCPD-BRX-118', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-118', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:01', 28, '2024-09-25 11:10:01');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (169, 8, 'FXCCPD-BRX-119', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-119', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:09', 28, '2024-09-25 11:10:09');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (171, 8, 'FXCCPD-BRX-120', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-120', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:18', 28, '2024-09-25 11:10:18');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (173, 8, 'FXCCPD-BRX-121', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-121', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:27', 28, '2024-09-25 11:10:27');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (175, 8, 'FXCCPD-BRX-122', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-122', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:41', 28, '2024-09-25 11:10:41');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (177, 8, 'FXCCPD-BRX-123', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-123', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:50', 28, '2024-09-25 11:10:50');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (179, 8, 'FXCCPD-BRX-124', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-124', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:10:57', 28, '2024-09-25 11:10:57');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (181, 8, 'FXCCPD-BRX-125', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-125', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:11:05', 28, '2024-09-25 11:11:05');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (183, 8, 'FXCCPD-BRX-126', '3L Bio-reactor', '20240925', '001', 2.00, 'FXCCPD-BRX-126', 'images/public/img/tank-3L.png', b'1', b'0', 28, '2024-09-25 11:11:12', 28, '2024-09-25 11:11:12');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (185, 9, 'T-V-15-02', '15L Bio-reactor', '20250710', '001', 15.00, '1154896', 'images/public/img/tank-15L.png', b'1', b'0', 17, '2025-07-10 18:26:17', 17, '2025-07-10 18:26:28');
INSERT INTO `CDP_BioReactor_ItemSerials` VALUES (187, 9, 'H-15-13', '15L Bio-reactor', '20260228', '001', 12.00, 'H-15-13', 'images/public/img/tank-15L.png', b'1', b'0', 17, '2026-02-28 14:21:31', 17, '2026-02-28 14:21:31');

SET FOREIGN_KEY_CHECKS = 1;
