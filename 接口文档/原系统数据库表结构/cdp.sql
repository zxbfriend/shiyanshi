/*
 Navicat Premium Dump SQL

 Source Server         : 101.200.152.223-ymsc
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : 101.200.152.223:6033
 Source Schema         : cdp

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 01/09/2026 16:11:43
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for auth_culture
-- ----------------------------
DROP TABLE IF EXISTS `auth_culture`;
CREATE TABLE `auth_culture`  (
  `CultureID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `CultureCode` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '培养编号',
  `Alias` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '别名',
  `PreBatchId` int NULL DEFAULT NULL COMMENT '批次关联id',
  `PrincipalId` int NULL DEFAULT NULL COMMENT '责任人',
  `LabDeviceId` int NULL DEFAULT NULL COMMENT '设备ID',
  `BatchStartTime` datetime NULL DEFAULT NULL COMMENT '培养开始时间',
  `IrrigationIdentificationID` int NULL DEFAULT NULL COMMENT '灌流标识：1 批次培养 3 灌流培养',
  `SpecialCulture` bit(1) NULL DEFAULT NULL COMMENT '是否特殊培养',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`CultureID`) USING BTREE,
  INDEX `PreBatchId`(`PreBatchId` ASC) USING BTREE,
  INDEX ```CultureCode```(`CultureCode` ASC) USING BTREE,
  INDEX `LabDeviceId`(`LabDeviceId` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  CONSTRAINT `auth_culture_ibfk_1` FOREIGN KEY (`PreBatchId`) REFERENCES `auth_prebatch` (`PreBatchId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '培养表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_culture
-- ----------------------------

-- ----------------------------
-- Table structure for auth_department
-- ----------------------------
DROP TABLE IF EXISTS `auth_department`;
CREATE TABLE `auth_department`  (
  `DepartmentId` int NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `DepartmentName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `DepartmentCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`DepartmentId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '部门表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_department
-- ----------------------------

-- ----------------------------
-- Table structure for auth_module
-- ----------------------------
DROP TABLE IF EXISTS `auth_module`;
CREATE TABLE `auth_module`  (
  `ModuleId` int NOT NULL AUTO_INCREMENT COMMENT '模块ID',
  `ModuleNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ModuleName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ModuleSetting` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `URL` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Icon` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SuperModuleId` int NULL DEFAULT NULL COMMENT '主模块',
  `SortNo` int NOT NULL DEFAULT 1 COMMENT '排序',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ModuleId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '模块表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_module
-- ----------------------------

-- ----------------------------
-- Table structure for auth_prebatch
-- ----------------------------
DROP TABLE IF EXISTS `auth_prebatch`;
CREATE TABLE `auth_prebatch`  (
  `PreBatchId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `PreBatchNo` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '批次编号',
  `PreBatchName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '批次名称',
  `Alias` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '别名',
  `ProjectId` int NULL DEFAULT NULL COMMENT '项目id',
  `PrincipalId` int NULL DEFAULT NULL COMMENT '责任人',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`PreBatchId`) USING BTREE,
  INDEX ```PreBatchId```(`PreBatchId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '批次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_prebatch
-- ----------------------------

-- ----------------------------
-- Table structure for auth_prebatchuser
-- ----------------------------
DROP TABLE IF EXISTS `auth_prebatchuser`;
CREATE TABLE `auth_prebatchuser`  (
  `PreBatchUserId` int NOT NULL AUTO_INCREMENT,
  `PreBatchId` int NOT NULL COMMENT '项目ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `LimitToDate` datetime NULL DEFAULT NULL COMMENT '用户过期时间',
  `Upload` bit(1) NOT NULL COMMENT '上传',
  `RevokeUpload` bit(1) NOT NULL COMMENT '撤回上传',
  `Signature` bit(1) NOT NULL COMMENT '签名',
  `RevokeSignature` bit(1) NOT NULL COMMENT '撤回签名',
  `Verify` bit(1) NOT NULL COMMENT '审核',
  `RevokeVerify` bit(1) NOT NULL COMMENT '撤回审核',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`PreBatchUserId`) USING BTREE,
  INDEX `PreBatchId`(`PreBatchId` ASC) USING BTREE,
  INDEX `UserId`(`UserId` ASC) USING BTREE,
  INDEX `LimitToDate`(`LimitToDate` ASC) USING BTREE,
  CONSTRAINT `auth_prebatchuser_ibfk_1` FOREIGN KEY (`PreBatchId`) REFERENCES `auth_prebatch` (`PreBatchId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '有批次权限的用户' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_prebatchuser
-- ----------------------------

-- ----------------------------
-- Table structure for auth_project
-- ----------------------------
DROP TABLE IF EXISTS `auth_project`;
CREATE TABLE `auth_project`  (
  `ProjectId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `DepartmentId` int NULL DEFAULT NULL COMMENT '部门id',
  `ProjectNo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '项目编号',
  `ProjectName` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '项目名称',
  `PrincipalId` int NULL DEFAULT NULL COMMENT '责任人',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProjectId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '项目表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_project
-- ----------------------------

-- ----------------------------
-- Table structure for auth_projectdepartment
-- ----------------------------
DROP TABLE IF EXISTS `auth_projectdepartment`;
CREATE TABLE `auth_projectdepartment`  (
  `ProjectDepartmentId` int NOT NULL AUTO_INCREMENT,
  `ProjectId` int NOT NULL,
  `DepartmentId` int NOT NULL,
  `IsDelete` bit(1) NULL DEFAULT NULL,
  PRIMARY KEY (`ProjectDepartmentId`) USING BTREE,
  INDEX `ProjectId`(`ProjectId` ASC) USING BTREE,
  INDEX `DepartmentId`(`DepartmentId` ASC) USING BTREE,
  CONSTRAINT `auth_projectdepartment_ibfk_1` FOREIGN KEY (`ProjectId`) REFERENCES `auth_project` (`ProjectId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_projectdepartment_ibfk_2` FOREIGN KEY (`DepartmentId`) REFERENCES `auth_department` (`DepartmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用--项目部门' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_projectdepartment
-- ----------------------------

-- ----------------------------
-- Table structure for auth_projectuser
-- ----------------------------
DROP TABLE IF EXISTS `auth_projectuser`;
CREATE TABLE `auth_projectuser`  (
  `ProjectUserId` int NOT NULL AUTO_INCREMENT,
  `ProjectId` int NOT NULL COMMENT '项目ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `LimitToDate` datetime NULL DEFAULT NULL COMMENT '用户过期时间',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProjectUserId`) USING BTREE,
  INDEX `fk_project_fk1`(`ProjectId` ASC) USING BTREE,
  INDEX `fk_user_fk2`(`UserId` ASC) USING BTREE,
  CONSTRAINT `fk_project_fk1` FOREIGN KEY (`ProjectId`) REFERENCES `auth_project` (`ProjectId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_user_fk2` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_projectuser
-- ----------------------------

-- ----------------------------
-- Table structure for auth_role
-- ----------------------------
DROP TABLE IF EXISTS `auth_role`;
CREATE TABLE `auth_role`  (
  `RoleId` int NOT NULL AUTO_INCREMENT COMMENT '养老机构角色ID',
  `MachineId` int NOT NULL COMMENT '机器ID',
  `ParentRoleId` int NULL DEFAULT NULL COMMENT '父角色ID',
  `RoleName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `RoleType` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`RoleId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_role
-- ----------------------------

-- ----------------------------
-- Table structure for auth_rolemodule
-- ----------------------------
DROP TABLE IF EXISTS `auth_rolemodule`;
CREATE TABLE `auth_rolemodule`  (
  `RoleModuleId` int NOT NULL AUTO_INCREMENT COMMENT '角色模块ID',
  `ModuleId` int NOT NULL COMMENT '模块ID',
  `RoleId` int NULL DEFAULT NULL COMMENT '养老机构角色ID',
  `ModuleSetting` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `CheckState` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`RoleModuleId`) USING BTREE,
  INDEX `FK_REF_LTC_ROLEMODULES_LTC_MODULES`(`ModuleId` ASC) USING BTREE,
  INDEX `FK_Reference_63`(`RoleId` ASC) USING BTREE,
  CONSTRAINT `FK_REF_LTC_ROLEMODULES_LTC_MODULES` FOREIGN KEY (`ModuleId`) REFERENCES `auth_module` (`ModuleId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_63` FOREIGN KEY (`RoleId`) REFERENCES `auth_role` (`RoleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '角色菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_rolemodule
-- ----------------------------

-- ----------------------------
-- Table structure for auth_rolereactor
-- ----------------------------
DROP TABLE IF EXISTS `auth_rolereactor`;
CREATE TABLE `auth_rolereactor`  (
  `RoleReactorId` int NOT NULL AUTO_INCREMENT,
  `LabDeviceId` int NOT NULL,
  `RoleId` int NOT NULL,
  `CheckState` bit(1) NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`RoleReactorId`) USING BTREE,
  INDEX `ReactorId`(`LabDeviceId` ASC) USING BTREE,
  INDEX `RoleId`(`RoleId` ASC) USING BTREE,
  CONSTRAINT `auth_rolereactor_ibfk_1` FOREIGN KEY (`LabDeviceId`) REFERENCES `cdp_labdevice` (`LabDeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_rolereactor_ibfk_2` FOREIGN KEY (`RoleId`) REFERENCES `auth_role` (`RoleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '哪些角色可以看的罐子' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_rolereactor
-- ----------------------------

-- ----------------------------
-- Table structure for auth_site
-- ----------------------------
DROP TABLE IF EXISTS `auth_site`;
CREATE TABLE `auth_site`  (
  `SiteId` int NOT NULL AUTO_INCREMENT COMMENT 'SiteID\r\n',
  `SiteName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `SiteCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '地址',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`SiteId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '基地表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_site
-- ----------------------------

-- ----------------------------
-- Table structure for auth_user
-- ----------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user`  (
  `UserId` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `Account` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Pwd` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DisplayName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OnlineStatus` bit(1) NOT NULL DEFAULT b'0',
  `Email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsInitialPwd` bit(1) NOT NULL COMMENT '是否初始密码',
  `LatestOperation` datetime NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `DepartmentId` int NULL DEFAULT NULL,
  `PasswordEffectiveDate` date NULL DEFAULT NULL COMMENT '密码生效时间',
  `PasswordValidityPeriod` int NULL DEFAULT NULL COMMENT '密码有效时间',
  `PasswordExpirationDate` date NULL DEFAULT NULL COMMENT '密码过期时间',
  PRIMARY KEY (`UserId`) USING BTREE,
  INDEX `fk1`(`DepartmentId` ASC) USING BTREE,
  CONSTRAINT `fk1` FOREIGN KEY (`DepartmentId`) REFERENCES `auth_department` (`DepartmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_user
-- ----------------------------

-- ----------------------------
-- Table structure for auth_usercache
-- ----------------------------
DROP TABLE IF EXISTS `auth_usercache`;
CREATE TABLE `auth_usercache`  (
  `UserCacheId` int NOT NULL AUTO_INCREMENT,
  `UserId` int NOT NULL,
  `DepartmentId` int NULL DEFAULT NULL,
  `RoomId` int NULL DEFAULT NULL,
  `BGARoomId` int NULL DEFAULT NULL,
  `VicellRoomId` int NULL DEFAULT NULL,
  `OSMORoomId` int NULL DEFAULT NULL,
  `OSMO6060RoomId` int NULL DEFAULT NULL,
  `CedexRoomId` int NULL DEFAULT NULL,
  PRIMARY KEY (`UserCacheId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_usercache
-- ----------------------------

-- ----------------------------
-- Table structure for auth_userfeedingspeedsetting
-- ----------------------------
DROP TABLE IF EXISTS `auth_userfeedingspeedsetting`;
CREATE TABLE `auth_userfeedingspeedsetting`  (
  `FeedingId` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `UserId` int NOT NULL,
  `Feeding1Speed` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Feeding2Speed` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Feeding3Speed` varchar(25) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OtherSpeed` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`FeedingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '创建一期自动补料时记录用户、泵与泵速，方便下一次创建相同项目、同批次 同培养的补料时泵速默认用上一次的' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_userfeedingspeedsetting
-- ----------------------------

-- ----------------------------
-- Table structure for auth_userlab
-- ----------------------------
DROP TABLE IF EXISTS `auth_userlab`;
CREATE TABLE `auth_userlab`  (
  `UserLabId` int NOT NULL AUTO_INCREMENT,
  `UserId` int NOT NULL,
  `LabId` int NOT NULL,
  PRIMARY KEY (`UserLabId`) USING BTREE,
  INDEX `FK_Reference_64`(`LabId` ASC) USING BTREE,
  INDEX `FK_Reference_65`(`UserId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_65` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '没理解' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_userlab
-- ----------------------------

-- ----------------------------
-- Table structure for auth_userloginlog
-- ----------------------------
DROP TABLE IF EXISTS `auth_userloginlog`;
CREATE TABLE `auth_userloginlog`  (
  `UserLoginId` int NOT NULL AUTO_INCREMENT COMMENT '用户登录ID',
  `LabID` int NULL DEFAULT NULL COMMENT '机器ID',
  `LoginTime` datetime NULL DEFAULT NULL COMMENT '登录时间',
  `LoginIP` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LogoutTime` datetime NULL DEFAULT NULL COMMENT '注销时间',
  `Browser` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OS` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `MAC` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `PCName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UserId` int NULL DEFAULT NULL COMMENT '用户ID',
  PRIMARY KEY (`UserLoginId`) USING BTREE,
  INDEX `FK_Reference_66`(`UserId` ASC) USING BTREE,
  INDEX `FK_Reference_60`(`LabID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_60` FOREIGN KEY (`LabID`) REFERENCES `cdp_lab` (`LabID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_66` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户登入记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_userloginlog
-- ----------------------------

-- ----------------------------
-- Table structure for auth_userrole
-- ----------------------------
DROP TABLE IF EXISTS `auth_userrole`;
CREATE TABLE `auth_userrole`  (
  `UserRoleId` int NOT NULL AUTO_INCREMENT COMMENT '用户角色ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `RoleId` int NOT NULL COMMENT '角色ID',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`UserRoleId`) USING BTREE,
  INDEX `FK_Reference_126`(`UserId` ASC) USING BTREE,
  INDEX `FK_Reference_127`(`RoleId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_126` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_127` FOREIGN KEY (`RoleId`) REFERENCES `auth_role` (`RoleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_userrole
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_alarm_inventorysetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_alarm_inventorysetting`;
CREATE TABLE `cdp_alarm_inventorysetting`  (
  `InventoryAlarmSettingID` int NOT NULL AUTO_INCREMENT,
  `ItemDefID` int NULL DEFAULT NULL,
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '位置组合ID',
  `SettingType` int NOT NULL COMMENT '物料类型:\r\n1: Consumable Configuration\r\n3: Liquid Configuration\r\n5: Sampling Unit Configuration\r\n7: Feeding Unit Configuration',
  `NormalQuantity` decimal(18, 2) NULL DEFAULT 0.00 COMMENT '正常数量',
  `DefaultAlarmQuantity` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '默认报警数量',
  `AlarmQuantity` decimal(18, 2) NOT NULL DEFAULT 0.00 COMMENT '告警数量',
  `Operator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL DEFAULT 'lt' COMMENT 'lt:less than;gt:great than',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`InventoryAlarmSettingID`) USING BTREE,
  INDEX `ItemDefID`(`ItemDefID` ASC) USING BTREE,
  INDEX `LocCombinationID`(`LocCombinationID` ASC) USING BTREE,
  CONSTRAINT `cdp_alarm_inventorysetting_ibfk_1` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_alarm_inventorysetting_ibfk_2` FOREIGN KEY (`LocCombinationID`) REFERENCES `cdp_location_combinations` (`LocCombinationID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '报警-库存设置\r\n物料报警配置\r\n物料类型:\r\n1: Consumable Configuration\r\n3: Liquid Configuration\r\n5: Sampling Unit Configuration\r\n7: Feeding Unit Configuration' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_alarm_inventorysetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_alarm_testingsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_alarm_testingsetting`;
CREATE TABLE `cdp_alarm_testingsetting`  (
  `TestingAlarmSettingID` int NOT NULL AUTO_INCREMENT,
  `TestingDefID` int NOT NULL COMMENT '检测项目定义',
  `WarningLowerLimit` decimal(18, 4) NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 4) NULL DEFAULT NULL,
  `DataType` int NULL DEFAULT NULL COMMENT 'Feed 1 Perfusion 3',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingAlarmSettingID`) USING BTREE,
  INDEX `TestingDefID`(`TestingDefID` ASC) USING BTREE,
  CONSTRAINT `cdp_alarm_testingsetting_ibfk_2` FOREIGN KEY (`TestingDefID`) REFERENCES `cdp_testingdef` (`TestingDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '报警-离线检测\r\n检测项报警配置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_alarm_testingsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_auto_setting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_auto_setting`;
CREATE TABLE `cdp_auto_setting`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `LabDeviceId` int NULL DEFAULT NULL,
  `LocCombinationID` int NULL DEFAULT NULL,
  `LabId` int NULL DEFAULT NULL,
  `BatchId` int NULL DEFAULT NULL,
  `BatchCode` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Name` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Desc` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `UpperLimit` decimal(20, 4) NULL DEFAULT NULL,
  `LowerLimit` decimal(20, 4) NULL DEFAULT NULL,
  `Variable` decimal(20, 4) NULL DEFAULT NULL COMMENT '可能需要一个计算自动创建Vicell任务时间的变量',
  `Parameter` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其他需要的参数，例如降温需要的温度',
  `Other` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备用字段',
  `Type` int NOT NULL DEFAULT 0 COMMENT '1.pH 3.Temp 降温',
  `Count` int NOT NULL DEFAULT 0 COMMENT '执行次数 目前只是降温用',
  `Status` int NULL DEFAULT 0,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `IsEnable` bit(1) NULL DEFAULT NULL COMMENT '0.禁用 1.启用',
  `RunTime` datetime NULL DEFAULT NULL,
  `UpdateTime` datetime NULL DEFAULT NULL,
  `UpdateBy` int NULL DEFAULT NULL,
  `CreateTime` datetime NOT NULL,
  `CreateBy` int NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '自动化设置\r\n无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_auto_setting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_auto_setting_task
-- ----------------------------
DROP TABLE IF EXISTS `cdp_auto_setting_task`;
CREATE TABLE `cdp_auto_setting_task`  (
  `AutoTaskId` int NOT NULL AUTO_INCREMENT,
  `LabId` int NULL DEFAULT NULL COMMENT '1.一期 2.二期',
  `BatchId` int NULL DEFAULT NULL,
  `LabDeviceId` int NULL DEFAULT NULL,
  `LabDeviceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ProjectId` int NULL DEFAULT NULL,
  `BatchCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '批次号',
  `ProjectCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '项目号',
  `NotCalibrated` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不校准',
  `CalibrateToIntermediateValue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准至中间值',
  `CalibrateToOfflineValue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准至离线值',
  `Type` int NULL DEFAULT NULL COMMENT '1.pH 3.Temp',
  `Status` int NULL DEFAULT NULL COMMENT '1.未执行 3.执行中 5.已执行 7.执行出错 9.终止 99.已取消',
  `CreatedBy` int NULL DEFAULT NULL,
  `CreatedTime` datetime NULL DEFAULT NULL,
  `UpdatedBy` int NULL DEFAULT NULL,
  `UpdatedTime` datetime NULL DEFAULT NULL,
  `IsDeleted` bit(1) NULL DEFAULT b'0',
  PRIMARY KEY (`AutoTaskId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '自动化设置-ph校准-定时触发的存储' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_auto_setting_task
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_auto_setting_task_info
-- ----------------------------
DROP TABLE IF EXISTS `cdp_auto_setting_task_info`;
CREATE TABLE `cdp_auto_setting_task_info`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `AutoTaskId` int NULL DEFAULT NULL,
  `LabDeviceId` int NULL DEFAULT NULL,
  `LabDeviceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `LocCombinationID` int NULL DEFAULT NULL,
  `LabId` int NULL DEFAULT NULL,
  `BatchId` int NULL DEFAULT NULL,
  `BatchCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ProjectCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Rule1Param` decimal(10, 4) NULL DEFAULT NULL,
  `Rule1Operation` int NULL DEFAULT NULL COMMENT '1.不校准 3.中间值 5.离线值',
  `Rule2Param1` decimal(10, 4) NULL DEFAULT NULL,
  `Rule2Param2` decimal(10, 4) NULL DEFAULT NULL,
  `Rule2Operation` int NULL DEFAULT NULL COMMENT '1.不校准 3.中间值 5.离线值',
  `Rule3Param1` decimal(10, 4) NULL DEFAULT NULL,
  `Rule3Param2` decimal(10, 4) NULL DEFAULT 0.0000,
  `Rule3Operation` int NULL DEFAULT 0 COMMENT '1.不校准 3.中间值 5.离线值',
  `Rule4Param` decimal(10, 4) NULL DEFAULT NULL,
  `Rule4Operation` int NULL DEFAULT NULL COMMENT '1.不校准 3.中间值 5.离线值',
  `RunTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NULL DEFAULT 0,
  `IsDeleted` bit(1) NULL DEFAULT b'0',
  `UpdatedTime` datetime NULL DEFAULT NULL,
  `UpdatedBy` int NULL DEFAULT NULL,
  `CreatedTime` datetime NULL DEFAULT NULL,
  `CreatedBy` int NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '自动化设置-ph校准-定时触发的存储-规则-明细表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_auto_setting_task_info
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_auto_setting_task_msg
-- ----------------------------
DROP TABLE IF EXISTS `cdp_auto_setting_task_msg`;
CREATE TABLE `cdp_auto_setting_task_msg`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `AutoSettingTaskId` int NULL DEFAULT NULL,
  `Mode` int NULL DEFAULT NULL COMMENT '1.自动 3.手动',
  `ExecuteTime` datetime NULL DEFAULT NULL,
  `ProjectCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BatchCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ReactorNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `OperationUser` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '？',
  `OnlineValue` decimal(10, 4) NULL DEFAULT NULL,
  `OfflineValue` decimal(10, 4) NULL DEFAULT NULL,
  `PH` decimal(10, 4) NULL DEFAULT NULL,
  `CalibratedTo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Message` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1.执行成功 3.执行失败',
  `CreatedBy` int NULL DEFAULT 1,
  `CreatedTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '自动化设置-ph校准-定时触发的存储-消息配置-执行信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_auto_setting_task_msg
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_autoop_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_autoop_rec`;
CREATE TABLE `cdp_autoop_rec`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `BatchOPId` int NULL DEFAULT NULL,
  `BatchOPSubId` int NULL DEFAULT NULL,
  `CurrentSpeed` int NULL DEFAULT NULL COMMENT '实时泵速',
  `CurrentScaleValue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '地秤当前读数',
  `PumpCalculation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '泵计算量',
  `ScaleCalculation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '地秤计算量',
  `CurrentTime` datetime NULL DEFAULT NULL COMMENT '当前时间',
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_autoop_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch`;
CREATE TABLE `cdp_batch`  (
  `BatchID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '位置ID',
  `ProjectID` int NULL DEFAULT NULL COMMENT '项目ID',
  `PreBatchID` int NULL DEFAULT NULL COMMENT '培养批次ID',
  `MediumName` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '培养基名称',
  `CultureID` int NULL DEFAULT NULL COMMENT '培养记录ID',
  `ReactorSerialNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '罐体SN',
  `BatchName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '批次名称',
  `BatchCode` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `MediumVolume` decimal(18, 2) NOT NULL COMMENT '培养液体积',
  `MediumLotNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '培养基lotno',
  `MediumTemp` decimal(18, 2) NULL DEFAULT NULL COMMENT '培养基温度',
  `CellType` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT '15',
  `CellsVolume` decimal(18, 2) NOT NULL COMMENT '细胞体积',
  `RefillVolumeAtf` decimal(18, 0) NULL DEFAULT NULL,
  `RefillVolume` decimal(18, 0) NULL DEFAULT NULL,
  `RefillSpeed` int NULL DEFAULT NULL COMMENT '罐子预填充速度',
  `RefillAtfSpeed` int NULL DEFAULT NULL COMMENT '柱后预填充速度',
  `AtfReservedSpeed` int NULL DEFAULT NULL COMMENT '柱后留样速度',
  `InitialViableCellNumber` decimal(18, 2) NULL DEFAULT NULL COMMENT '初始活细胞数量',
  `StartTime` datetime NULL DEFAULT NULL COMMENT '批次开始时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT '批次结束时间',
  `CurrentVolume` decimal(18, 2) NULL DEFAULT NULL,
  `CurrentCedexGlucoseTime` datetime NULL DEFAULT NULL COMMENT '糖指定时间',
  `CurrentGlucoseWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '当前罐体中糖的重量g',
  `CurrentVCD` decimal(18, 2) NULL DEFAULT NULL COMMENT '？',
  `CurrentViability` decimal(18, 2) NULL DEFAULT NULL,
  `CurrentBGAPH` decimal(18, 2) NULL DEFAULT NULL,
  `CurrentOSMO` decimal(18, 2) NULL DEFAULT NULL,
  `LastPH` decimal(18, 2) NULL DEFAULT NULL,
  `LastDO` decimal(18, 2) NULL DEFAULT NULL,
  `LastOxygenFlowRate` decimal(18, 2) NULL DEFAULT NULL,
  `LastStirrer` decimal(18, 2) NULL DEFAULT NULL,
  `LastTemp` decimal(18, 2) NULL DEFAULT NULL,
  `ErrorCode` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '批次执行错误码',
  `IsFeeding` bit(1) NULL DEFAULT NULL COMMENT '是否补料中 0否1是',
  `Status` int NULL DEFAULT 3 COMMENT 'New  1.用户创建新批次\r\nScanQR 3.用户扫码物料\r\nNonInoculation 5.待接种\r\nWaitingSupply 7.待接补料单元\r\nProducting 9.生产中\r\nCompleted 11.完成\r\nAbort 15.中止\r\nCanceled 99.取消',
  `StartBatchTime` datetime NULL DEFAULT NULL,
  `StartBatchUser` int NULL DEFAULT NULL,
  `InoculationTime` datetime NULL DEFAULT NULL COMMENT '接种时间',
  `InoculationUser` int NULL DEFAULT NULL COMMENT '接种用户',
  `SupplementaryUnitTime` datetime NULL DEFAULT NULL COMMENT '补液时间',
  `SupplementaryUser` int NULL DEFAULT NULL COMMENT '补液用户',
  `CompleteTime` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `CompleteUser` int NULL DEFAULT NULL COMMENT '完成用户',
  `CancelTime` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `CancelUser` int NULL DEFAULT NULL,
  `CancelDescription` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '取消描述',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`BatchID`) USING BTREE,
  INDEX `FK_Reference_68`(`WorkflowID` ASC) USING BTREE,
  INDEX `FK_Reference_71`(`LocCombinationID` ASC) USING BTREE,
  INDEX ```BatchID```(`BatchID` ASC) USING BTREE,
  INDEX ```PreBatchID```(`PreBatchID` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_68` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_71` FOREIGN KEY (`LocCombinationID`) REFERENCES `cdp_location_combinations` (`LocCombinationID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '批次' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_cellsdata
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_cellsdata`;
CREATE TABLE `cdp_batch_cellsdata`  (
  `BatchCellsDataID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchOPID` int NULL DEFAULT NULL COMMENT 'ID',
  `ItemID` int NULL DEFAULT NULL COMMENT '物料明细ID',
  `TestingVicellTaskDtlID` int NULL DEFAULT NULL,
  `TotalVolume` decimal(18, 2) NULL DEFAULT NULL,
  `TotalViableNumber` decimal(18, 2) NULL DEFAULT NULL COMMENT '母瓶总的活细胞数',
  `TotalCellsNumber` decimal(18, 2) NULL DEFAULT NULL COMMENT '母瓶总的细胞数',
  `Created_By` int NULL DEFAULT NULL COMMENT '记录创建账号的ID',
  `Creation_Time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  PRIMARY KEY (`BatchCellsDataID`) USING BTREE,
  INDEX `FK_Reference_90`(`BatchID` ASC) USING BTREE,
  INDEX `FK_Reference_91`(`BatchOPID` ASC) USING BTREE,
  INDEX `FK_Reference_92`(`ItemID` ASC) USING BTREE,
  INDEX `FK_Reference_93`(`TestingVicellTaskDtlID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_90` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_91` FOREIGN KEY (`BatchOPID`) REFERENCES `cdp_batch_op` (`BatchOPID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_92` FOREIGN KEY (`ItemID`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_93` FOREIGN KEY (`TestingVicellTaskDtlID`) REFERENCES `cdp_testing_vicelltaskdtl` (`TestingVicellTaskDtlID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '不知道干什么的' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_cellsdata
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_epsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_epsetting`;
CREATE TABLE `cdp_batch_epsetting`  (
  `EPSettingId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `RecordNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '记录编号 20230612142401',
  `EPDefId` int NOT NULL COMMENT 'ID',
  `ItemDefID` int NOT NULL COMMENT '物料定义ID',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次ID',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT '记录时间',
  `ActioLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionUpperLimit` decimal(18, 2) NULL DEFAULT NULL,
  `IsEnable` bit(1) NULL DEFAULT NULL COMMENT '是否启用',
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  PRIMARY KEY (`EPSettingId`) USING BTREE,
  INDEX `FK_Reference_14`(`EPDefId` ASC) USING BTREE,
  INDEX `FK_Reference_82`(`ItemDefID` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC, `IsDelete` ASC) USING BTREE,
  CONSTRAINT `cdp_batch_epsetting_ibfk_1` FOREIGN KEY (`EPDefId`) REFERENCES `cdp_epdef` (`EPDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_batch_epsetting_ibfk_2` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次报警细化\r\n无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_epsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_epsetting_history
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_epsetting_history`;
CREATE TABLE `cdp_batch_epsetting_history`  (
  `EPSettingHistoryId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `RecordNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '记录编号 20230612142401',
  `EPDefId` int NOT NULL COMMENT 'ID',
  `ItemDefID` int NOT NULL COMMENT '物料定义ID',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次ID',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT '记录时间',
  `ActioLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionUpperLimit` decimal(18, 2) NULL DEFAULT NULL,
  `IsEnable` bit(1) NULL DEFAULT NULL COMMENT '是否启用',
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  PRIMARY KEY (`EPSettingHistoryId`) USING BTREE,
  INDEX `FK_Reference_14`(`EPDefId` ASC) USING BTREE,
  INDEX `FK_Reference_82`(`ItemDefID` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC, `IsDelete` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次报警细化\r\n无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_epsetting_history
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_feedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_feedingtask`;
CREATE TABLE `cdp_batch_feedingtask`  (
  `BatchFeedingTaskId` int NOT NULL AUTO_INCREMENT,
  `BatchId` int NOT NULL,
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `Day` int NULL DEFAULT NULL,
  `FeedingTime` time NULL DEFAULT NULL COMMENT '补料时间',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent 3:Feeding ByVolume 5：Rule',
  `FeedingVolumePercent` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料体积百分比',
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料体积',
  `LowerLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/L',
  `FeedingTo` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/L',
  `LowerLimitOperator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '1:< 2:<=',
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT '下发速度',
  PRIMARY KEY (`BatchFeedingTaskId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料任务规则' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_feedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_fixedfeedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_fixedfeedingtask`;
CREATE TABLE `cdp_batch_fixedfeedingtask`  (
  `BatchTaskID` int NOT NULL AUTO_INCREMENT,
  `TaskNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `SoureType` int NULL DEFAULT NULL COMMENT '1:Protocol\r\n            3:User Creation   5:SubSystem Insert',
  `Mode` int NOT NULL DEFAULT 1 COMMENT '1:Automatic\r\n            3:Maunal',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingMediumID` int NULL DEFAULT NULL COMMENT 'ID',
  `FeedingTime` datetime NOT NULL COMMENT 'ID',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n            3:Feeding By Volume  5:Rule',
  `FeedingVolumePercent` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `IsFeedingGlucose` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否是补糖Task',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `ConfirmUserID` int NULL DEFAULT NULL,
  `ConfirmTime` datetime NULL DEFAULT NULL,
  `ConfirmUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '确认人签名',
  `ReviewUserID` int NULL DEFAULT NULL,
  `ReviewTime` datetime NULL DEFAULT NULL,
  `ReviewUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `ApproveUserID` int NULL DEFAULT NULL,
  `ApproveTime` datetime NULL DEFAULT NULL,
  `ApproveUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `StartUserID` int NULL DEFAULT NULL,
  `AbortUserID` int NULL DEFAULT NULL,
  `AbortTime` datetime NULL DEFAULT NULL,
  `AbortUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '取消人签名',
  `AbortReviewUserID` int NULL DEFAULT NULL COMMENT '取消复核人id',
  `AbortReviewTime` datetime NULL DEFAULT NULL COMMENT '取消复核时间',
  `AbortReviewUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '取消复核连接',
  `CedexSampleID` int NULL DEFAULT NULL,
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `TotalFeedingTime` int NULL DEFAULT NULL COMMENT 's',
  `TotalFeedingRealVolume` decimal(18, 2) NULL DEFAULT NULL,
  `CurrentVolumeBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料前净重',
  `CurrentVolumeAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料后净重',
  `GlucoseWeightBefore` decimal(18, 10) NULL DEFAULT NULL COMMENT '补料前糖重量',
  `GlucoseWeightAfter` decimal(18, 10) NULL DEFAULT NULL COMMENT '补料后糖重量',
  `ReactorWeightFeedingBefore` decimal(18, 2) NULL DEFAULT NULL,
  `ReactorWeightFeedingAfter` decimal(18, 2) NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '1：Pending Review\r\n2：Pending Cancel\r\n            3：Pending Approve\r\n            5：Pending Execute\r\n            7：Executing\r\n            9：执行出错\r\n            11：执行出错已处理\r\n            17：Skiped\r\n            19：Executed\r\n            99: Canceled',
  `AbnormalCause` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '异常原因',
  `CreateCause` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '创建原因',
  `AbnormalCompleteVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '异常时完成的重量',
  `FeedingExpectTime` int NULL DEFAULT NULL COMMENT '预计补料耗时（手动用）',
  `LowerLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/L',
  `FeedingTo` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/L',
  `LowerLimitOperator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '1: < 2:<=',
  `TaskQueueID` int NULL DEFAULT NULL COMMENT '任务队列主键',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchTaskID`) USING BTREE,
  INDEX `TaskNo`(`TaskNo` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '固定泵补料任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_fixedfeedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_op
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_op`;
CREATE TABLE `cdp_batch_op`  (
  `BatchOPID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `LabId` int NULL DEFAULT NULL COMMENT '实验室ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `OPID` int NULL DEFAULT NULL COMMENT 'ID',
  `Mode` int NOT NULL DEFAULT 3 COMMENT '1:Manual\r\n            3:Automatic',
  `Status` int NOT NULL DEFAULT 1 COMMENT '1.Pending\r\n            3.Executing\r\n            5.Executed\r\n            99.Canceled',
  `StartTime` datetime NULL DEFAULT NULL COMMENT 'OP开始时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT 'OP结束时间',
  `SequenceNumber` int NOT NULL DEFAULT 1,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchOPID`) USING BTREE,
  INDEX `FK_Reference_48`(`OPID` ASC) USING BTREE,
  INDEX `FK_Reference_64`(`BatchID` ASC) USING BTREE,
  INDEX `Mode`(`Mode` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  INDEX `IsDelete`(`IsDelete` ASC) USING BTREE,
  INDEX `BatchID`(`BatchID` ASC, `OPID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_64` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '自动取测的任务主表  任务队列---主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_op
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_op_exec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_op_exec`;
CREATE TABLE `cdp_batch_op_exec`  (
  `ExecID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NOT NULL,
  `BatchOPID` int NOT NULL,
  `OPSubID` int NOT NULL,
  `ActualValue` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ExecID`) USING BTREE,
  INDEX `cap_batch_op_exec_batchopid`(`BatchOPID` ASC) USING BTREE,
  CONSTRAINT `cap_batch_op_exec_batchopid` FOREIGN KEY (`BatchOPID`) REFERENCES `cdp_batch_op` (`BatchOPID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '自动取测的任务主表  任务队列---子表  调度系统用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_op_exec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_op_parametersubvalue
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_op_parametersubvalue`;
CREATE TABLE `cdp_batch_op_parametersubvalue`  (
  `OPParameterSubID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `OPParameterID` int NOT NULL COMMENT 'ID',
  `ParameterSubID` int NOT NULL,
  `TopValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BottomValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Value` bit(1) NULL DEFAULT NULL,
  `SequenceNumber` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`OPParameterSubID`) USING BTREE,
  INDEX `OPParameterID`(`OPParameterID` ASC) USING BTREE,
  CONSTRAINT `cdp_batch_op_parametersubvalue_ibfk_1` FOREIGN KEY (`OPParameterID`) REFERENCES `cdp_batch_op_parametervalue` (`OPParameterID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_op_parametersubvalue
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_op_parametervalue
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_op_parametervalue`;
CREATE TABLE `cdp_batch_op_parametervalue`  (
  `OPParameterID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchSubOPID` int NULL DEFAULT NULL COMMENT 'ID',
  `ParameterID` int NULL DEFAULT NULL COMMENT 'ID',
  `SubParameterID` int NULL DEFAULT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SequenceNumber` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`OPParameterID`) USING BTREE,
  INDEX `BatchSubOPID`(`BatchSubOPID` ASC) USING BTREE,
  CONSTRAINT `cdp_batch_op_parametervalue_ibfk_1` FOREIGN KEY (`BatchSubOPID`) REFERENCES `cdp_batch_op_sub` (`BatchOPSubID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_op_parametervalue
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_op_sub
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_op_sub`;
CREATE TABLE `cdp_batch_op_sub`  (
  `BatchOPSubID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchOPID` int NOT NULL COMMENT 'ID',
  `OPSubID` int NOT NULL COMMENT 'ID',
  `Status` int NOT NULL DEFAULT 1 COMMENT '1.Pending\r\n            3.Executing\r\n            5.Executed\r\n            99.Canceled',
  `StartTime` datetime NULL DEFAULT NULL COMMENT 'OP开始时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT 'OP结束时间',
  `Value` bit(1) NULL DEFAULT NULL,
  `SequenceNumber` int NOT NULL DEFAULT 1,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchOPSubID`) USING BTREE,
  INDEX `BatchOPID`(`BatchOPID` ASC) USING BTREE,
  INDEX `OPSubID`(`OPSubID` ASC) USING BTREE,
  INDEX `Value`(`Value` ASC) USING BTREE,
  INDEX `Time`(`StartTime` ASC, `EndTime` ASC) USING BTREE,
  CONSTRAINT `cdp_batch_op_sub_ibfk_1` FOREIGN KEY (`BatchOPID`) REFERENCES `cdp_batch_op` (`BatchOPID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_batch_op_sub_ibfk_2` FOREIGN KEY (`OPSubID`) REFERENCES `cdp_op_definitionsub` (`OPSubID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_op_sub
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_opexecution
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_opexecution`;
CREATE TABLE `cdp_batch_opexecution`  (
  `OPExecutionID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NOT NULL,
  `BatchOPID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OPExecutionID`) USING BTREE,
  INDEX `FK_Reference_51`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_51` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_opexecution
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_opexecutiondetail
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_opexecutiondetail`;
CREATE TABLE `cdp_batch_opexecutiondetail`  (
  `OPExecutionDetailID` int NOT NULL AUTO_INCREMENT,
  `OPExecutionID` int NOT NULL,
  `RecordType` int NOT NULL COMMENT 'OPID\r\n            \r\n            OPID: Defined \r\n            \r\n            0:Input\r\n            \r\n            -97:Trash;-99:Product(Non defined OP<=0)',
  `VesselID1` int NULL DEFAULT NULL COMMENT '主体容器ID',
  `FluidID` int NULL DEFAULT NULL,
  `FluidVolume` decimal(18, 2) NULL DEFAULT NULL,
  `VesselID2` int NULL DEFAULT NULL COMMENT '液体操作时目标容器ID',
  `CarrierID` int NULL DEFAULT NULL COMMENT '操作耗材，目前主要是记录Tip头',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OPExecutionDetailID`) USING BTREE,
  INDEX `FK_EXEDETAIL_REFERENCE_ACM_BATC`(`OPExecutionID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_opexecutiondetail
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_phcorrection
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_phcorrection`;
CREATE TABLE `cdp_batch_phcorrection`  (
  `BatchPHCorrectionID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `PH_BGA` decimal(18, 2) NULL DEFAULT NULL,
  `PH_Bio_Ractor` decimal(18, 2) NULL DEFAULT NULL,
  `PH_Corrected_Value` decimal(18, 2) NULL DEFAULT NULL,
  `CorrectionTime` datetime NULL DEFAULT NULL COMMENT 'OP开始时间',
  `Status` int NOT NULL DEFAULT 1 COMMENT '1.Pending\r\n            3.Corrected\r\n            99.Canceled',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchPHCorrectionID`) USING BTREE,
  INDEX `FK_Reference_81`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_81` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_phcorrection
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batchfeedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batchfeedingtask`;
CREATE TABLE `cdp_batchfeedingtask`  (
  `BatchTaskID` int NOT NULL AUTO_INCREMENT,
  `TaskNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `SoureType` int NULL DEFAULT NULL COMMENT '1:Protocol\r\n            3:User Creation   5:SubSystem Insert',
  `LocCombinationID` int NULL DEFAULT NULL,
  `Mode` int NOT NULL DEFAULT 1 COMMENT '1:Automatic\r\n            3:Maunal',
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL,
  `ItemID` int NULL DEFAULT NULL COMMENT '物料ID',
  `FeedingTime` datetime NOT NULL COMMENT 'ID',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n3:Feeding By Volume\r\n5.Rule',
  `FeedingVolumePercent` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `LowerLimitOperator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '1: < 2:<=',
  `LowerLimit` decimal(18, 2) NOT NULL COMMENT 'g/L',
  `FeedingTo` decimal(18, 2) NOT NULL COMMENT 'g/L',
  `FeedingTimeOut` int NULL DEFAULT NULL,
  `IsFeedingGlucose` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否是补糖Task',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `ConfirmUserID` int NULL DEFAULT NULL,
  `ConfirmTime` datetime NULL DEFAULT NULL,
  `ConfirmUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '确认人签名',
  `StartUserID` int NULL DEFAULT NULL,
  `AbortUserID` int NULL DEFAULT NULL,
  `AbortTime` datetime NULL DEFAULT NULL,
  `AbortUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '取消人签名',
  `CedexSampleID` int NULL DEFAULT NULL,
  `ReactorWeightFeedingBefore` decimal(18, 2) NULL DEFAULT NULL,
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `TotalFeedingTime` int NULL DEFAULT NULL COMMENT 's',
  `TotalFeedingRealVolume` decimal(18, 2) NULL DEFAULT NULL,
  `ReactorWeightFeedingAfter` decimal(18, 2) NULL DEFAULT NULL,
  `CurrentVolumeBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料前净重',
  `CurrentVolumeAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料后净重',
  `GlucoseWeightBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料前糖重量',
  `GlucoseWeightAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料后糖重量',
  `Status` int NOT NULL COMMENT '1：Pending Review\r\n2：Pending Cancel\r\n            3：Pending Approve\r\n            5：Pending Execute\r\n            7：Executing\r\n            9：执行出错\r\n            11：执行出错已处理\r\n            17：Skiped\r\n            19：Executed\r\n            99: Canceled',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchTaskID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batchfeedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_bioreactor_itemserials
-- ----------------------------
DROP TABLE IF EXISTS `cdp_bioreactor_itemserials`;
CREATE TABLE `cdp_bioreactor_itemserials`  (
  `BioReactorItemSerialsId` int NOT NULL AUTO_INCREMENT,
  `ItemDefID` int NOT NULL COMMENT '物料定义ID',
  `ItemSerialNumber` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '物料序号',
  `Description` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `LotNo` varchar(31) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Brand` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `MaxCapacity` decimal(18, 2) NOT NULL,
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Icon` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BioReactorItemSerialsId`) USING BTREE,
  INDEX `ItemDefID`(`ItemDefID` ASC) USING BTREE,
  INDEX `ItemSerialNumber`(`ItemSerialNumber` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  CONSTRAINT `cdp_bioreactor_itemserials_ibfk_1` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '罐子信息表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_bioreactor_itemserials
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_celltypesetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_celltypesetting`;
CREATE TABLE `cdp_celltypesetting`  (
  `CellTypeId` int NOT NULL AUTO_INCREMENT,
  `CellTypeNo` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '细胞类型标识',
  `CellTypeName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '细胞类型名称',
  `SortNo` int NULL DEFAULT NULL COMMENT '排序',
  `IsDelete` bit(1) NULL DEFAULT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_Time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`CellTypeId`) USING BTREE,
  INDEX `CellTypeNo`(`CellTypeNo` ASC) USING BTREE,
  INDEX `CellTypeName`(`CellTypeName` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '细胞类型表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_celltypesetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_channelconfig
-- ----------------------------
DROP TABLE IF EXISTS `cdp_channelconfig`;
CREATE TABLE `cdp_channelconfig`  (
  `ChannelConfigID` int NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `ChannelNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '液桶位置ID',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ChannelConfigID`) USING BTREE,
  INDEX `FK_Reference_76`(`LocCombinationID` ASC) USING BTREE,
  INDEX `FK_Reference_67`(`LabDeviceID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_67` FOREIGN KEY (`LabDeviceID`) REFERENCES `cdp_labdevice` (`LabDeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_channelconfig
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_coderule
-- ----------------------------
DROP TABLE IF EXISTS `cdp_coderule`;
CREATE TABLE `cdp_coderule`  (
  `LabId` int NOT NULL COMMENT '机器ID',
  `CodeKey` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '编码Key',
  `GenerateRule` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '规则',
  `SerialNumber` int NOT NULL COMMENT '当前序号',
  PRIMARY KEY (`LabId`, `CodeKey`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_coderule
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_db_versions
-- ----------------------------
DROP TABLE IF EXISTS `cdp_db_versions`;
CREATE TABLE `cdp_db_versions`  (
  `VersionId` int NOT NULL AUTO_INCREMENT,
  `BackFileName` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `BackTime` datetime NULL DEFAULT NULL,
  `MajorNumber` int NOT NULL DEFAULT 0,
  `MinorNumber` int NOT NULL DEFAULT 0,
  `RevisionNumber` int NOT NULL DEFAULT 0,
  `BuildNumber` int NOT NULL DEFAULT 0,
  `FullVersion` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`VersionId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '数据库版本' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_db_versions
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_dict
-- ----------------------------
DROP TABLE IF EXISTS `cdp_dict`;
CREATE TABLE `cdp_dict`  (
  `DictId` int NOT NULL AUTO_INCREMENT COMMENT '字典ID',
  `DictNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DictName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsUserLevelFlag` bit(1) NULL DEFAULT NULL COMMENT '是否用户级(页面显示否)',
  `IsModifyFlag` bit(1) NOT NULL COMMENT 'A:只可新增\r\n               H:隐藏\r\n               N:不可修改\r\n               Y:可以修改',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`DictId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '字典表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_dict
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_dictdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_dictdtl`;
CREATE TABLE `cdp_dictdtl`  (
  `DictDtlId` int NOT NULL AUTO_INCREMENT COMMENT '字典明细Id',
  `DictId` int NULL DEFAULT NULL COMMENT '字典ID',
  `DictDtlNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DictDtlName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SortNo` int NULL DEFAULT NULL COMMENT '排序',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`DictDtlId`) USING BTREE,
  INDEX `FK_Reference_62`(`DictId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_62` FOREIGN KEY (`DictId`) REFERENCES `cdp_dict` (`DictId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '字典表详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_dictdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_co2_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_co2_rec`;
CREATE TABLE `cdp_ep_co2_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceId` int NOT NULL COMMENT '设备ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'online表，在线数据。从cdp_ep_co2_rec到cdp_ep_vesselweight_stat上是在线数据，缓存。' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_co2_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_co2_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_co2_stat`;
CREATE TABLE `cdp_ep_co2_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceId` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_co2_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_do_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_do_rec`;
CREATE TABLE `cdp_ep_do_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_59`(`EPSettingId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_do_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_do_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_do_stat`;
CREATE TABLE `cdp_ep_do_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_do_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate1_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate1_rec`;
CREATE TABLE `cdp_ep_oxygenflowrate1_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate1_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate1_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate1_stat`;
CREATE TABLE `cdp_ep_oxygenflowrate1_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate1_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate2_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate2_rec`;
CREATE TABLE `cdp_ep_oxygenflowrate2_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate2_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate2_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate2_stat`;
CREATE TABLE `cdp_ep_oxygenflowrate2_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate2_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate_rec`;
CREATE TABLE `cdp_ep_oxygenflowrate_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_ph_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_ph_rec`;
CREATE TABLE `cdp_ep_ph_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '页面实时数据' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_ph_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_ph_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_ph_stat`;
CREATE TABLE `cdp_ep_ph_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_ph_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump1_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump1_rec`;
CREATE TABLE `cdp_ep_pump1_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump1_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump1_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump1_stat`;
CREATE TABLE `cdp_ep_pump1_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump1_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump2_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump2_rec`;
CREATE TABLE `cdp_ep_pump2_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump2_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump2_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump2_stat`;
CREATE TABLE `cdp_ep_pump2_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump2_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump3_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump3_rec`;
CREATE TABLE `cdp_ep_pump3_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump3_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump3_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump3_stat`;
CREATE TABLE `cdp_ep_pump3_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump3_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump4_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump4_rec`;
CREATE TABLE `cdp_ep_pump4_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump4_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump4_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump4_stat`;
CREATE TABLE `cdp_ep_pump4_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump4_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump5_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump5_rec`;
CREATE TABLE `cdp_ep_pump5_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump5_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump5_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump5_stat`;
CREATE TABLE `cdp_ep_pump5_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump5_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump6_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump6_rec`;
CREATE TABLE `cdp_ep_pump6_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump6_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump6_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump6_stat`;
CREATE TABLE `cdp_ep_pump6_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump6_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_rec_current
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_rec_current`;
CREATE TABLE `cdp_ep_rec_current`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceId` int NOT NULL COMMENT '设备ID',
  `Value` decimal(8, 3) NOT NULL COMMENT '值',
  `RecordTime` datetime NOT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_rec_current
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_stirrer_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_stirrer_rec`;
CREATE TABLE `cdp_ep_stirrer_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NULL DEFAULT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '页面实时数据--转速' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_stirrer_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_stirrer_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_stirrer_stat`;
CREATE TABLE `cdp_ep_stirrer_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_stirrer_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_temp_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_temp_rec`;
CREATE TABLE `cdp_ep_temp_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '页面实时数据--温度' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_temp_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_temp_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_temp_stat`;
CREATE TABLE `cdp_ep_temp_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_temp_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_vesselweight_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_vesselweight_rec`;
CREATE TABLE `cdp_ep_vesselweight_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingID` int NULL DEFAULT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL,
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX ```EPSettingID```(`EPSettingID` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```RecordTime```(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_vesselweight_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_vesselweight_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_vesselweight_stat`;
CREATE TABLE `cdp_ep_vesselweight_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPSettingId` int NOT NULL COMMENT 'ID',
  `LabDeviceID` int NOT NULL COMMENT '设备ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX ```EPSettingId```(`EPSettingId` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX ```PeriodCode```(`PeriodCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'online表，在线数据。从cdp_ep_co2_rec到cdp_ep_vesselweight_stat上是在线数据，缓存。' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_vesselweight_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epdef
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epdef`;
CREATE TABLE `cdp_epdef`  (
  `EPDefID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '名称',
  `EPName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '名称',
  `UpperLimit` decimal(10, 0) NULL DEFAULT NULL COMMENT '检测上线值',
  `LowerLimit` decimal(10, 0) NULL DEFAULT NULL COMMENT '检测下限值',
  `Unit` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '单位',
  `Status` bit(1) NOT NULL COMMENT '状态: 0 正常 1 删除',
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPDefID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '配置表---控制管子页面是否显示' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epdef
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epsetting`;
CREATE TABLE `cdp_epsetting`  (
  `EPSettingId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPDefId` int NOT NULL COMMENT 'ID',
  `ItemDefID` int NOT NULL COMMENT '物料定义ID',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT '记录时间',
  `ActioLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionUpperLimit` decimal(18, 2) NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '记录修改人ID',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '记录修改时间',
  PRIMARY KEY (`EPSettingId`) USING BTREE,
  INDEX `FK_Reference_14`(`EPDefId` ASC) USING BTREE,
  INDEX `FK_Reference_82`(`ItemDefID` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC, `IsDelete` ASC) USING BTREE,
  CONSTRAINT `cdp_epsetting_ibfk_1` FOREIGN KEY (`EPDefId`) REFERENCES `cdp_epdef` (`EPDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_epsetting_ibfk_2` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '配置表---控制管子页面是否显示，，在线值颜色' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epyaxissetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epyaxissetting`;
CREATE TABLE `cdp_epyaxissetting`  (
  `EPYaxisSettingId` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `UserID` int NULL DEFAULT NULL COMMENT '用户ID',
  `EpDefId` int NULL DEFAULT NULL COMMENT '外键ID',
  `MinY` decimal(18, 2) NULL DEFAULT NULL COMMENT 'Y轴最小值',
  `MaxY` decimal(18, 2) NULL DEFAULT NULL COMMENT 'Y轴最大值',
  `IsDelete` bit(1) NULL DEFAULT NULL,
  `Create_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPYaxisSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '统计图上显示的' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epyaxissetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equipment_calibration_record
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equipment_calibration_record`;
CREATE TABLE `cdp_equipment_calibration_record`  (
  `EquipmentCalibrationRecord` int NOT NULL AUTO_INCREMENT,
  `TestingEquipmentID` int NULL DEFAULT NULL,
  `EquipmentType` int NULL DEFAULT NULL COMMENT '1.Bga 2.Vicell 3.Osmo 4.Cedex',
  `DeviceId` int NULL DEFAULT NULL,
  `Calibration_Time` datetime NOT NULL COMMENT '校准日期',
  `Next_Calibration_Time` datetime NULL DEFAULT NULL COMMENT '下次校准时间',
  `IsDelete` bit(1) NULL DEFAULT NULL,
  `Created_by` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EquipmentCalibrationRecord`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equipment_calibration_record
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equmentscale
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equmentscale`;
CREATE TABLE `cdp_equmentscale`  (
  `ScaleId` int NOT NULL AUTO_INCREMENT,
  `LabId` int NULL DEFAULT NULL,
  `PrincipalId` int NULL DEFAULT NULL,
  `EquipmentNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Model` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Specification` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `IP` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Port` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ErrorCode` bigint NULL DEFAULT NULL,
  `DeviceStatus` int NULL DEFAULT NULL COMMENT '1 空闲中 2 补料中',
  `ScalePrecision` decimal(18, 2) NULL DEFAULT NULL COMMENT '地秤精度',
  `LastUsed_Time` datetime NULL DEFAULT NULL COMMENT '末次使用时间',
  `LastUsed_DeviceId` int NULL DEFAULT NULL COMMENT '末次使用设备',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ScaleId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '库存管理---地秤管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equmentscale
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_events_faulthandlingrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_events_faulthandlingrecord`;
CREATE TABLE `cdp_events_faulthandlingrecord`  (
  `FaultHandlingID` int NOT NULL AUTO_INCREMENT,
  `OperateUnitID` int NULL DEFAULT NULL,
  `HandlingMode` int NULL DEFAULT NULL COMMENT '1：机内处理\r\n   3：机外处理',
  `Status` int NULL DEFAULT NULL COMMENT '1:清空配液站物料\r\n   3:配液站消毒\r\n   5:主体耗材放置入料舱\r\n   7:入料舱消毒\r\n   9:故障处理',
  `HandlingContent` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `HandlingTime` datetime NULL DEFAULT NULL,
  `HandlingUserID` int NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`FaultHandlingID`) USING BTREE,
  INDEX `OperateUnitID`(`OperateUnitID` ASC) USING BTREE,
  CONSTRAINT `cdp_events_faulthandlingrecord_ibfk_1` FOREIGN KEY (`OperateUnitID`) REFERENCES `cdp_operateunit_events` (`OperateUnitID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_events_faulthandlingrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_events_handlingrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_events_handlingrecord`;
CREATE TABLE `cdp_events_handlingrecord`  (
  `HandlingID` int NOT NULL AUTO_INCREMENT,
  `OperateUnitID` int NULL DEFAULT NULL,
  `RootCause` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '根本原因',
  `HandlingContent` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `HandlingResult` int NULL DEFAULT NULL COMMENT ' 1：Retry  （重试，重新执行）   \r\n  3：Go On  (继续，代表本地任务继续执行)\r\n  5：Ignore  (忽略，代表本次任务放弃，通过替代方法完成)\r\n  7：Skip    (代表本地任务不执行)\r\n',
  `HandlingTime` datetime NULL DEFAULT NULL,
  `HandlingUserID` int NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`HandlingID`) USING BTREE,
  INDEX `OperateUnitID`(`OperateUnitID` ASC) USING BTREE,
  CONSTRAINT `cdp_events_handlingrecord_ibfk_1` FOREIGN KEY (`OperateUnitID`) REFERENCES `cdp_operateunit_events` (`OperateUnitID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '主页面----事件' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_events_handlingrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_executeunit_events
-- ----------------------------
DROP TABLE IF EXISTS `cdp_executeunit_events`;
CREATE TABLE `cdp_executeunit_events`  (
  `ExecuteUnitID` int NOT NULL AUTO_INCREMENT,
  `OperateUnitID` int NULL DEFAULT NULL COMMENT 'ID',
  `OPID` int NULL DEFAULT NULL,
  `ActionGroupCode` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DeviceID` int NULL DEFAULT NULL COMMENT '类型',
  `ActionCode` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `EventType` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `EventTime` datetime NULL DEFAULT NULL,
  `EventMessage` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ErrorCode` bigint NULL DEFAULT NULL,
  `ExeParameters` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SubSystemID` int NULL DEFAULT NULL,
  `CabinID` int NULL DEFAULT NULL,
  PRIMARY KEY (`ExecuteUnitID`) USING BTREE,
  INDEX `FK_Reference_110`(`OperateUnitID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_executeunit_events
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_experimentalgroup
-- ----------------------------
DROP TABLE IF EXISTS `cdp_experimentalgroup`;
CREATE TABLE `cdp_experimentalgroup`  (
  `GroupId` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `GroupName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `GroupNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DepartmentId` int NULL DEFAULT NULL,
  `PrincipalId` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`GroupId`) USING BTREE,
  INDEX `fk1`(`PrincipalId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '数据管理---系统设置---实验组' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_experimentalgroup
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_experimentalgroupuser
-- ----------------------------
DROP TABLE IF EXISTS `cdp_experimentalgroupuser`;
CREATE TABLE `cdp_experimentalgroupuser`  (
  `PreBatchUserId` int NOT NULL AUTO_INCREMENT,
  `GroupId` int NOT NULL COMMENT '用户ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`PreBatchUserId`) USING BTREE,
  INDEX `FK_Reference_60`(`GroupId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_GroupID` FOREIGN KEY (`GroupId`) REFERENCES `cdp_experimentalgroup` (`GroupId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '数据管理---系统设置---实验组人员' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_experimentalgroupuser
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_feedingconfig
-- ----------------------------
DROP TABLE IF EXISTS `cdp_feedingconfig`;
CREATE TABLE `cdp_feedingconfig`  (
  `ConfigId` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `ConfigName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '配置名称',
  `IntervalTime` int NOT NULL COMMENT '补料实施执行间隔（s）',
  `SpeedDiff` decimal(18, 2) NOT NULL COMMENT '泵速差值',
  `ExcessPercentage` decimal(18, 2) NOT NULL COMMENT '补料超量百分比',
  `DitherCoefficient` decimal(18, 2) NOT NULL COMMENT '抖动系数',
  `DitherIntervalCoefficient` int NULL DEFAULT NULL COMMENT '抖动环控系数',
  `DitherMonitorTime` int NOT NULL COMMENT '抖动监控时间',
  `JamCoefficient` decimal(18, 2) NOT NULL COMMENT '堵塞系数',
  `JamIntervalCoefficient` int NOT NULL COMMENT '堵塞环控系数',
  `RebateCoefficient` decimal(18, 2) NOT NULL COMMENT '返水系数',
  `RebateIntervalCoefficient` int NOT NULL COMMENT '返水监控时间系数',
  `IsDelete` bit(1) NULL DEFAULT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`ConfigId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料配置---一条数据--写死的' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_feedingconfig
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_fixedfeedingtask_execdetail
-- ----------------------------
DROP TABLE IF EXISTS `cdp_fixedfeedingtask_execdetail`;
CREATE TABLE `cdp_fixedfeedingtask_execdetail`  (
  `ExecDetailID` int NOT NULL AUTO_INCREMENT COMMENT '执行主键',
  `TaskID` int NOT NULL COMMENT '关联任务id',
  `TaskNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '关联任务no',
  `CheckTime` datetime NOT NULL COMMENT '检测时间',
  `ExecTime` int NOT NULL COMMENT '已经持续时间',
  `Step` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '阶段',
  `CurrentSpeed` decimal(18, 4) NOT NULL COMMENT '当前速度',
  `SetSpeed` decimal(18, 4) NULL DEFAULT NULL COMMENT '当前设定速度',
  `Exenumber` decimal(18, 4) NOT NULL COMMENT '已完成量（g）',
  `ReactorWeight` decimal(18, 4) NOT NULL COMMENT '反应器重量（g）',
  `FeedingScaleWeight` decimal(18, 4) NOT NULL COMMENT '补料地秤重量（g）',
  `IsFeeding` bit(1) NULL DEFAULT NULL COMMENT '是否在补料中，0否 null和1是',
  `DBTime` datetime NOT NULL COMMENT '数据库记录时间',
  PRIMARY KEY (`ExecDetailID`) USING BTREE,
  INDEX `TaskID`(`TaskID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '主页---补料任务--处理错误' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_fixedfeedingtask_execdetail
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_fixedfeedingtask_speedset
-- ----------------------------
DROP TABLE IF EXISTS `cdp_fixedfeedingtask_speedset`;
CREATE TABLE `cdp_fixedfeedingtask_speedset`  (
  `SpeedSetID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `TaskID` int NOT NULL COMMENT '关联任务id',
  `TaskNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '关联任务no',
  `SetTime` datetime NOT NULL COMMENT '设置时间',
  `PumpNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '泵的编号',
  `Step` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '阶段名称',
  `Speed` decimal(18, 4) NOT NULL COMMENT '下发速度',
  `IsSuccess` bit(1) NOT NULL COMMENT '是否成功 0否1是',
  `DBTime` datetime NOT NULL COMMENT '数据库时间',
  PRIMARY KEY (`SpeedSetID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '主页--默认链接---配置泵速' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_fixedfeedingtask_speedset
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_global_setting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_global_setting`;
CREATE TABLE `cdp_global_setting`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KeyVal` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '关键字',
  `Val` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '值',
  `Description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '描述',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0' COMMENT '删除标识',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '更新人',
  `Last_update_time` datetime NOT NULL COMMENT '更新时间',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统全局设置表---提醒密码到期' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_global_setting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_iot_dataprocessing
-- ----------------------------
DROP TABLE IF EXISTS `cdp_iot_dataprocessing`;
CREATE TABLE `cdp_iot_dataprocessing`  (
  `TaskId` int NOT NULL AUTO_INCREMENT,
  `BatchId` int NOT NULL,
  `Status` int NOT NULL COMMENT '1.待执行 3.执行中 5.已执行 ',
  `CreatedTime` datetime NOT NULL,
  `UpdatedTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TaskId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_iot_dataprocessing
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_alarmsettings
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_alarmsettings`;
CREATE TABLE `cdp_item_alarmsettings`  (
  `AlarmSettingID` int NOT NULL AUTO_INCREMENT,
  `ItemDefID` int NULL DEFAULT NULL,
  `SettingType` int NOT NULL COMMENT '物料类型:\r\n            1: Material Configuration\r\n            3: Liquid Configuration\r\n            5: Large Liquid Configuration(Sampling)\r\n            7: Large Liquid Configuration(Pumping)',
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '位置组合ID',
  `NormalQuantity` decimal(18, 2) NOT NULL DEFAULT 0.00,
  `DefaultAlarmQuantity` decimal(18, 2) NOT NULL DEFAULT 0.00,
  `AlarmQuantity` decimal(18, 2) NOT NULL DEFAULT 0.00,
  `Operator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`AlarmSettingID`) USING BTREE,
  INDEX `FK_Reference_56`(`LocCombinationID` ASC) USING BTREE,
  INDEX `FK_Reference_57`(`ItemDefID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '库存系统报警设定' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_alarmsettings
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_def
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_def`;
CREATE TABLE `cdp_item_def`  (
  `ItemDefID` int NOT NULL AUTO_INCREMENT COMMENT '物料定义ID',
  `ItemCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '物料定义Code',
  `ItemDescription` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '物料名称',
  `ItemCategory` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '物料类型：\r\n1、LIQUID：液体\r\n2、BIGLIQUID：大液\r\n3、REACTOR：堆？\r\n4、BARCODE：标签？\r\n5、MEDIUM：媒介\r\n10、CITEM：\r\n12、ECITEM\r\n14、LID：盖子\r\n15、PLATE：盘子',
  `UOM` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '计量单位',
  `Capacity` int NULL DEFAULT NULL COMMENT '物料容量',
  `CapacityUOM` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '容量单位',
  `MaterialIcon` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '物料icon链接',
  `Brand` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '品牌',
  `LidItemDefID` int NULL DEFAULT NULL COMMENT '盖子ItemDefID',
  `LidStatus` bit(1) NULL DEFAULT NULL COMMENT '盖子状态:\r\n            null 非盖子\r\n            0 关闭\r\n            1 打开',
  `MapItemDefID` int NULL DEFAULT NULL COMMENT '容器ItemDefID',
  `MapCarriedItemDefID` int NULL DEFAULT NULL COMMENT '容器内液体ItemDefID',
  `MapCarriedItemQuantity` int NULL DEFAULT NULL COMMENT '容器内液量',
  `DefaultCarriedQuantity` decimal(18, 2) NULL DEFAULT NULL COMMENT '默认液量',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `LiquidType` int NULL DEFAULT NULL COMMENT '液体类型\r\n1：大补料\r\n3：小补料\r\n5：糖补料\r\n7：用户可自定义增加\r\n',
  `GlucoseConc` decimal(18, 2) NULL DEFAULT NULL COMMENT '糖浓度',
  `IsSystemDef` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否系统级定义',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemDefID`) USING BTREE,
  INDEX ```ItemCode```(`ItemCode` ASC) USING BTREE,
  INDEX ```ItemCategory```(`ItemCategory` ASC) USING BTREE,
  INDEX `ItemDefID`(`ItemDefID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '物料定义表   --主页---物料详细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_def
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_serials
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_serials`;
CREATE TABLE `cdp_item_serials`  (
  `ItemID` int NOT NULL AUTO_INCREMENT COMMENT '物料明细ID',
  `ItemSerialNumber` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '实时物料编号',
  `ItemDefID` int NOT NULL COMMENT '物料定义ID',
  `LocCombinationID` int NOT NULL COMMENT '物料位置ID',
  `CatNO` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LotNO` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `BeginTime` datetime NULL DEFAULT NULL COMMENT '开始使用时间',
  `PlateSlotID` int NULL DEFAULT NULL COMMENT '托盘明细ID',
  `CarriedItemDefID` int NULL DEFAULT NULL COMMENT '内部携带物料ID',
  `Quantity` decimal(18, 2) NULL DEFAULT NULL COMMENT '内部液体余量',
  `LidStatus` bit(1) NULL DEFAULT NULL COMMENT '盖子状态:\r\n            null 非盖子\r\n            0 关闭\r\n            1 打开',
  `LastMoveTime` datetime NULL DEFAULT NULL COMMENT '最后移动时间',
  `ItemStatus` int NOT NULL DEFAULT 0 COMMENT '物料状态:\r\n0 Normal：没有在使用的正常物料\r\n2 Using：正在使用的物料\r\n4  TestVicell\r\n6  TestOsmo\r\n8  TestCedex\r\n10  TestCentrifuge\r\n12  TestCentrifugeDone\r\n14  TestNeedVicell\r\n20 Used\r\n22 Harversting正在收获\r\n24 Harversted收获完成\r\n26 Disable：被禁用的物料\r\n28 Discard：用光被丢出的物料\r\n30 Product：完成标记\r\n\r\n\r\n            ',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次id',
  `ExtraData` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '物料状态:\r\n            0 Normal：没有在使用的正常物料\r\n            2 Using：正在使用的物料\r\n            4 Used\r\n        6 Harversting正在收获\r\n        8 Harversted收获完成\r\n            10 Disable：被禁用的物料\r\n            12 Discard：用光被丢出的物料\r\n            14 Product：完成标记\r\n\r\n20  TestVicell\r\n22  TestOsmo\r\n24  TestCedex\r\n26  TestCentrifuge\r\n28  TestCentrifugeDone\r\n30  TestNeedVicell\r\n\r\n\r\n\r\n\r\n30  TestNeedVicell\r\n\r\n            ',
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemID`) USING BTREE,
  INDEX `FK_Reference_1`(`ItemDefID` ASC) USING BTREE,
  INDEX `FK_Reference_12`(`CarriedItemDefID` ASC) USING BTREE,
  INDEX `FK_Reference_9`(`LocCombinationID` ASC) USING BTREE,
  INDEX `BatchId`(`BatchId` ASC) USING BTREE,
  INDEX `PlateSlotID`(`PlateSlotID` ASC) USING BTREE,
  INDEX ```ItemSerialNumber```(`ItemSerialNumber` ASC) USING BTREE,
  INDEX `ItemStatus`(`ItemStatus` ASC) USING BTREE,
  CONSTRAINT `cdp_item_serials_ibfk_1` FOREIGN KEY (`BatchId`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_item_serials_ibfk_2` FOREIGN KEY (`PlateSlotID`) REFERENCES `cdp_plate_slots` (`PlateSlotID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_1` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_12` FOREIGN KEY (`CarriedItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '调度表，每几秒轮询一次' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_serials
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_transaction
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_transaction`;
CREATE TABLE `cdp_item_transaction`  (
  `ItemTransactionID` int NOT NULL AUTO_INCREMENT COMMENT '物料事务ID',
  `ItemTransactionType` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemTransactionID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_transaction
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_transaction_details
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_transaction_details`;
CREATE TABLE `cdp_item_transaction_details`  (
  `ItemTransactionDetailID` int NOT NULL AUTO_INCREMENT,
  `ItemTransactionID` int NOT NULL,
  `ItemID` int NOT NULL,
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '储位组合ID',
  `PlateSlotID` int NULL DEFAULT NULL COMMENT '托盘托位ID',
  `CarriedItemID` int NULL DEFAULT NULL,
  `Quantity` int NULL DEFAULT NULL,
  `LidStatus` bit(1) NOT NULL COMMENT '盖子状态:\r\n            null 非盖子\r\n            0 关闭\r\n            1 打开',
  `ItemStatus` int NOT NULL COMMENT '物料状态:\r\n            0 Normal：没有在使用的正常物料\r\n            2 Using：正在使用的物料\r\n            4 Disable：被禁用的物料\r\n            6 Discard：用光被丢出的物料\r\n            8 Product：完成标记\r\n            ',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemTransactionDetailID`) USING BTREE,
  INDEX `FK_ACM_TRANSDETAIL_REF_HEADER`(`ItemTransactionID` ASC) USING BTREE,
  INDEX `FK_Reference_56`(`ItemID` ASC) USING BTREE,
  INDEX `FK_Reference_57`(`LocCombinationID` ASC) USING BTREE,
  INDEX `FK_Reference_58`(`PlateSlotID` ASC) USING BTREE,
  CONSTRAINT `FK_ACM_TRANSDETAIL_REF_HEADER` FOREIGN KEY (`ItemTransactionID`) REFERENCES `cdp_item_transaction` (`ItemTransactionID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_56` FOREIGN KEY (`ItemID`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_57` FOREIGN KEY (`LocCombinationID`) REFERENCES `cdp_location_combinations` (`LocCombinationID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_58` FOREIGN KEY (`PlateSlotID`) REFERENCES `cdp_plate_slots` (`PlateSlotID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_transaction_details
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_lab
-- ----------------------------
DROP TABLE IF EXISTS `cdp_lab`;
CREATE TABLE `cdp_lab`  (
  `LabID` int NOT NULL AUTO_INCREMENT COMMENT '机器ID',
  `LabNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '实验室编号',
  `LabName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '实验室名称',
  `LabKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `LabSecret` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `DepartmentId` int NULL DEFAULT NULL,
  PRIMARY KEY (`LabID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '机器定义表 ---实验室配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_lab
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_lab_sakula
-- ----------------------------
DROP TABLE IF EXISTS `cdp_lab_sakula`;
CREATE TABLE `cdp_lab_sakula`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Algerbra` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `Kangar` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用   加密系统' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_lab_sakula
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_labarea
-- ----------------------------
DROP TABLE IF EXISTS `cdp_labarea`;
CREATE TABLE `cdp_labarea`  (
  `LabAreaID` int NOT NULL AUTO_INCREMENT COMMENT '机器仓ID',
  `LabID` int NULL DEFAULT NULL COMMENT '机器ID',
  `LabAreaNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '实验室区域编号',
  `LabAreaName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '实验室区域名称',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LabAreaID`) USING BTREE,
  INDEX `FK_Reference_46`(`LabID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_46` FOREIGN KEY (`LabID`) REFERENCES `cdp_lab` (`LabID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '机器仓定义表（主页----机械区域）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_labarea
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_labcabin
-- ----------------------------
DROP TABLE IF EXISTS `cdp_labcabin`;
CREATE TABLE `cdp_labcabin`  (
  `LabCabinID` int NOT NULL AUTO_INCREMENT COMMENT '机器仓ID',
  `LabCabinNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '机器仓编号',
  `LabCabinName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '机器仓名称',
  `LabId` int NULL DEFAULT NULL COMMENT '房间Id',
  `DisplaySequence` int NULL DEFAULT NULL COMMENT '排序号',
  `Status` bit(1) NOT NULL DEFAULT b'1' COMMENT '启用状态',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0' COMMENT '0 未删除\r\n            1 已删除',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LabCabinID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_labcabin
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_labdevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_labdevice`;
CREATE TABLE `cdp_labdevice`  (
  `LabDeviceID` int NOT NULL AUTO_INCREMENT COMMENT '设备ID',
  `LabAreaID` int NULL DEFAULT NULL COMMENT '机器仓ID',
  `LabCabinID` int NULL DEFAULT NULL COMMENT '机器仓ID',
  `LabDeviceNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '设备编号',
  `LabDeviceName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '设备名称',
  `LabDeviceType` int NULL DEFAULT NULL COMMENT '1 罐子\r\n3 取样单元\r\n5 补料单元\r\n7 检测仪器 BGA\r\n9 检测仪器 OSMO\r\n11 检测仪器 Vicell\r\n13 检测仪器 Cedex',
  `IsMaterialImport` bit(1) NULL DEFAULT NULL COMMENT '是否上料位',
  `ScaleId` int NULL DEFAULT NULL COMMENT '地秤ID',
  `Remake` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '备注信息',
  `DeviceStatus` int NULL DEFAULT NULL COMMENT '0:Offline;1:Idle;2:Busy;3:Error',
  `ErrorCode` bigint NULL DEFAULT NULL,
  `DisplaySequence` int NULL DEFAULT NULL COMMENT '显示排序',
  `CurrentLocCombinationID` int NULL DEFAULT NULL COMMENT '夹爪当前所在位置',
  `EquipmentID` int NULL DEFAULT NULL COMMENT '检测设备Id',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LabDeviceID`) USING BTREE,
  INDEX `CurrentLocCombinationID`(`CurrentLocCombinationID` ASC) USING BTREE,
  INDEX `FK_Reference_102`(`LabCabinID` ASC) USING BTREE,
  INDEX `FK_Reference_47`(`LabAreaID` ASC) USING BTREE,
  INDEX ```LabDeviceName```(`LabDeviceName` ASC) USING BTREE,
  INDEX `LabDeviceType`(`LabDeviceType` ASC) USING BTREE,
  INDEX `DeviceStatus`(`DeviceStatus` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC, `IsDelete` ASC) USING BTREE,
  CONSTRAINT `cdp_machinedevice_ibfk_1` FOREIGN KEY (`CurrentLocCombinationID`) REFERENCES `cdp_location_combinations` (`LocCombinationID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_102` FOREIGN KEY (`LabCabinID`) REFERENCES `cdp_labcabin` (`LabCabinID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_47` FOREIGN KEY (`LabAreaID`) REFERENCES `cdp_labarea` (`LabAreaID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '设备定义表（物料系统设备--主页）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_labdevice
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_labdevicesub
-- ----------------------------
DROP TABLE IF EXISTS `cdp_labdevicesub`;
CREATE TABLE `cdp_labdevicesub`  (
  `LabDeviceSubID` int NOT NULL AUTO_INCREMENT,
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `LabDeviceSubNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '子设备编号',
  `LabDeviceSubName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '子设备名称',
  `ErrorCode` bigint NULL DEFAULT NULL,
  `DeviceSubStatus` int NULL DEFAULT NULL COMMENT '0:Offline;1:Idle;2:Busy;3:Error',
  `DisplaySequence` int NULL DEFAULT NULL COMMENT '显示排序',
  `StorageType` int NULL DEFAULT NULL COMMENT '0非存储设备, 1耗材存储设备, 2大料存储设备',
  `DefaultSpeed` decimal(18, 5) NULL DEFAULT NULL COMMENT '默认速度',
  `MaxSpeed` decimal(18, 5) NULL DEFAULT NULL COMMENT '最大速度',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LabDeviceSubID`) USING BTREE,
  INDEX `FK_Reference_48`(`LabDeviceID` ASC) USING BTREE,
  INDEX ```LabDeviceSubName```(`LabDeviceSubName` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_48` FOREIGN KEY (`LabDeviceID`) REFERENCES `cdp_labdevice` (`LabDeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '设备定义表（物料系统设备--主页）子设备' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_labdevicesub
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_labdevicesubloc
-- ----------------------------
DROP TABLE IF EXISTS `cdp_labdevicesubloc`;
CREATE TABLE `cdp_labdevicesubloc`  (
  `LabDeviceSubLocID` int NOT NULL AUTO_INCREMENT COMMENT '设备存储位ID',
  `LabDeviceSubID` int NULL DEFAULT NULL COMMENT '子设备id',
  `LabDeviceSubLocCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '设备存储位编号',
  `DisplaySequence` int NOT NULL DEFAULT 1 COMMENT '外显排序',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LabDeviceSubLocID`) USING BTREE,
  INDEX `LabDeviceSubID`(`LabDeviceSubID` ASC, `LabDeviceSubLocCode` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '子设备---位置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_labdevicesubloc
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_location_combinations
-- ----------------------------
DROP TABLE IF EXISTS `cdp_location_combinations`;
CREATE TABLE `cdp_location_combinations`  (
  `LocCombinationID` int NOT NULL AUTO_INCREMENT COMMENT '位置ID',
  `LabID` int NULL DEFAULT NULL COMMENT '实验室ID',
  `LabCabinID` int NULL DEFAULT NULL COMMENT '机器仓ID',
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `LabDeviceSubID` int NULL DEFAULT NULL COMMENT '子设备id',
  `LabDeviceSubLocID` int NULL DEFAULT NULL,
  `LocationCode` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '位置code',
  `IsEmpty` bit(1) NOT NULL DEFAULT b'1' COMMENT '是否为空 0否1是',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LocCombinationID`) USING BTREE,
  INDEX `FK_Reference_101`(`LabCabinID` ASC) USING BTREE,
  INDEX `FK_Reference_49`(`LabID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX ```LabDeviceID```(`LabDeviceID` ASC) USING BTREE,
  INDEX `LocationCode`(`LocationCode` ASC) USING BTREE,
  INDEX `LocCombinationID`(`LocCombinationID` ASC) USING BTREE,
  INDEX `LabDeviceSubID`(`LabDeviceSubID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_101` FOREIGN KEY (`LabCabinID`) REFERENCES `cdp_labcabin` (`LabCabinID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_49` FOREIGN KEY (`LabID`) REFERENCES `cdp_lab` (`LabID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '位置定义表   记录所有位置---有唯一编号\r\n所有设备的状态' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_location_combinations
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_location_controls
-- ----------------------------
DROP TABLE IF EXISTS `cdp_location_controls`;
CREATE TABLE `cdp_location_controls`  (
  `LocationControlsID` int NOT NULL AUTO_INCREMENT,
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '位置ID',
  `ControlType` int NULL DEFAULT NULL COMMENT '1:位置上的物料 3.位置上的物料装载物',
  `ItemDefID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LocationControlsID`) USING BTREE,
  INDEX `FK_Reference_52`(`LocCombinationID` ASC) USING BTREE,
  INDEX `FK_Reference_99`(`ItemDefID` ASC) USING BTREE,
  INDEX ```ControlType```(`ControlType` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  INDEX `IsDelete`(`IsDelete` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_99` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '位置物料控制定义表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_location_controls
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_machinemodeswitchrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_machinemodeswitchrecord`;
CREATE TABLE `cdp_machinemodeswitchrecord`  (
  `ModeSwitchRecordId` int NOT NULL AUTO_INCREMENT COMMENT '机器ID',
  `LabID` int NULL DEFAULT NULL COMMENT '机器ID',
  `SwitchCase` int NULL DEFAULT NULL COMMENT '1. Manual->Automatic\r\n               3. Automatic->Manual',
  `SwitchTime` datetime NULL DEFAULT NULL COMMENT '软件版本',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ModeSwitchRecordId`) USING BTREE,
  INDEX `FK_Reference_54`(`LabID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_54` FOREIGN KEY (`LabID`) REFERENCES `cdp_lab` (`LabID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '手自动切换记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_machinemodeswitchrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_manualop_detail_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_manualop_detail_rec`;
CREATE TABLE `cdp_manualop_detail_rec`  (
  `ManualOPRecDetailID` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `ManualOPRecID` int NOT NULL,
  `Weight` decimal(18, 2) NULL DEFAULT NULL COMMENT '重量',
  `PumpedTime` datetime NULL DEFAULT NULL COMMENT '补料时间',
  `Speed` int NULL DEFAULT NULL COMMENT '实时泵速',
  `CurrentScaleValue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '地秤当前读数',
  `PumpCalculation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '泵计算量',
  PRIMARY KEY (`ManualOPRecDetailID`) USING BTREE,
  INDEX `ManualOPRecDetailID`(`ManualOPRecDetailID` ASC) USING BTREE,
  INDEX ```Weight```(`Weight` ASC) USING BTREE,
  INDEX ```ManualOPRecID```(`ManualOPRecID` ASC) USING BTREE,
  INDEX `PumpedTime`(`PumpedTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '1期--手动补料明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_manualop_detail_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_manualop_parmeter
-- ----------------------------
DROP TABLE IF EXISTS `cdp_manualop_parmeter`;
CREATE TABLE `cdp_manualop_parmeter`  (
  `ManualOPParmeterID` int NOT NULL AUTO_INCREMENT,
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `OperationType` int NOT NULL COMMENT '1.Rinse\r\n   3.Sampling\r\n   5.Disinfection\r\n   11.PumpingFM1\r\n   13.PumpingFM2\r\n   15.PumpingGlucose\r\n   17.PumpingFM3',
  `PumpingType` int NULL DEFAULT NULL COMMENT 'null : Sampling\r\n1.大补料\r\n3.小补料\r\n5.糖补料\r\n7.其他补料',
  `DefaultParameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '执行参数',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ManualOPParmeterID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统控制----补料---补料泵速' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_manualop_parmeter
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_manualop_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_manualop_rec`;
CREATE TABLE `cdp_manualop_rec`  (
  `ManualOPRecID` int NOT NULL AUTO_INCREMENT,
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `OperationType` int NOT NULL COMMENT '1.Rinse\r\n   3.Sampling\r\n   5.Disinfection\r\n   11.PumpingFM1\r\n   13.PumpingFM2\r\n   15.PumpingGlucose\r\n   17.PumpingFM3',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `ErrorCode` bigint NULL DEFAULT NULL COMMENT '错误码',
  `ExecParameters` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '执行参数',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Weight` decimal(18, 2) NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '1:开始\r\n3:结束\r\n99:取消',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `LocCombinationID` int NULL DEFAULT NULL COMMENT '位置',
  PRIMARY KEY (`ManualOPRecID`) USING BTREE,
  INDEX `FK_Reference_94`(`LabDeviceID` ASC) USING BTREE,
  INDEX `FK_Reference_95`(`BatchID` ASC) USING BTREE,
  INDEX `ManualOPRecID`(`ManualOPRecID` ASC) USING BTREE,
  INDEX ```OperationType```(`OperationType` ASC) USING BTREE,
  INDEX ```LocCombinationID```(`LocCombinationID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '手动补料任务表----任务下面每几秒的数据' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_manualop_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_material
-- ----------------------------
DROP TABLE IF EXISTS `cdp_material`;
CREATE TABLE `cdp_material`  (
  `MaterialId` int NOT NULL AUTO_INCREMENT,
  `Category` int NOT NULL COMMENT '1.Fed-Batch 3.Harvest 5.LoadSample',
  `LabId` int NULL DEFAULT NULL COMMENT '哪个实验室',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`MaterialId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---耗材设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_material
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_materialdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_materialdtl`;
CREATE TABLE `cdp_materialdtl`  (
  `MaterialDtlId` int NOT NULL AUTO_INCREMENT,
  `MaterialId` int NOT NULL COMMENT '主表Id',
  `Category` int NULL DEFAULT NULL COMMENT '1.Bga 3.Vicell 5.Osmo 7.Cedex 9.Reserved Sample ',
  `Type` int NULL DEFAULT NULL COMMENT '1.耗材 3.共享',
  `Item` int NULL DEFAULT NULL COMMENT '具体物件名称：Item_Def Cate=CITEM',
  `Quantity` int NULL DEFAULT NULL COMMENT '数量',
  `IsDilution` bit(1) NULL DEFAULT NULL COMMENT '是否稀释',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`MaterialDtlId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---耗材设置详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_materialdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_notification
-- ----------------------------
DROP TABLE IF EXISTS `cdp_notification`;
CREATE TABLE `cdp_notification`  (
  `NotificationId` int NOT NULL AUTO_INCREMENT,
  `LabID` int NULL DEFAULT NULL COMMENT '机器ID',
  `Title` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NotificationContent` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Link` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Parameter` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `NotificationTime` datetime NOT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'0',
  `UserId` int NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`NotificationId`) USING BTREE,
  INDEX `FK_Reference_53`(`LabID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_53` FOREIGN KEY (`LabID`) REFERENCES `cdp_lab` (`LabID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_notification
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_op_definition
-- ----------------------------
DROP TABLE IF EXISTS `cdp_op_definition`;
CREATE TABLE `cdp_op_definition`  (
  `OPID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `Code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OPType` int NULL DEFAULT NULL COMMENT '0:Manuafacture; 1: Motion',
  `Icon` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SequenceNumber` int NOT NULL DEFAULT 1,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OPID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '任务队列---检测任务的下拉框' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_op_definition
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_op_definitionsub
-- ----------------------------
DROP TABLE IF EXISTS `cdp_op_definitionsub`;
CREATE TABLE `cdp_op_definitionsub`  (
  `OPSubID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `OPID` int NOT NULL,
  `Code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OPType` int NULL DEFAULT NULL COMMENT '0:Hide; 1: Show',
  `Icon` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SequenceNumber` int NOT NULL DEFAULT 1,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OPSubID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '任务队列---检测任务的下拉框值' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_op_definitionsub
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_op_defparameter
-- ----------------------------
DROP TABLE IF EXISTS `cdp_op_defparameter`;
CREATE TABLE `cdp_op_defparameter`  (
  `OPParameterID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `OPSubID` int NULL DEFAULT NULL COMMENT 'ID',
  `ParameterID` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '?????',
  `SequenceNumber` int NOT NULL COMMENT '???',
  `IsHidden` bit(1) NULL DEFAULT b'0',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OPParameterID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '任务队列---检测任务的下拉框选项' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_op_defparameter
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_op_parameter
-- ----------------------------
DROP TABLE IF EXISTS `cdp_op_parameter`;
CREATE TABLE `cdp_op_parameter`  (
  `ParameterID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `Name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '名称',
  `Description` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Unit` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '单位',
  `Type` tinyint NULL DEFAULT NULL COMMENT '类型0:Enum;1:int;2:String;3:Boolean;4:Button',
  `DefaultValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '默认值',
  `MinValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '最小值',
  `MaxValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '最大值',
  `Status` bit(1) NOT NULL DEFAULT b'0' COMMENT '状态: 1 正常 0删除',
  `SequenceNumber` int NOT NULL DEFAULT 1,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ParameterID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '任务队列---检测任务---反应器的配置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_op_parameter
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_op_parameter_value
-- ----------------------------
DROP TABLE IF EXISTS `cdp_op_parameter_value`;
CREATE TABLE `cdp_op_parameter_value`  (
  `ParameterValueId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `ParameterID` int NULL DEFAULT NULL COMMENT 'ID',
  `ParameterValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ParameterValueName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SubParameterID` int NULL DEFAULT NULL,
  `SequenceNumber` int NOT NULL DEFAULT 1,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ParameterValueId`) USING BTREE,
  INDEX `ParameterID`(`ParameterID` ASC) USING BTREE,
  CONSTRAINT `cdp_op_parameter_value_ibfk_1` FOREIGN KEY (`ParameterID`) REFERENCES `cdp_op_parameter` (`ParameterID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '任务队列---检测任务---反应器的配置值' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_op_parameter_value
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_op_parametersub
-- ----------------------------
DROP TABLE IF EXISTS `cdp_op_parametersub`;
CREATE TABLE `cdp_op_parametersub`  (
  `ParameterSubID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `ParameterID` int NOT NULL,
  `TestingNo` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '编号',
  `Name` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '名称',
  `Description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '描述',
  `DefaultTopValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '稀释分子值',
  `DefaultBottomValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '稀释分母值',
  `Unit` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '单位',
  `Status` bit(1) NOT NULL DEFAULT b'1' COMMENT '状态: 1 正常 0删除',
  `SequenceNumber` int NOT NULL DEFAULT 1 COMMENT '序号',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ParameterSubID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '任务队列---检测任务---反应器----检测设备---检测设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_op_parametersub
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_operateunit_events
-- ----------------------------
DROP TABLE IF EXISTS `cdp_operateunit_events`;
CREATE TABLE `cdp_operateunit_events`  (
  `OperateUnitID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `LabId` int NULL DEFAULT NULL,
  `OperateMode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SourceID` int NULL DEFAULT NULL,
  `OperateType` int NULL DEFAULT NULL COMMENT 'ACM_Sys_Reference.EnumValue',
  `ParentOperateUnitID` int NULL DEFAULT NULL,
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `EventType` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `EventTime` datetime NULL DEFAULT NULL,
  `EventMessage` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ErrorCode` bigint NULL DEFAULT NULL,
  `Status` int NULL DEFAULT 0 COMMENT 'int(0:New;1:Handled;9:Reexec Fail;11:Reexec Successful)',
  `BatchId` int NULL DEFAULT NULL,
  `ExeParameters` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CabinId` int NULL DEFAULT NULL,
  `Solution` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  PRIMARY KEY (`OperateUnitID`) USING BTREE,
  INDEX ```BatchId```(`BatchId` ASC) USING BTREE,
  INDEX ```ErrorCode```(`ErrorCode` ASC) USING BTREE,
  INDEX ```EventType```(`EventType` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX `SourceID`(`SourceID` ASC) USING BTREE,
  INDEX `StartTime`(`StartTime` ASC) USING BTREE,
  INDEX `OperateType`(`OperateType` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '首页---事件---手动自动化日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_operateunit_events
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_perfusionfeedingrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_perfusionfeedingrecord`;
CREATE TABLE `cdp_perfusionfeedingrecord`  (
  `PerfusionId` int NOT NULL AUTO_INCREMENT,
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '反应器设备Id',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次号',
  `BatchCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '批次Code',
  `FeedingLiquid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '液体No',
  `PumpNo` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '泵号',
  `ReactorName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '反应器名称',
  `AddAmount` decimal(10, 2) NULL DEFAULT NULL COMMENT '补多少计量',
  `DoseDuration` decimal(10, 2) NULL DEFAULT NULL COMMENT '每一次持续多少时间min',
  `DelayTime` int NULL DEFAULT NULL COMMENT '延迟时间',
  `NumberOfCycles` int NULL DEFAULT NULL COMMENT '轮询次数',
  `Flow` decimal(10, 0) NULL DEFAULT NULL COMMENT '速度',
  `Creation_time` datetime NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  PRIMARY KEY (`PerfusionId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '罐流的补料任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_perfusionfeedingrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_plate_slots
-- ----------------------------
DROP TABLE IF EXISTS `cdp_plate_slots`;
CREATE TABLE `cdp_plate_slots`  (
  `PlateSlotID` int NOT NULL AUTO_INCREMENT COMMENT '托盘明细ID',
  `ItemID` int NULL DEFAULT NULL COMMENT '物料明细ID',
  `SlotDefID` int NULL DEFAULT NULL COMMENT '托盘定义ID',
  `IsEmpty` bit(1) NOT NULL DEFAULT b'1',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`PlateSlotID`) USING BTREE,
  INDEX `FK_Reference_55`(`ItemID` ASC) USING BTREE,
  INDEX `SlotDefID`(`SlotDefID` ASC) USING BTREE,
  INDEX `IsEmpty`(`IsEmpty` ASC) USING BTREE,
  CONSTRAINT `cdp_plate_slots_ibfk_1` FOREIGN KEY (`SlotDefID`) REFERENCES `cdp_plateslot_def` (`SlotDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_plate_slots_ibfk_2` FOREIGN KEY (`ItemID`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '和cdp_location_combinations有管' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_plate_slots
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_plateslot_controls
-- ----------------------------
DROP TABLE IF EXISTS `cdp_plateslot_controls`;
CREATE TABLE `cdp_plateslot_controls`  (
  `SlotControlID` int NOT NULL AUTO_INCREMENT,
  `SlotDefID` int NULL DEFAULT NULL COMMENT '托盘定义ID',
  `ItemDefID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`SlotControlID`) USING BTREE,
  INDEX `FK_Reference_98`(`ItemDefID` ASC) USING BTREE,
  INDEX `SlotDefID`(`SlotDefID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_44` FOREIGN KEY (`SlotDefID`) REFERENCES `cdp_plateslot_def` (`SlotDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_98` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '托盘位置可控制表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_plateslot_controls
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_plateslot_def
-- ----------------------------
DROP TABLE IF EXISTS `cdp_plateslot_def`;
CREATE TABLE `cdp_plateslot_def`  (
  `SlotDefID` int NOT NULL AUTO_INCREMENT COMMENT '托盘/架定义ID',
  `ItemDefID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `PlateSlotItemDefID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `SlotDefCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '托盘/架定义code',
  `ColCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '行标识',
  `RowCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '列标识',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`SlotDefID`) USING BTREE,
  INDEX `FK_Reference_82`(`ItemDefID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '和cdp_location_combinations有管' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_plateslot_def
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_print_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_print_rec`;
CREATE TABLE `cdp_print_rec`  (
  `PrintRecID` int NOT NULL AUTO_INCREMENT,
  `ItemDefID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `ItemBarcode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '物料号',
  `ItemMaterial` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '物料名称',
  `PrintUser` int NULL DEFAULT NULL COMMENT '打印人',
  `PrintTime` datetime NULL DEFAULT NULL COMMENT '打印时间',
  PRIMARY KEY (`PrintRecID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '打印的表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_print_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_revokereason
-- ----------------------------
DROP TABLE IF EXISTS `cdp_revokereason`;
CREATE TABLE `cdp_revokereason`  (
  `RevokeReasonID` int NOT NULL AUTO_INCREMENT COMMENT '撤回原因ID',
  `RevokeReason` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '撤回原因',
  `RevokeType` int NOT NULL COMMENT '撤回类型\r\n1. BGA 上传撤回\r\n3. OSMO 上传撤回\r\n5. Vivell 上传撤回\r\n7. Cedex 上传撤回\r\n9 签名撤回\r\n11 审核撤回',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`RevokeReasonID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统配置---撤销原因表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_revokereason
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_startqueue
-- ----------------------------
DROP TABLE IF EXISTS `cdp_startqueue`;
CREATE TABLE `cdp_startqueue`  (
  `StartQueueID` int NOT NULL AUTO_INCREMENT,
  `LabDeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `ItemDefID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `RinseVolume` decimal(18, 2) NOT NULL,
  `Disinfectant` decimal(18, 2) NOT NULL,
  `TargetViableCellNumber` decimal(18, 2) NOT NULL COMMENT '孔位ItemID',
  `InitialMediumVolume` decimal(18, 2) NOT NULL,
  `InitialMediumTEMP` decimal(18, 2) NOT NULL,
  `InitialMediumLotNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `CellType` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InitialCellVolume` decimal(18, 2) NULL DEFAULT NULL,
  `InitialVCD` decimal(18, 2) NULL DEFAULT NULL,
  `InitialCellLotNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Status` int NULL DEFAULT 3 COMMENT '1.Not Started\r\n3.Started\r\n5.Canceled',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`StartQueueID`) USING BTREE,
  INDEX `LabDeviceID`(`LabDeviceID` ASC) USING BTREE,
  INDEX `ItemDefID`(`ItemDefID` ASC) USING BTREE,
  INDEX `BatchID`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `cdp_startqueue_ibfk_1` FOREIGN KEY (`LabDeviceID`) REFERENCES `cdp_labdevice` (`LabDeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_startqueue_ibfk_2` FOREIGN KEY (`ItemDefID`) REFERENCES `cdp_item_def` (`ItemDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_startqueue_ibfk_3` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_startqueue
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_sys_reference
-- ----------------------------
DROP TABLE IF EXISTS `cdp_sys_reference`;
CREATE TABLE `cdp_sys_reference`  (
  `ReferenceId` int NOT NULL AUTO_INCREMENT,
  `TableName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ColumnName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `EnumValue` int NULL DEFAULT NULL,
  `EnumDescription` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ReferenceTable` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ReferenceId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_sys_reference
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_taskqueue
-- ----------------------------
DROP TABLE IF EXISTS `cdp_taskqueue`;
CREATE TABLE `cdp_taskqueue`  (
  `TaskQueueID` int NOT NULL AUTO_INCREMENT,
  `BatchOPID` int NULL DEFAULT NULL,
  `Status` int NULL DEFAULT 3 COMMENT '1.Not Started\r\n3.Uninoculated\r\n5.Producting\r\n7.Completed\r\n9.Canceled',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TaskQueueID`) USING BTREE,
  INDEX `BatchOPID`(`BatchOPID` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  CONSTRAINT `cdp_taskqueue_ibfk_1` FOREIGN KEY (`BatchOPID`) REFERENCES `cdp_batch_op` (`BatchOPID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次表和cdp_batch和cdp_batch_op三表联合\r\n对应页面任务队列' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_taskqueue
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_test_loadsample
-- ----------------------------
DROP TABLE IF EXISTS `cdp_test_loadsample`;
CREATE TABLE `cdp_test_loadsample`  (
  `TestLoadSampleId` int NOT NULL AUTO_INCREMENT,
  `DeviceId` int NOT NULL,
  `DeviceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Status` int NOT NULL,
  `IsDeleted` bit(1) NOT NULL DEFAULT b'0',
  `CreateBy` int NOT NULL,
  `CreateTime` datetime NOT NULL,
  `UpdateBy` int NULL DEFAULT NULL,
  `UpdateTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestLoadSampleId`) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  INDEX ```DeviceId```(`DeviceId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '手动取样自动检测-----loadsample模块' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_test_loadsample
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_test_loadsampledtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_test_loadsampledtl`;
CREATE TABLE `cdp_test_loadsampledtl`  (
  `TestLoadSampleDtlId` int NOT NULL AUTO_INCREMENT,
  `TestLoadSampleId` int NOT NULL,
  `LocCombinationID` int NOT NULL,
  `ItemSerialsId` int NOT NULL,
  `SampleId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Volume` int NOT NULL,
  `Well` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `IsBGA` bit(1) NULL DEFAULT NULL,
  `BGASampleVolume` int NULL DEFAULT NULL,
  `BGATemperature` decimal(5, 1) NULL DEFAULT NULL,
  `BGAIsComplete` bit(1) NOT NULL DEFAULT b'0',
  `IsOsmo` bit(1) NULL DEFAULT NULL,
  `OsmoSampleVolume` int NULL DEFAULT NULL,
  `OSMOIsComplete` bit(1) NOT NULL DEFAULT b'0',
  `IsVicell` bit(1) NULL DEFAULT NULL,
  `VicellTestingVolume` int NULL DEFAULT NULL,
  `DilutionFactor` int NULL DEFAULT NULL,
  `VicellSampleVolume` int NULL DEFAULT NULL,
  `VicellCellType` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `VicellIsComplete` bit(1) NOT NULL DEFAULT b'0',
  `IsCedex` bit(1) NULL DEFAULT NULL,
  `CedexSampleVolume` int NULL DEFAULT NULL,
  `CedexParameter` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `CedexIsComplete` bit(1) NOT NULL DEFAULT b'0',
  `Status` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `CreateBy` int NOT NULL,
  `CreateTime` datetime NOT NULL,
  `UpdateBy` int NULL DEFAULT NULL,
  `UpdateTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestLoadSampleDtlId`) USING BTREE,
  INDEX `ItemSerialsId`(`ItemSerialsId` ASC) USING BTREE,
  INDEX `SampleId`(`SampleId` ASC) USING BTREE,
  INDEX `TestLoadSampleId`(`TestLoadSampleId` ASC) USING BTREE,
  INDEX ```LocCombinationID```(`LocCombinationID` ASC) USING BTREE,
  CONSTRAINT `ItemSerialsId` FOREIGN KEY (`ItemSerialsId`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `TestLoadSampleId` FOREIGN KEY (`TestLoadSampleId`) REFERENCES `cdp_test_loadsample` (`TestLoadSampleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '手动取样自动检测-----loadsample模块子表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_test_loadsampledtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_bgacalibrationrec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_bgacalibrationrec`;
CREATE TABLE `cdp_testing_bgacalibrationrec`  (
  `BGACalibrationRecID` int NOT NULL AUTO_INCREMENT,
  `BGADeviceID` int NOT NULL,
  `CalibrationType` int NULL DEFAULT NULL COMMENT '1.一点校准\r\n            3.二点校准\r\n            5.校准前5分钟提示',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：Start 开始校准\r\n            3：Pending 校准新数据待请求\r\n            5：Closed 校准完成\r\n            9：Canceled 取消校准',
  `NextStartTime` datetime NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BGACalibrationRecID`) USING BTREE,
  INDEX `CalibrationType`(`CalibrationType` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  INDEX `BGADeviceID`(`BGADeviceID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '离线检测bga校准记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_bgacalibrationrec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_bgadevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_bgadevice`;
CREATE TABLE `cdp_testing_bgadevice`  (
  `BGADeviceID` int NOT NULL AUTO_INCREMENT,
  `SubSystemIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SubSystemMAC` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `TestingEquipmentID` int NOT NULL,
  `DeviceNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DeviceModel` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '串行端口名称',
  `SerialPortBaudRate` int NULL DEFAULT NULL COMMENT '？',
  `SerialPortDataBits` int NULL DEFAULT NULL,
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DeviceStatus` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BGADeviceID`) USING BTREE,
  INDEX `TestingEquipmentID`(`TestingEquipmentID` ASC) USING BTREE,
  INDEX `SubSystemMAC`(`SubSystemMAC` ASC) USING BTREE,
  INDEX `IsDelete`(`IsDelete` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_bgadevice_ibfk_1` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'BGA仪器设备\r\n离线检测BGA仪器设备' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_bgadevice
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_bgaorder
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_bgaorder`;
CREATE TABLE `cdp_testing_bgaorder`  (
  `TestingBGAOrderID` int NOT NULL AUTO_INCREMENT,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Position` int NULL DEFAULT NULL,
  `TEMP` decimal(18, 2) NULL DEFAULT NULL,
  `BGADeviceID` int NOT NULL,
  `Status` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingBGAOrderID`) USING BTREE,
  INDEX `FK_Reference_97`(`BGADeviceID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_97` FOREIGN KEY (`BGADeviceID`) REFERENCES `cdp_testing_bgadevice` (`BGADeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '离线检测bga 检测订单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_bgaorder
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_bgatask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_bgatask`;
CREATE TABLE `cdp_testing_bgatask`  (
  `TestingBGATaskID` int NOT NULL AUTO_INCREMENT,
  `BGADeviceID` int NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchOPID` int NULL DEFAULT NULL,
  `ItemID` int NULL DEFAULT NULL COMMENT '物料明细ID',
  `SEQNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：New 等待检测 (下发订单成功，等待进样开始检测)\r\n            3：Start 开始检测   （进样成功检测中）\r\n            5：Pending 检测新数据（检测完成待请求检测结果）\r\n            7：Closed 检测完成（成功存储检测结果）\r\n            9：Abnormal 检测数据丢失（请求检测数据无结果）\r\n            99：Cancel  取消检测  ',
  `Mode` int NULL DEFAULT NULL COMMENT '1:Manual\r\n            3:Automatic',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回原因',
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回备注',
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `OriginalSampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`TestingBGATaskID`) USING BTREE,
  INDEX `FK_Reference_100`(`BatchID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `SignatureID`(`SignatureUserID` ASC) USING BTREE,
  INDEX `VerifyID`(`VerifyUserID` ASC) USING BTREE,
  INDEX ```TestingBGATaskID```(`TestingBGATaskID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX `Last_update_time`(`Last_update_time` ASC) USING BTREE,
  INDEX `StartTime`(`StartTime` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_100` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '离线检测BGA 检测任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_bgatask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_bgataskresult
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_bgataskresult`;
CREATE TABLE `cdp_testing_bgataskresult`  (
  `BGATaskResultID` int NOT NULL AUTO_INCREMENT,
  `TestingBGATaskID` int NULL DEFAULT NULL,
  `Name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `Value` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `Unit` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BGATaskResultID`) USING BTREE,
  INDEX `FK_Reference_96`(`TestingBGATaskID` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_bgataskresult_ibfk_1` FOREIGN KEY (`TestingBGATaskID`) REFERENCES `cdp_testing_bgatask` (`TestingBGATaskID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '离线检测BGA 检测结果明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_bgataskresult
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cedexdevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cedexdevice`;
CREATE TABLE `cdp_testing_cedexdevice`  (
  `CedexDeviceID` int NOT NULL AUTO_INCREMENT,
  `SubSystemIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DeviceIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemMAC` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `TestingEquipmentID` int NOT NULL,
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortBaudRate` int NULL DEFAULT NULL,
  `SerialPortDataBits` int NULL DEFAULT NULL,
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DeviceStatus` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`CedexDeviceID`) USING BTREE,
  INDEX `TestingEquipmentID`(`TestingEquipmentID` ASC) USING BTREE,
  INDEX `SubSystemMAC`(`SubSystemMAC` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_cedexdevice_ibfk_1` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测cedex仪器设备' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedexdevice
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cedexorder
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cedexorder`;
CREATE TABLE `cdp_testing_cedexorder`  (
  `TestingCedexOrderID` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `CedexDeviceID` int NOT NULL COMMENT '设备编号',
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '样本编号',
  `Position` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '位置信息',
  `TestingItem` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测项目',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingCedexOrderID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测cedex 检测订单' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedexorder
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cedextask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cedextask`;
CREATE TABLE `cdp_testing_cedextask`  (
  `TestingCedexTaskID` int NOT NULL AUTO_INCREMENT,
  `OrderParameter` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n            3：Sample Edition\r\n            5：Start\r\n            7：Closed\r\n            99.Cancel',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingCedexTaskID`) USING BTREE,
  INDEX ```TestingCedexTaskID```(`TestingCedexTaskID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'cedex检测任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedextask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cedextaskdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cedextaskdtl`;
CREATE TABLE `cdp_testing_cedextaskdtl`  (
  `TestingCedexTaskDtlID` int NOT NULL AUTO_INCREMENT,
  `TestingCedexTaskID` int NULL DEFAULT NULL,
  `CedexDeviceID` int NOT NULL COMMENT '设备编号',
  `TestingItems` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '所有需要做的检测项(TestingNo)|分割',
  `PositionNo` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ItemID` int NULL DEFAULT NULL COMMENT '物料明细ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchOPID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '5：Testing\r\n7:  Tested\r\n9:   Uploaded\r\n11:  Signed\r\n13:  Verified\r\n99. Canceled',
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `Mode` int NULL DEFAULT NULL,
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回原因',
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回备注',
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `AbnormalReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '异常原因',
  `AbnormalUserID` int NULL DEFAULT NULL COMMENT '异常人ID',
  `AbnormalTime` datetime NULL DEFAULT NULL COMMENT '置为异常时间',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `OriginalSampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`TestingCedexTaskDtlID`) USING BTREE,
  INDEX `FK_Reference_89`(`TestingCedexTaskID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `cdp_testing_cedextaskdtl_ibfk_1`(`SignatureUserID` ASC) USING BTREE,
  INDEX `cdp_testing_cedextaskdtl_ibfk_2`(`VerifyUserID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX `Last_update_time`(`Last_update_time` ASC) USING BTREE,
  INDEX `StartTime`(`StartTime` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_89` FOREIGN KEY (`TestingCedexTaskID`) REFERENCES `cdp_testing_cedextask` (`TestingCedexTaskID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'cedex检测任务明细' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedextaskdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cedextaskresult
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cedextaskresult`;
CREATE TABLE `cdp_testing_cedextaskresult`  (
  `TestingCedexTaskResultId` int NOT NULL AUTO_INCREMENT,
  `TestingCedexTaskDtlID` int NULL DEFAULT NULL COMMENT '检测详情ID',
  `TestingItem` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测项目',
  `SpecticFactor` decimal(18, 2) NULL DEFAULT NULL COMMENT '稀释倍数',
  `TestingValue` decimal(18, 4) NULL DEFAULT NULL COMMENT '检测结果',
  `TestingUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测单位',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingCedexTaskResultId`) USING BTREE,
  INDEX ```TestingCedexTaskResultId```(`TestingCedexTaskResultId` ASC) USING BTREE,
  INDEX ```TestingCedexTaskDtlID```(`TestingCedexTaskDtlID` ASC) USING BTREE,
  INDEX ```TestingItem```(`TestingItem` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'cedextask检测结果' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedextaskresult
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_equipment
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_equipment`;
CREATE TABLE `cdp_testing_equipment`  (
  `TestingEquipmentID` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `EquipmentType` int NOT NULL COMMENT '设备类型',
  `EquipmentNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '设备编号',
  `EquipmentModel` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备型号',
  `LabId` int NOT NULL COMMENT '实验室Id',
  `AssetNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '资产编号',
  `Description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '描述',
  `Status` int NULL DEFAULT NULL COMMENT '1.启用 3.禁用',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingEquipmentID`) USING BTREE,
  INDEX `EquipmentNo`(`EquipmentNo` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----设备管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_equipment
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_operation
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_operation`;
CREATE TABLE `cdp_testing_operation`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `SampleId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测订单编号',
  `OldSampleId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '之前的Sample ID',
  `DeviceNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测设备编号',
  `TestDeviceCategory` int NULL DEFAULT NULL COMMENT '测试类型 1.BGA 2.OSMO 3.OSMO6060 4.Vicell 5.Cedex',
  `OperatorType` int NOT NULL DEFAULT 1 COMMENT '类型：1.上传 2.撤回上传 3.签名 4.撤销签名 5.审核 6.撤销审核 7.修改Sample ID 8.作废 9.取消 10.删除  99.其他',
  `OperatorUserId` int NOT NULL COMMENT '操作人',
  `OperatorTime` datetime NOT NULL COMMENT '操作时间',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `SampleId`(`SampleId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_operation
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_osmodevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_osmodevice`;
CREATE TABLE `cdp_testing_osmodevice`  (
  `OSMODeviceID` int NOT NULL AUTO_INCREMENT,
  `TestingEquipmentID` int NOT NULL,
  `SubSystemMAC` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemIP` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `OSMOIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `OSMOPort` int NULL DEFAULT NULL,
  `OSMOType` int NULL DEFAULT 1 COMMENT 'OSMO设备类型：1：OSMOPro、3：OSMO6060',
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '实时端口名称',
  `SerialPortBaudRate` int NULL DEFAULT NULL COMMENT '实时端口传播速率',
  `SerialPortDataBits` int NULL DEFAULT NULL COMMENT '实时端口数据位',
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '停止位',
  `SerialPortParity` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '流控',
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校验位',
  `DeviceStatus` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OSMODeviceID`) USING BTREE,
  INDEX `TestingEquipmentID`(`TestingEquipmentID` ASC) USING BTREE,
  INDEX `SubSystemMAC`(`SubSystemMAC` ASC) USING BTREE,
  INDEX `IsDelete`(`IsDelete` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_osmodevice_ibfk_1` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测osmo' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_osmodevice
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_osmoorder
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_osmoorder`;
CREATE TABLE `cdp_testing_osmoorder`  (
  `TestingOSMOOrderID` int NOT NULL AUTO_INCREMENT,
  `OSMODeviceID` int NULL DEFAULT NULL COMMENT '设备ID',
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PositionNo` int NOT NULL COMMENT '位置1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingOSMOOrderID`) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测osmo记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_osmoorder
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_osmotask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_osmotask`;
CREATE TABLE `cdp_testing_osmotask`  (
  `TestingOSMOTaskID` int NOT NULL AUTO_INCREMENT,
  `OrderParameter` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `OSMODeviceID` int NULL DEFAULT NULL,
  `Mode` int NOT NULL DEFAULT 3 COMMENT '1:Manual\r\n            3:Automatic',
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n            3：Start\r\n            5：Closed\r\n            99.Cancel',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingOSMOTaskID`) USING BTREE,
  INDEX `OSMODeviceNo`(`OSMODeviceID` ASC) USING BTREE,
  INDEX ```TestingOSMOTaskID```(`TestingOSMOTaskID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '下游检测osmo检测任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_osmotask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_osmotaskdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_osmotaskdtl`;
CREATE TABLE `cdp_testing_osmotaskdtl`  (
  `TestingOSMOTaskDtlID` int NOT NULL AUTO_INCREMENT,
  `TestingOSMOTaskID` int NULL DEFAULT NULL,
  `PositionNo` int NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ItemID` int NULL DEFAULT NULL COMMENT '物料明细ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchOPID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n3：Testing\r\n5：Tested\r\n9:  Uploaded\r\n11: Signed\r\n13: Verified\r\n99. Canceled',
  `OSMO` decimal(18, 4) NULL DEFAULT NULL COMMENT '物料明细ID',
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回原因',
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回备注',
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `OriginalSampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`TestingOSMOTaskDtlID`) USING BTREE,
  INDEX `FK_Reference_88`(`TestingOSMOTaskID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `SignatureUserID`(`SignatureUserID` ASC) USING BTREE,
  INDEX `VerifyUserID`(`VerifyUserID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX `Last_update_time`(`Last_update_time` ASC) USING BTREE,
  INDEX `StartTime`(`StartTime` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_88` FOREIGN KEY (`TestingOSMOTaskID`) REFERENCES `cdp_testing_osmotask` (`TestingOSMOTaskID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '下游检测osmo检测任务详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_osmotaskdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_signature
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_signature`;
CREATE TABLE `cdp_testing_signature`  (
  `TestingSignatureID` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `OperationType` int NULL DEFAULT NULL COMMENT '1 Signature,3 Verify,5 RevokeSignature,7 RevokeVerify',
  `OperationUser` int NULL DEFAULT NULL,
  `OperationTime` datetime NULL DEFAULT NULL,
  `RevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`TestingSignatureID`) USING BTREE,
  INDEX `OperationType`(`OperationType` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----数字签名' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_signature
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_signaturedtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_signaturedtl`;
CREATE TABLE `cdp_testing_signaturedtl`  (
  `TestingSignatureDtlID` int NOT NULL AUTO_INCREMENT,
  `TestingSignatureID` int NOT NULL,
  `CultureID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SecondID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Day` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`TestingSignatureDtlID`) USING BTREE,
  INDEX `TestingSignatureID`(`TestingSignatureID` ASC) USING BTREE,
  INDEX `CultureID`(`CultureID` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_signaturedtl_ibfk_1` FOREIGN KEY (`TestingSignatureID`) REFERENCES `cdp_testing_signature` (`TestingSignatureID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----数字签名详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_signaturedtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_subsystemsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_subsystemsetting`;
CREATE TABLE `cdp_testing_subsystemsetting`  (
  `TestingSubSystemSettingID` int NOT NULL AUTO_INCREMENT,
  `LabDeviceID` int NULL DEFAULT NULL,
  `SubSystemIP` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemType` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'OSMO,\r\nVICELL,',
  `Description` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `DisplaySequence` int NOT NULL DEFAULT 1,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingSubSystemSettingID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_subsystemsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_vicelldevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_vicelldevice`;
CREATE TABLE `cdp_testing_vicelldevice`  (
  `VicellDeviceID` int NOT NULL AUTO_INCREMENT,
  `TestingEquipmentID` int NOT NULL,
  `SubSystemMAC` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemIP` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ExcelPath` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `WasteUpperLimit` int NOT NULL DEFAULT 0 COMMENT '废料上限',
  `CurrentWasteCount` int NOT NULL DEFAULT 0 COMMENT '当前废料数',
  `DeviceStatus` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`VicellDeviceID`) USING BTREE,
  INDEX `TestingEquipmentID`(`TestingEquipmentID` ASC) USING BTREE,
  INDEX `SubSystemMAC`(`SubSystemMAC` ASC) USING BTREE,
  INDEX `IsDelete`(`IsDelete` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_vicelldevice_ibfk_1` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测vicell' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_vicelldevice
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_vicellfile
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_vicellfile`;
CREATE TABLE `cdp_testing_vicellfile`  (
  `VicellFileID` int NOT NULL AUTO_INCREMENT,
  `SystemMac` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '系统mac地址',
  `Path` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '文件路径',
  `Extension` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '文件格式',
  `ShortName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '文件名称',
  `FileCreationTime` datetime NULL DEFAULT NULL COMMENT '文件创建时间',
  `CreationTime` datetime NULL DEFAULT NULL COMMENT '系统创建时间',
  `IsDelete` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  PRIMARY KEY (`VicellFileID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测vicell文件' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_vicellfile
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_vicellorder
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_vicellorder`;
CREATE TABLE `cdp_testing_vicellorder`  (
  `VicellDeviceOrderID` int NOT NULL AUTO_INCREMENT,
  `VicellDeviceID` int NOT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `IsClosed` bit(1) NOT NULL DEFAULT b'0',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`VicellDeviceOrderID`) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `DeviceNo`(`VicellDeviceID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测vicell记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_vicellorder
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_vicelltask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_vicelltask`;
CREATE TABLE `cdp_testing_vicelltask`  (
  `TestingVicellTaskID` int NOT NULL AUTO_INCREMENT,
  `OrderParameter` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `VicellDeviceID` int NULL DEFAULT NULL,
  `Mode` int NOT NULL DEFAULT 3 COMMENT '1:Manual\r\n            3:Automatic',
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n            3：Sample Edition\r\n            5：Start\r\n            7：Closed\r\n            99.Cancel',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingVicellTaskID`) USING BTREE,
  INDEX `VicellDeviceNo`(`VicellDeviceID` ASC) USING BTREE,
  INDEX ```TestingVicellTaskID```(`TestingVicellTaskID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX `Time`(`StartTime` ASC, `EndTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '下游检测vicell检测任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_vicelltask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_vicelltaskdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_vicelltaskdtl`;
CREATE TABLE `cdp_testing_vicelltaskdtl`  (
  `TestingVicellTaskDtlID` int NOT NULL AUTO_INCREMENT,
  `TestingVicellTaskID` int NULL DEFAULT NULL,
  `PositionNo` int NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CellType` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DilutionFactor` decimal(18, 2) NULL DEFAULT NULL,
  `ItemID` int NULL DEFAULT NULL COMMENT '物料明细ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchOPID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `VCD` decimal(18, 4) NULL DEFAULT NULL COMMENT '物料明细ID',
  `Viability` decimal(18, 4) NULL DEFAULT NULL COMMENT 'ID',
  `AvgDiam` decimal(18, 4) NULL DEFAULT NULL COMMENT 'ID',
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n3：Testing\r\n5:  Tested\r\n9:  Uploaded\r\n11: Signed\r\n13: Verified\r\n99. Canceled',
  `ExcelFileLocation` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回原因',
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '上传撤回备注',
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `ErrorMsg` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '异常标记',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `OriginalSampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`TestingVicellTaskDtlID`) USING BTREE,
  INDEX `FK_Reference_87`(`TestingVicellTaskID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `cdp_testing_vicelltaskdtl_ibfk_1`(`SignatureUserID` ASC) USING BTREE,
  INDEX `cdp_testing_vicelltaskdtl_ibfk_2`(`VerifyUserID` ASC) USING BTREE,
  INDEX ```BatchID```(`BatchID` ASC) USING BTREE,
  INDEX ```Status```(`Status` ASC) USING BTREE,
  INDEX `Last_update_time`(`Last_update_time` ASC) USING BTREE,
  INDEX `StartTime`(`StartTime` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_87` FOREIGN KEY (`TestingVicellTaskID`) REFERENCES `cdp_testing_vicelltask` (`TestingVicellTaskID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '下游检测vicell检测任务详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_vicelltaskdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testingdef
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testingdef`;
CREATE TABLE `cdp_testingdef`  (
  `TestingDefID` int NOT NULL AUTO_INCREMENT COMMENT '测试项目定义',
  `TestingNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测项目No',
  `TestingName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测项目名称',
  `TestingDescription` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测项目描述',
  `TestingType` int NULL DEFAULT NULL COMMENT 'BGA 1\r\nVicell 3\r\nOMSO 5\r\nCedex 7',
  `UpperLimit` decimal(10, 0) NULL DEFAULT NULL COMMENT '检测上线值',
  `LowerLimit` decimal(10, 0) NULL DEFAULT NULL COMMENT '检测下限值',
  `IsDataSignature` bit(1) NULL DEFAULT NULL COMMENT '是否签名需要',
  `Unit` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '单位',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingDefID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测---检测项目管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testingdef
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testingyaxissetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testingyaxissetting`;
CREATE TABLE `cdp_testingyaxissetting`  (
  `TestingYaxisSettingId` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `UserID` int NULL DEFAULT NULL COMMENT '用户ID',
  `TestingDefID` int NULL DEFAULT NULL COMMENT '外键ID',
  `MinY` decimal(18, 2) NULL DEFAULT NULL COMMENT 'Y轴最小值',
  `MaxY` decimal(18, 2) NULL DEFAULT NULL COMMENT 'Y轴最大值',
  `IsDelete` bit(1) NULL DEFAULT NULL,
  `Create_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingYaxisSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测---检测项目管理  y轴设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testingyaxissetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_useroperatelog
-- ----------------------------
DROP TABLE IF EXISTS `cdp_useroperatelog`;
CREATE TABLE `cdp_useroperatelog`  (
  `OperateId` int NOT NULL AUTO_INCREMENT COMMENT '用户操作ID',
  `UserId` int NULL DEFAULT NULL COMMENT '用户ID',
  `ModuleName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LogTime` datetime NULL DEFAULT NULL COMMENT '日志时间',
  `Action` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Location` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Remark` varchar(2000) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `BeforeData` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `AfterData` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `IPAddress` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`OperateId`) USING BTREE,
  INDEX `FK_Reference_42`(`UserId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_42` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户操作记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_useroperatelog
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow`;
CREATE TABLE `cdp_workflow`  (
  `WorkflowID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowType` int NULL DEFAULT NULL COMMENT '1.Start Culture\r\n3.Inoculation\r\n5.Feeding Unit Connection\r\n7.Supply Liquid(Sampling Unit)\r\n9.Supply Liquid(Feeding Unit)\r\n11.Waste Clean\r\n13.Material Import\r\n15.Complete Culture\r\n17.Feeding Other\r\n19.Feeding Manual\r\n21.Sampling Manual',
  `UserID` int NOT NULL COMMENT 'UserID',
  `FailureCause` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '\0',
  `IsSatellite` bit(1) NULL DEFAULT NULL COMMENT '是否卫星罐',
  `LocCombinationID` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Creation_FinishTime` datetime NULL DEFAULT NULL,
  `Creation_FinishBy` int NULL DEFAULT NULL COMMENT '记录完成人',
  PRIMARY KEY (`WorkflowID`) USING BTREE,
  INDEX `WorkflowType`(`WorkflowType` ASC) USING BTREE,
  INDEX `LocCombinationID`(`LocCombinationID` ASC) USING BTREE,
  INDEX `IsDelete`(`IsDelete` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchcomplete
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchcomplete`;
CREATE TABLE `cdp_workflow_batchcomplete`  (
  `BatchCompleteID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `Status` int NULL DEFAULT NULL COMMENT '1.用户开始完成批次\r\n            3.完成Workflow',
  `ItemID` int NULL DEFAULT NULL,
  PRIMARY KEY (`BatchCompleteID`) USING BTREE,
  INDEX `FK_Reference_75`(`WorkflowID` ASC) USING BTREE,
  INDEX `FK_Reference_78`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_75` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_78` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流--结束细胞培养' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchcomplete
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchinoculation
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchinoculation`;
CREATE TABLE `cdp_workflow_batchinoculation`  (
  `BatchInoculationID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `CellType` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CellsVolume` decimal(18, 2) NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `InitialVCD` decimal(18, 2) NULL DEFAULT NULL,
  `InitialViablity` decimal(18, 2) NULL DEFAULT NULL,
  `InitialCellLotNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `AvgDiam` decimal(32, 0) NULL DEFAULT NULL,
  `TargetViableCellNumber` decimal(18, 2) NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '1:用户开始接种\r\n            3:完成Workflow\r\n            \r\n            99:取消',
  `DisChargeStatus` bit(1) NULL DEFAULT NULL,
  `DisChargeVolume` decimal(18, 2) NULL DEFAULT NULL,
  `PipeInstallationStatus` bit(1) NULL DEFAULT NULL,
  `SoftwareStatus` bit(1) NULL DEFAULT NULL,
  PRIMARY KEY (`BatchInoculationID`) USING BTREE,
  INDEX `FK_Reference_69`(`BatchID` ASC) USING BTREE,
  INDEX `FK_Reference_70`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_batchinoculation_ibfk_1` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_workflow_batchinoculation_ibfk_2` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---接种' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchinoculation
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchsupplyconnection
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchsupplyconnection`;
CREATE TABLE `cdp_workflow_batchsupplyconnection`  (
  `BatchSupplyConnectionID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `MultiFeedStatus` bit(1) NULL DEFAULT NULL COMMENT 'Multi-feed控制开启',
  `VesselWeightStatus` bit(1) NULL DEFAULT NULL COMMENT 'vessel weight控制开启',
  `HarvestPumpStatus` bit(1) NULL DEFAULT NULL COMMENT '关联Harvest泵开启',
  `Status` int NULL DEFAULT NULL COMMENT '1:用户开始连接补料单元\r\n            3:完成Workflow\r\n            \r\n            99:取消',
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  PRIMARY KEY (`BatchSupplyConnectionID`) USING BTREE,
  INDEX `WorkflowID`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_batchsupplyconnection_ibfk_1` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---连接补料单元' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchsupplyconnection
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchsupplyconnectiondtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchsupplyconnectiondtl`;
CREATE TABLE `cdp_workflow_batchsupplyconnectiondtl`  (
  `BatchSupplyConnectionDtlID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL,
  `LabDeviceID` int NULL DEFAULT NULL,
  `LocCombinationID` int NULL DEFAULT NULL,
  `PumpNo` int NULL DEFAULT NULL COMMENT '泵编号',
  `ItemDefId` int NULL DEFAULT NULL COMMENT '补料培养基Id',
  `Volume` int NULL DEFAULT NULL,
  `Speed` int NULL DEFAULT NULL,
  `LocationNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Unit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`BatchSupplyConnectionDtlID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '工作流---连接补料单元详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchsupplyconnectiondtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_feedingmanual
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_feedingmanual`;
CREATE TABLE `cdp_workflow_feedingmanual`  (
  `FeedingManualID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT '流程ID',
  `LocCombinationID` int NOT NULL COMMENT '位置ID',
  `FluidName` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '补料名称',
  `FluidVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料液量',
  `Status` int NULL DEFAULT NULL COMMENT '手动补料状态\r\n1 开始\r\n3 完成',
  PRIMARY KEY (`FeedingManualID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '工作流---手动补料' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_feedingmanual
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_liquidimport_samplingunit
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_liquidimport_samplingunit`;
CREATE TABLE `cdp_workflow_liquidimport_samplingunit`  (
  `SamplingUnitLiquidImportID` int NOT NULL AUTO_INCREMENT,
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次ID',
  `LocCombinationID` int NOT NULL COMMENT '储位组合ID',
  `ExportItemID` int NULL DEFAULT NULL,
  `ExportItemDefID` int NULL DEFAULT NULL,
  `ExportFluidDefID` int NULL DEFAULT NULL,
  `ExportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `ImportItemID` int NULL DEFAULT NULL,
  `ImportItemDefID` int NULL DEFAULT NULL,
  `ImportFluidDefID` int NULL DEFAULT NULL,
  `ImportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `Status` int NULL DEFAULT NULL COMMENT '1.用户扫码换桶\r\n            3.完成Workflow',
  PRIMARY KEY (`SamplingUnitLiquidImportID`) USING BTREE,
  INDEX `WorkflowID`(`WorkflowID` ASC) USING BTREE,
  INDEX `ImportItemID`(`ImportItemID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_liquidimport_samplingunit_ibfk_1` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_workflow_liquidimport_samplingunit_ibfk_2` FOREIGN KEY (`ImportItemID`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---手动取样' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_liquidimport_samplingunit
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_liquidimport_supplyunit
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_liquidimport_supplyunit`;
CREATE TABLE `cdp_workflow_liquidimport_supplyunit`  (
  `SupplyUnitLiquidImportID` int NOT NULL AUTO_INCREMENT,
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次ID',
  `LocCombinationID` int NOT NULL COMMENT '储位组合ID',
  `ExportItemID` int NULL DEFAULT NULL,
  `ExportItemDefID` int NULL DEFAULT NULL,
  `ExportFluidDefID` int NULL DEFAULT NULL,
  `ExportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `ImportItemID` int NULL DEFAULT NULL,
  `ImportItemDefID` int NULL DEFAULT NULL,
  `ImportFluidDefID` int NULL DEFAULT NULL,
  `ImportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `Status` int NULL DEFAULT NULL COMMENT '1.用户扫码换桶\r\n            3.完成Workflow',
  PRIMARY KEY (`SupplyUnitLiquidImportID`) USING BTREE,
  INDEX `FK_Reference_76`(`WorkflowID` ASC) USING BTREE,
  INDEX `ImportItemID`(`ImportItemID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_liquidimport_supplyunit_ibfk_1` FOREIGN KEY (`ImportItemID`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_76` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---更换手动补料' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_liquidimport_supplyunit
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_liquidother
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_liquidother`;
CREATE TABLE `cdp_workflow_liquidother`  (
  `FeedingOtherID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT '流程ID',
  `LocCombinationID` int NOT NULL COMMENT '位置ID',
  `PurgingSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT '预填充速速',
  `PumpingName` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '补料名称',
  `PumpingVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料液量',
  `PumpingSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料速度',
  `Status` int NULL DEFAULT NULL COMMENT '1 开始\r\n3 连接完成\r\n5 预填充完成\r\n7 完成',
  PRIMARY KEY (`FeedingOtherID`) USING BTREE,
  INDEX `WorkflowID`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_liquidother_ibfk_1` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_liquidother
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_liquidwaste
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_liquidwaste`;
CREATE TABLE `cdp_workflow_liquidwaste`  (
  `LiquidWasteID` int NOT NULL AUTO_INCREMENT,
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次ID',
  `LocCombinationID` int NOT NULL COMMENT '储位组合ID',
  `ExportItemID` int NULL DEFAULT NULL,
  `ExportItemDefID` int NULL DEFAULT NULL,
  `ExportFluidDefID` int NULL DEFAULT NULL,
  `ExportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `ImportItemID` int NULL DEFAULT NULL,
  `ImportItemDefID` int NULL DEFAULT NULL,
  `ImportFluidDefID` int NULL DEFAULT NULL,
  `ImportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `Status` int NULL DEFAULT NULL COMMENT '1.用户扫码换桶\r\n            3.完成Workflow',
  PRIMARY KEY (`LiquidWasteID`) USING BTREE,
  INDEX `FK_Reference_77`(`WorkflowID` ASC) USING BTREE,
  INDEX `ImportItemID`(`ImportItemID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_liquidwaste_ibfk_1` FOREIGN KEY (`ImportItemID`) REFERENCES `cdp_item_serials` (`ItemID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_77` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_liquidwaste
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_material_import
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_material_import`;
CREATE TABLE `cdp_workflow_material_import`  (
  `WorkflowMaterialImportID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '状态:\r\n1.Start\r\n3.Finish\r\n99.Cancel',
  `LabId` int NULL DEFAULT NULL,
  PRIMARY KEY (`WorkflowMaterialImportID`) USING BTREE,
  INDEX `WorkflowID`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_material_import_ibfk_1` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_material_import
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_material_import_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_material_import_dtl`;
CREATE TABLE `cdp_workflow_material_import_dtl`  (
  `WorkflowMaterialImportDtlID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowMaterialImportID` int NULL DEFAULT NULL,
  `LocCombinationID` int NOT NULL COMMENT '位置ID',
  `ImportItemDefID` int NULL DEFAULT NULL COMMENT '物料ID',
  `ImportBarcode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '物料条码',
  `ExportItemID` int NULL DEFAULT NULL COMMENT '旧物料ID',
  PRIMARY KEY (`WorkflowMaterialImportDtlID`) USING BTREE,
  INDEX `WorkflowMaterialImportID`(`WorkflowMaterialImportID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_material_import_dtl_ibfk_1` FOREIGN KEY (`WorkflowMaterialImportID`) REFERENCES `cdp_workflow_material_import` (`WorkflowMaterialImportID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_material_import_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_perfusionsure
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_perfusionsure`;
CREATE TABLE `cdp_workflow_perfusionsure`  (
  `PerfusionSureId` int NOT NULL AUTO_INCREMENT,
  `BatchId` int NOT NULL,
  `ATFStatus` bit(1) NULL DEFAULT NULL COMMENT 'ATF已连接确认',
  `ScaleStatus` bit(1) NULL DEFAULT NULL COMMENT '台秤已清零确认',
  `BasicMediumStatus` bit(1) NULL DEFAULT NULL COMMENT '培养基已注入确认',
  `ControllerStatus` bit(1) NULL DEFAULT NULL COMMENT '控制器已设置确认',
  `ATFControlStatus` bit(1) NULL DEFAULT NULL COMMENT 'ATF control已开启确认',
  `ReactorStatus` bit(1) NULL DEFAULT NULL COMMENT '罐体已菌检确认',
  `ATFPillarStatus` bit(1) NULL DEFAULT NULL COMMENT 'ATF柱已菌检确认',
  `PumpStatus` bit(1) NULL DEFAULT NULL COMMENT '泵已校准确认',
  `CreateTime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`PerfusionSureId`) USING BTREE,
  INDEX `BatchId`(`BatchId` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_perfusionsure_ibfk_1` FOREIGN KEY (`BatchId`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_perfusionsure
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_samplingmanual
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_samplingmanual`;
CREATE TABLE `cdp_workflow_samplingmanual`  (
  `SamplingManualID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT '流程ID',
  `LocCombinationID` int NOT NULL COMMENT '位置ID',
  `SampleVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料液量',
  `HarvestVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '收获液量',
  `Status` int NULL DEFAULT NULL COMMENT '手动补料状态\r\n1 开始\r\n3 完成',
  PRIMARY KEY (`SamplingManualID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_samplingmanual
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_email_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_email_rec`;
CREATE TABLE `sys_notification_email_rec`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '通知主键',
  `NotificationRecId` int NULL DEFAULT NULL,
  `UserID` int NULL DEFAULT NULL,
  `Email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `From` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人',
  `To` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '收件人，多个以英文；隔开',
  `CC` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '抄送人，多个以英文；隔开',
  `Subject` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '主题',
  `Body` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '邮件主体',
  `SendTime` datetime NULL DEFAULT NULL COMMENT '发送时间',
  `NotificationCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '通知编号',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `FK_Reference_fk1`(`NotificationRecId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_fk1` FOREIGN KEY (`NotificationRecId`) REFERENCES `sys_notification_rec` (`NotificationRecId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '邮件通知记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_email_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_emailsetting
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_emailsetting`;
CREATE TABLE `sys_notification_emailsetting`  (
  `EmailSettingId` int NOT NULL AUTO_INCREMENT COMMENT '通知设置主键',
  `SenderPlatformName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人平台',
  `EmailServiceAddress` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发送邮件服务器地址',
  `SenderPassword` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人密码',
  `From` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人邮箱',
  `FromDefault` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发件人默认邮箱',
  `EmailServicePort` int NOT NULL COMMENT '发送邮件服务器端口',
  `SendAccount` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发件人账号',
  `To` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '收件人邮箱',
  `CC` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '抄送人邮箱',
  `IsDefault` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否默认邮箱',
  PRIMARY KEY (`EmailSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '邮件通知设置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_emailsetting
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_msg_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_msg_rec`;
CREATE TABLE `sys_notification_msg_rec`  (
  `MsgRecId` int NOT NULL AUTO_INCREMENT,
  `LabId` int NULL DEFAULT NULL,
  `BatchId` int NULL DEFAULT NULL,
  `Content` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SendTo` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SendTime` datetime NULL DEFAULT NULL,
  `MsgType` int NULL DEFAULT NULL COMMENT '1.pH 3.降温',
  `Status` int NOT NULL COMMENT '0.  未发送  1.已发送 99.异常',
  `IsDelete` bit(1) NULL DEFAULT b'0',
  `CreateBy` int NULL DEFAULT NULL,
  `CreateTime` datetime NULL DEFAULT NULL,
  `UpdateBy` int NULL DEFAULT NULL,
  `UpdateTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`MsgRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_msg_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_rec`;
CREATE TABLE `sys_notification_rec`  (
  `NotificationRecId` int NOT NULL AUTO_INCREMENT COMMENT '消息记录ID',
  `NotificationCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '消息提醒Code',
  `ReferenceId` int NULL DEFAULT NULL COMMENT '引用ID',
  `ReferenceSecondId` int NULL DEFAULT NULL COMMENT '第二引用ID',
  `SendTime` datetime NULL DEFAULT NULL COMMENT '发送时间',
  PRIMARY KEY (`NotificationRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_setting
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_setting`;
CREATE TABLE `sys_notification_setting`  (
  `NotificationSettingID` int NOT NULL AUTO_INCREMENT COMMENT '通知设置主键',
  `NotificationItem` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '栏目',
  `NotificationCode` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '编码',
  `NotificationCategory` int NOT NULL COMMENT '类目',
  `NotificationDescription` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '描述',
  `NotificationTime` int NULL DEFAULT NULL COMMENT '通知时间',
  `NotificationTimeOfStart` int NULL DEFAULT NULL COMMENT '自定义 起始时间',
  `NotificationTimeOfEnd` int NULL DEFAULT NULL COMMENT '自定义 结束时间',
  `NotificationMethodOfWeb` bit(1) NOT NULL DEFAULT b'0' COMMENT '站内通知',
  `NotificationMethodOfEmail` bit(1) NOT NULL DEFAULT b'0' COMMENT '邮件通知',
  `NotificationMethodOfPhone` bit(1) NOT NULL DEFAULT b'0' COMMENT '电话通知',
  `NotificationFrequency` int NULL DEFAULT NULL COMMENT '通知频率',
  `NotificationFrequencyOfMinutes` int NULL DEFAULT NULL COMMENT '多少分钟通知一次',
  `NotificationTimeBuffer` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人主键',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '记录修改人主键',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '记录修改时间',
  PRIMARY KEY (`NotificationSettingID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '站内通知设置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_setting
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_site_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_site_rec`;
CREATE TABLE `sys_notification_site_rec`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '通知设置主键',
  `NotificationCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '通知编号',
  `NotificationRecId` int NULL DEFAULT NULL,
  `MachineID` int NOT NULL COMMENT '机器主键',
  `Tag` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '标签',
  `Title` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '标题',
  `NotificationContent` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '通知内容',
  `Link` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '链接地址',
  `Parameter` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '参数',
  `NotificationTime` datetime NOT NULL COMMENT '通知时间',
  `Status` bit(1) NOT NULL DEFAULT b'0' COMMENT '已读状态',
  `UserId` int NULL DEFAULT NULL COMMENT '用户主键',
  `NotificationFlag` bit(1) NOT NULL DEFAULT b'0' COMMENT '0：未通知  1：已通知',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人主键',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '记录修改人主键',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '记录修改时间',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `NotificationRecId`(`NotificationRecId` ASC) USING BTREE,
  INDEX `NotificationFlag`(`NotificationFlag` ASC) USING BTREE,
  CONSTRAINT `sys_notification_site_rec_ibfk_1` FOREIGN KEY (`NotificationRecId`) REFERENCES `sys_notification_rec` (`NotificationRecId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '站内通知记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_site_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notificaton_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_notificaton_user`;
CREATE TABLE `sys_notificaton_user`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NULL DEFAULT NULL,
  `Email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Phone` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `CreateTime` datetime NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notificaton_user
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
