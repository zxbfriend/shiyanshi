/*
 Navicat Premium Dump SQL

 Source Server         : 101.200.152.223-ymsc
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : 101.200.152.223:6033
 Source Schema         : npp

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 01/09/2026 16:11:18
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '权限模块表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_module
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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '角色模块关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_rolemodule
-- ----------------------------

-- ----------------------------
-- Table structure for auth_rolemodule_copy1
-- ----------------------------
DROP TABLE IF EXISTS `auth_rolemodule_copy1`;
CREATE TABLE `auth_rolemodule_copy1`  (
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
  CONSTRAINT `auth_rolemodule_copy1_ibfk_1` FOREIGN KEY (`ModuleId`) REFERENCES `auth_module` (`ModuleId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_rolemodule_copy1_ibfk_2` FOREIGN KEY (`RoleId`) REFERENCES `auth_role` (`RoleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '角色模块关联表副本' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_rolemodule_copy1
-- ----------------------------

-- ----------------------------
-- Table structure for auth_user
-- ----------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user`  (
  `UserId` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `Account` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Pwd` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ADFSPwd` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'ADFS密码',
  `DisplayName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `JobNumber` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DepartmentId` int NULL DEFAULT NULL,
  `Email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Team` int NULL DEFAULT NULL COMMENT '团队：1：UpStream 3：DowmStream 5：Both',
  `OnlineStatus` bit(1) NOT NULL DEFAULT b'0',
  `IsInitialPwd` bit(1) NOT NULL COMMENT '是否初始密码',
  `SigningFailCount` int NULL DEFAULT NULL,
  `PasswordEffectiveDate` datetime NULL DEFAULT NULL,
  `PasswordValidityPeriod` int NULL DEFAULT NULL,
  `PasswordExpirationDate` datetime NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `ExperimentalGroup` int NULL DEFAULT NULL COMMENT '实验组',
  `IsReceiveSMS` bit(1) NULL DEFAULT b'1',
  `IsReceiveEmail` bit(1) NULL DEFAULT b'1',
  `IsReceiveSite` bit(1) NULL DEFAULT b'1',
  PRIMARY KEY (`UserId`) USING BTREE,
  INDEX `fk1`(`DepartmentId` ASC) USING BTREE,
  CONSTRAINT `fk1` FOREIGN KEY (`DepartmentId`) REFERENCES `cdp_department` (`DepartmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_user
-- ----------------------------

-- ----------------------------
-- Table structure for auth_user_20240529
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_20240529`;
CREATE TABLE `auth_user_20240529`  (
  `UserId` int NOT NULL DEFAULT 0 COMMENT '用户ID',
  `Account` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Pwd` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ADFSPwd` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT 'ADFS密码',
  `DisplayName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `JobNumber` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DepartmentId` int NULL DEFAULT NULL,
  `Email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Team` int NULL DEFAULT NULL COMMENT '团队：1：UpStream 3：DowmStream 5：Both',
  `OnlineStatus` bit(1) NOT NULL DEFAULT b'0',
  `IsInitialPwd` bit(1) NOT NULL COMMENT '是否初始密码',
  `SigningFailCount` int NULL DEFAULT NULL,
  `PasswordEffectiveDate` datetime NULL DEFAULT NULL,
  `PasswordValidityPeriod` int NULL DEFAULT NULL,
  `PasswordExpirationDate` datetime NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `ExperimentalGroup` int NULL DEFAULT NULL COMMENT '实验组'
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户表备份20240529' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_user_20240529
-- ----------------------------

-- ----------------------------
-- Table structure for auth_userlab
-- ----------------------------
DROP TABLE IF EXISTS `auth_userlab`;
CREATE TABLE `auth_userlab`  (
  `UserLabId` int NOT NULL AUTO_INCREMENT COMMENT '用户实验室关联ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `LabId` int NOT NULL COMMENT '实验室ID',
  PRIMARY KEY (`UserLabId`) USING BTREE,
  INDEX `FK_Reference_64`(`LabId` ASC) USING BTREE,
  INDEX `FK_Reference_65`(`UserId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_65` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户实验室关联表' ROW_FORMAT = DYNAMIC;

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
  CONSTRAINT `FK_Reference_66` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户登录日志表' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户角色关联表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of auth_userrole
-- ----------------------------

-- ----------------------------
-- Table structure for awo_actionitemfu
-- ----------------------------
DROP TABLE IF EXISTS `awo_actionitemfu`;
CREATE TABLE `awo_actionitemfu`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `MainId` int NOT NULL COMMENT '关联主表ID',
  `AnomalyLevel` int NOT NULL COMMENT '异常情况等级',
  `UE` bit(1) NULL DEFAULT NULL COMMENT 'UE',
  `MEMO` bit(1) NULL DEFAULT NULL COMMENT 'MEMO',
  `CAPA` bit(1) NULL DEFAULT NULL COMMENT 'CAPA',
  `TotalActionItem` int NOT NULL DEFAULT 0 COMMENT '总行动项个数',
  `CompletedActionItem` int NOT NULL DEFAULT 0 COMMENT '已完成行动项个数',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `MainId`(`MainId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'awo-知识库类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_actionitemfu
-- ----------------------------

-- ----------------------------
-- Table structure for awo_actionitemsubitem
-- ----------------------------
DROP TABLE IF EXISTS `awo_actionitemsubitem`;
CREATE TABLE `awo_actionitemsubitem`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `ActionItemId` int NOT NULL COMMENT '关联行动项表ID',
  `Type` int NOT NULL COMMENT '1行动项、3UE、5MEMO、7CAPA',
  `ActionNo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '行动编号',
  `ActionName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '行动项名称',
  `PlanDate` date NULL DEFAULT NULL COMMENT '计划完成日期',
  `Remark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `IsClose` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否关闭',
  `IsSure` bit(1) NULL DEFAULT NULL COMMENT '是否确认',
  `CommencementDate` datetime NULL DEFAULT NULL COMMENT '生效日期',
  `ApplicationDate` datetime NOT NULL COMMENT '申请日期',
  `CompleteDate` datetime NULL DEFAULT NULL COMMENT '实际完成日期',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `ActionItemId`(`ActionItemId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '行动项子项表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_actionitemsubitem
-- ----------------------------

-- ----------------------------
-- Table structure for awo_actionsubitemreceiver
-- ----------------------------
DROP TABLE IF EXISTS `awo_actionsubitemreceiver`;
CREATE TABLE `awo_actionsubitemreceiver`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `WarningID` int NULL DEFAULT NULL COMMENT '预警ID',
  `ReceiveUserID` int NOT NULL COMMENT '接收用户ID',
  `CreateTime` datetime NOT NULL COMMENT '创建时间',
  `CreateBy` int NOT NULL DEFAULT 0 COMMENT '创建人',
  `IsDelete` bit(1) NULL DEFAULT b'0' COMMENT '是否删除',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '行动项子项接收人表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_actionsubitemreceiver
-- ----------------------------

-- ----------------------------
-- Table structure for awo_antistop
-- ----------------------------
DROP TABLE IF EXISTS `awo_antistop`;
CREATE TABLE `awo_antistop`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `ParentId` int NULL DEFAULT NULL COMMENT '父节点',
  `Type` int NOT NULL COMMENT '1大类、3中类、5小类',
  `Context` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '内容',
  `IsEnable` bit(1) NOT NULL DEFAULT b'1' COMMENT '启用状态',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '防停机分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_antistop
-- ----------------------------

-- ----------------------------
-- Table structure for awo_baseinfo
-- ----------------------------
DROP TABLE IF EXISTS `awo_baseinfo`;
CREATE TABLE `awo_baseinfo`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `MainId` int NOT NULL COMMENT '主表Id',
  `PlatformExperiment` bit(1) NULL DEFAULT NULL COMMENT '是否平台实验',
  `ProjectId` int NULL DEFAULT NULL COMMENT '项目Id',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次号',
  `CultureId` int NULL DEFAULT NULL COMMENT '培养号',
  `GroupId` int NULL DEFAULT NULL COMMENT '组',
  `AbnormalDate` datetime NULL DEFAULT NULL COMMENT '异常日期',
  `BigClass` int NOT NULL COMMENT '大类',
  `OtherBigClass` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其他大类',
  `MiddleClass` int NULL DEFAULT NULL COMMENT '中类',
  `OtherMiddleClass` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其他中类',
  `SmallClass` int NULL DEFAULT NULL COMMENT '小类',
  `OtherSmallClass` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其他小类',
  `Subject` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '主题',
  `DetailDesc` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '详情描述',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `Team` int NULL DEFAULT NULL COMMENT '团队：1upstream，3downstream,5Both',
  `IsDuplicate` bit(1) NULL DEFAULT NULL COMMENT '是否重复 1 是 /  0 否',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `MainId`(`MainId` ASC) USING BTREE,
  INDEX `BigClass`(`BigClass` ASC, `MiddleClass` ASC, `SmallClass` ASC) USING BTREE,
  INDEX `BigClass_2`(`BigClass` ASC) USING BTREE,
  INDEX `MiddleClass`(`MiddleClass` ASC) USING BTREE,
  INDEX `SmallClass`(`SmallClass` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_baseinfo
-- ----------------------------

-- ----------------------------
-- Table structure for awo_main
-- ----------------------------
DROP TABLE IF EXISTS `awo_main`;
CREATE TABLE `awo_main`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `OrderNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '错误工单号',
  `Status` int NOT NULL DEFAULT 1 COMMENT '3.进行中  5.已关闭',
  `Schedule` int NULL DEFAULT 0 COMMENT '进度 1 2 3（2/3）',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_main
-- ----------------------------

-- ----------------------------
-- Table structure for awo_option_remark
-- ----------------------------
DROP TABLE IF EXISTS `awo_option_remark`;
CREATE TABLE `awo_option_remark`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `MainID` int NULL DEFAULT NULL COMMENT '关联主表ID',
  `BaseOption` int NULL DEFAULT NULL COMMENT '1涉及的SOP/制度',
  `Option` int NULL DEFAULT NULL COMMENT '1涉及的SOP/制度',
  `Name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Remark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '选项备注表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_option_remark
-- ----------------------------

-- ----------------------------
-- Table structure for awo_permissionmaintenance
-- ----------------------------
DROP TABLE IF EXISTS `awo_permissionmaintenance`;
CREATE TABLE `awo_permissionmaintenance`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Site` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `UserId` int NOT NULL,
  `ActionItemEdit` bit(1) NOT NULL DEFAULT b'0' COMMENT '行动项编辑',
  `CloseWorkOrder` bit(1) NOT NULL DEFAULT b'0' COMMENT '关闭工单',
  `SettingPage` bit(1) NOT NULL DEFAULT b'0' COMMENT '配置页面',
  `Status` int NOT NULL DEFAULT 1 COMMENT '1.启用 3.禁用',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '权限维护表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_permissionmaintenance
-- ----------------------------

-- ----------------------------
-- Table structure for awo_principal
-- ----------------------------
DROP TABLE IF EXISTS `awo_principal`;
CREATE TABLE `awo_principal`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `CorrelationId` int NOT NULL COMMENT '基本信息ID、行动项表ID',
  `UsePage` int NULL DEFAULT NULL COMMENT '1基本信息 3.根本原因分析 5行动项跟进',
  `Type` int NULL DEFAULT NULL COMMENT '基本信息：1.第一负责人 3.第二负责人  || 行动项跟进：5.负责人',
  `UserId` int NOT NULL COMMENT '负责人',
  `UserName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `CorrelationId`(`CorrelationId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '负责人表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_principal
-- ----------------------------

-- ----------------------------
-- Table structure for awo_processanalysis
-- ----------------------------
DROP TABLE IF EXISTS `awo_processanalysis`;
CREATE TABLE `awo_processanalysis`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `ReasonAnalysisId` int NOT NULL,
  `Type` int NOT NULL COMMENT '类型(1.鱼骨图 3.Why 5.头脑风暴',
  `Proposition` int NULL DEFAULT NULL COMMENT '1人、3机、5料、7法、9环、10Q、12A 15头脑风暴',
  `Context` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '内容',
  `ContextA` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'A',
  `ContextQ` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Q',
  `PrimaryCause` bit(1) NULL DEFAULT b'0' COMMENT '是否作为根本原因 根本原因Id',
  `IsArtificial` bit(1) NULL DEFAULT b'0' COMMENT '是否人为',
  `OtherReason` int NULL DEFAULT NULL COMMENT '1根本原因 3贡献原因 5直接原因',
  `SmallRccmId` int NULL DEFAULT NULL COMMENT '小根本原因分类',
  `MiddleRccmId` int NULL DEFAULT NULL COMMENT '中根本原因分类',
  `BigRccmId` int NULL DEFAULT NULL COMMENT '大根本原因分类',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Sort` int NULL DEFAULT NULL COMMENT '顺序',
  `WhyClass` int NULL DEFAULT NULL COMMENT 'why类目',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `ReasonAnalysisId`(`ReasonAnalysisId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '过程分析表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_processanalysis
-- ----------------------------

-- ----------------------------
-- Table structure for awo_reasonanalysis
-- ----------------------------
DROP TABLE IF EXISTS `awo_reasonanalysis`;
CREATE TABLE `awo_reasonanalysis`  (
  `Id` int(11) UNSIGNED ZEROFILL NOT NULL AUTO_INCREMENT,
  `MainId` int NOT NULL,
  `IsAffectProduction` bit(1) NOT NULL DEFAULT b'0' COMMENT '异常是否影响生产',
  `Grow` bit(1) NOT NULL DEFAULT b'0' COMMENT '生长',
  `GrowRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '生长备注',
  `Metabolism` bit(1) NOT NULL DEFAULT b'0' COMMENT '代谢',
  `MetabolismRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '代谢备注',
  `Output` bit(1) NOT NULL DEFAULT b'0' COMMENT '产量',
  `OutputRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '产量备注',
  `Quality` bit(1) NOT NULL DEFAULT b'0' COMMENT '质量',
  `QualityRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '质量备注',
  `Yield` bit(1) NULL DEFAULT NULL COMMENT '收率',
  `YieldRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '收率备注',
  `MicrobialContamination` bit(1) NULL DEFAULT NULL COMMENT '微生物污染',
  `MicrobialContaminationRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '微生物污染备注',
  `ProcessPerformance` bit(1) NULL DEFAULT NULL COMMENT '工艺表现',
  `ProcessPerformanceRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '工艺表现备注',
  `SampleDelivery` bit(1) NULL DEFAULT NULL COMMENT '样品量交付',
  `SampleDeliveryRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '样品量交付备注',
  `DelayDelivery` bit(1) NULL DEFAULT NULL COMMENT '延迟交付',
  `DelayDeliveryRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '延迟交付备注',
  `OtherAffectProduction` bit(1) NOT NULL DEFAULT b'0' COMMENT '其他异常是否影响生产',
  `OtherAffectProductionRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其他异常是否影响生产备注',
  `IsProduceWaste` bit(1) NOT NULL DEFAULT b'0' COMMENT '异常是否产生浪费',
  `Manpower` bit(1) NOT NULL DEFAULT b'0' COMMENT '人力',
  `ManpowerRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '人力备注',
  `Manhour` bit(1) NOT NULL DEFAULT b'0' COMMENT '工时',
  `ManhourRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '工时备注',
  `Material` bit(1) NOT NULL DEFAULT b'0' COMMENT '物料',
  `MaterialRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '物料备注',
  `SopSystem` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'SOP/制度',
  `Timeline` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Timeline',
  `TimelineRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Timeline备注',
  `Money` bit(1) NULL DEFAULT NULL COMMENT '金额',
  `MoneyRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '金额备注',
  `OtherProduceWaste` bit(1) NOT NULL DEFAULT b'0' COMMENT '其他异常是否产生浪费',
  `OtherProduceWasteRemark` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '其他异常是否产生浪费备注',
  `FixedAssetNumber` bit(1) NOT NULL COMMENT '是否涉及设备固定资产编号',
  `FixedAssetNumberRemark` varchar(1000) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '是否涉及设备固定资产编号备注',
  `PrimaryCauseId` int NULL DEFAULT NULL COMMENT '是否作为根本原因 根本原因Id',
  `IsArtificial` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否人为',
  `Brainstorming` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '头脑风暴',
  `SmallRccmId` int NULL DEFAULT NULL COMMENT '小根本原因分类',
  `MiddleRccmId` int NULL DEFAULT NULL COMMENT '中根本原因分类',
  `BigRccmId` int NULL DEFAULT NULL COMMENT '大根本原因分类',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `FixedSOPSystem` bit(1) NULL DEFAULT b'0' COMMENT '是否涉及SOP/制度',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `MainId`(`MainId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '根本原因分析表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_reasonanalysis
-- ----------------------------

-- ----------------------------
-- Table structure for awo_recommendedsolution
-- ----------------------------
DROP TABLE IF EXISTS `awo_recommendedsolution`;
CREATE TABLE `awo_recommendedsolution`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `ReasonAnalysisId` int NOT NULL,
  `Content` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `ReasonAnalysisId`(`ReasonAnalysisId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '推荐解决方案表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_recommendedsolution
-- ----------------------------

-- ----------------------------
-- Table structure for awo_rootcausemaintenance
-- ----------------------------
DROP TABLE IF EXISTS `awo_rootcausemaintenance`;
CREATE TABLE `awo_rootcausemaintenance`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `ParentId` int NULL DEFAULT NULL COMMENT '父节点',
  `Type` int NOT NULL COMMENT '1大类、3中类、5小类',
  `Team` int NULL DEFAULT NULL COMMENT '团队：1：UpStream 3：DowmStream',
  `Context` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '内容',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '根本原因维护表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_rootcausemaintenance
-- ----------------------------

-- ----------------------------
-- Table structure for awo_takeaction
-- ----------------------------
DROP TABLE IF EXISTS `awo_takeaction`;
CREATE TABLE `awo_takeaction`  (
  `Id` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `BaseInfoId` int NOT NULL,
  `Content` varchar(600) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '内容',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `BaseInfoId`(`BaseInfoId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '采取措施表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_takeaction
-- ----------------------------

-- ----------------------------
-- Table structure for awo_upload
-- ----------------------------
DROP TABLE IF EXISTS `awo_upload`;
CREATE TABLE `awo_upload`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `CorrelationId` int NOT NULL COMMENT '基本信息ID、行动项跟进ID',
  `UsePage` int NULL DEFAULT NULL COMMENT '1基本信息 3.根本原因分析 5行动项跟进',
  `FileType` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '1.文件 3.图片 5.视频',
  `FileName` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '文件名称',
  `FileSize` double NOT NULL COMMENT '文件大小',
  `FileSizeUnit` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '文件大小单位',
  `FileUrl` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '文件地址',
  `UploadBy` int NOT NULL COMMENT '上传人',
  `UploadTime` datetime NOT NULL COMMENT '上传时间',
  PRIMARY KEY (`Id`) USING BTREE,
  INDEX `CorrelationId`(`CorrelationId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '附件上传表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_upload
-- ----------------------------

-- ----------------------------
-- Table structure for awo_warningsetting
-- ----------------------------
DROP TABLE IF EXISTS `awo_warningsetting`;
CREATE TABLE `awo_warningsetting`  (
  `Id` int NOT NULL AUTO_INCREMENT,
  `AdvancedDay` decimal(10, 2) NULL DEFAULT NULL COMMENT '提前几天预警',
  `IntervalDay` decimal(10, 2) NULL DEFAULT NULL COMMENT '每隔 多少 天',
  `IntervalTime` time NULL DEFAULT NULL COMMENT '每天 几时几分几秒',
  `AfterExpirationTime` time NULL DEFAULT NULL COMMENT '过期后每天 时分秒时间 报警一次',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `AfterConfirmTime` time NULL DEFAULT NULL COMMENT '行动项确认报警',
  PRIMARY KEY (`Id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '预警设置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of awo_warningsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch`;
CREATE TABLE `cdp_batch`  (
  `BatchID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `PreCultureID` int NOT NULL COMMENT '主键',
  `EquReactorId` int NOT NULL COMMENT '罐体ID',
  `EquFeedingScaleId` int NOT NULL COMMENT '液袋地秤ID',
  `MediumLotNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ReactorTareWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '皮重',
  `ReactorRoughWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '毛重',
  `ReactorNetVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '净容量',
  `PumpingRealVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '实际泵液量',
  `MediumVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '培养基液量',
  `CurrentVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '反应器 液体净重',
  `CurrentBGAPH` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CurrentVCD` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CurrentViability` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CurrentOSMO` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CurrentCedexGlucoseTime` datetime NULL DEFAULT NULL COMMENT '当前葡萄糖浓度检测时间',
  `CurrentCedexGlucose` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '当前葡萄糖浓度',
  `CurrentCedexLactate` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '乳酸量',
  `CurrentCedexLactateTime` datetime NULL DEFAULT NULL COMMENT '理论乳酸溶度推算时间',
  `CedexGlucoseTheoreticalTime` datetime NULL DEFAULT NULL COMMENT '理论糖浓度推算时间',
  `CedexGlucoseTheoreticalValue` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '理论糖浓度',
  `CurrentCedexNH4` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CurrentCedexIGGHB` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CurrentGlucoseWeight` decimal(18, 10) NULL DEFAULT NULL COMMENT '当前罐体中糖的重量g',
  `ErrorCode` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '批次执行错误码',
  `Mode` int NULL DEFAULT NULL COMMENT '1:Automatic\r\n            3:Maunal',
  `Status` int NULL DEFAULT 3 COMMENT '1.用户创建新批次\r\n\r\n3. 编辑初始培养体积\r\n4. 报警信息确认\r\n\r\n7.生产中\r\n9.收获中\r\n11.生产完成\r\n99.取消',
  `GroupName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `GroupNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `GroupPrincipalId` int NULL DEFAULT NULL,
  `StartBatchTime` datetime NULL DEFAULT NULL,
  `StartBatchUser` int NULL DEFAULT NULL,
  `InoculationTime` datetime NULL DEFAULT NULL COMMENT '接种时间',
  `InoculationUser` int NULL DEFAULT NULL COMMENT '接种用户',
  `SupplementaryUnitTime` datetime NULL DEFAULT NULL COMMENT '补液时间',
  `SupplementaryUser` int NULL DEFAULT NULL COMMENT '补液用户',
  `CompleteTime` datetime NULL DEFAULT NULL COMMENT '完成时间',
  `CompleteUser` int NULL DEFAULT NULL COMMENT '完成用户',
  `TerminationTime` datetime NULL DEFAULT NULL COMMENT '终止时间',
  `TerminationUser` int NULL DEFAULT NULL COMMENT '终止用户',
  `MonitorStatus` int NULL DEFAULT NULL COMMENT '监控状态 监控中  null或者1，临时关闭  3，长期关闭 5',
  `MonitorRemark` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '监控备注',
  PRIMARY KEY (`BatchID`) USING BTREE,
  INDEX `FK_Reference_68`(`WorkflowID` ASC) USING BTREE,
  INDEX `FK_Reference_73`(`PreCultureID` ASC) USING BTREE,
  CONSTRAINT `cdp_batch_ibfk_1` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_73` FOREIGN KEY (`PreCultureID`) REFERENCES `cdp_preculture` (`PreCultureID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '批次表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_airpumpexecrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_airpumpexecrecord`;
CREATE TABLE `cdp_batch_airpumpexecrecord`  (
  `ExecID` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `BatchID` int NOT NULL COMMENT 'BatchID',
  `AirPumpID` int NOT NULL COMMENT '空气泵id',
  `SetSpeed` decimal(18, 2) NOT NULL COMMENT '下发泵速',
  `ExecStatus` bit(1) NOT NULL COMMENT '执行状态 成功或者失败',
  `Date` datetime NOT NULL COMMENT '执行日期',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`ExecID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次不了的空气泵执行记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_airpumpexecrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_cultureparam
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_cultureparam`;
CREATE TABLE `cdp_batch_cultureparam`  (
  `CultureParamId` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `BatchId` int NOT NULL,
  `ReactorTareWeight` decimal(18, 2) NOT NULL COMMENT '皮重',
  `MediumVolume` decimal(18, 2) NOT NULL COMMENT '初始培养体积',
  `ConfirmUserID` int NULL DEFAULT NULL COMMENT '确认人id',
  `ConfirmTime` datetime NULL DEFAULT NULL COMMENT '确认时间',
  `ConfirmUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '确认链接',
  `ApproveUserID` int NULL DEFAULT NULL COMMENT '审核人id',
  `ApproveTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `ApproveUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '审核链接',
  `AbortUserID` int NULL DEFAULT NULL COMMENT '拒绝人id',
  `AbortTime` datetime NULL DEFAULT NULL COMMENT '拒绝人时间',
  `AbortUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '拒绝人链接',
  `Status` int NULL DEFAULT NULL COMMENT '状态 1 审核中  3 已通过  5 已拒绝',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除',
  `Type` int NULL DEFAULT 0 COMMENT '类型',
  `CultureCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`CultureParamId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次培养的参数' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_cultureparam
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_feeding_manualrec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_feeding_manualrec`;
CREATE TABLE `cdp_batch_feeding_manualrec`  (
  `BatchFeedingManualRecID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `EquPumpId` int NULL DEFAULT NULL,
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingMediumID` int NULL DEFAULT NULL COMMENT 'ID',
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `ConfirmUserID` int NULL DEFAULT NULL,
  `ConfirmUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '确认签名图片地址',
  `ConfirmTime` datetime NULL DEFAULT NULL,
  `ReviewUserID` int NULL DEFAULT NULL,
  `ReviewUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '审核签名图片地址',
  `ReviewTime` datetime NULL DEFAULT NULL,
  `StartUserID` int NULL DEFAULT NULL,
  `StartTimeMT` bigint NULL DEFAULT NULL,
  `EndTimeMT` bigint NULL DEFAULT NULL,
  `ReactorWeightFeedingBefore` decimal(18, 2) NULL DEFAULT NULL,
  `TotalFeedingTime` int NULL DEFAULT NULL COMMENT 'ms',
  `TotalFeedingRealVolume` decimal(18, 2) NULL DEFAULT NULL,
  `ReactorWeightFeedingAfter` decimal(18, 2) NULL DEFAULT NULL,
  `AbortUserID` int NULL DEFAULT NULL,
  `AbortTime` datetime NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '7：Executing\r\n            9：Executed\r\n            99: Canceled/Abort',
  PRIMARY KEY (`BatchFeedingManualRecID`) USING BTREE,
  INDEX `FK_Reference_95`(`BatchID` ASC) USING BTREE,
  INDEX `FK_Reference_102`(`EquPumpId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_100` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_102` FOREIGN KEY (`EquPumpId`) REFERENCES `cdp_equpump` (`EquPumpId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次手动补料记录----暂时无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_feeding_manualrec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_feedingglucoseautorec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_feedingglucoseautorec`;
CREATE TABLE `cdp_batch_feedingglucoseautorec`  (
  `FeedingGlucoseAutTaskID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingMediumID` int NULL DEFAULT NULL COMMENT 'ID',
  `GlucoseFeedingBefore` decimal(18, 2) NULL DEFAULT NULL,
  `CedexSampleID` int NULL DEFAULT NULL,
  `ReactorWeightFeedingBefore` decimal(18, 2) NULL DEFAULT NULL,
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `TotalFeedingTime` int NULL DEFAULT NULL COMMENT 'ms',
  `TotalFeedingRealVolume` decimal(18, 2) NULL DEFAULT NULL,
  `ReactorWeightFeedingAfter` decimal(18, 2) NULL DEFAULT NULL,
  `CultureDay` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent            3:Feeding By Volume',
  `LowerLimit` int NULL DEFAULT NULL COMMENT 'g/L',
  `FeedingTo` int NULL DEFAULT NULL COMMENT 'g/L',
  `LowerLimitOperator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '< || <=',
  `Status` int NOT NULL COMMENT '7：Executing            9：Executed            99:Canceled',
  PRIMARY KEY (`FeedingGlucoseAutTaskID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '手动糖补料记录----暂时无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_feedingglucoseautorec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_fixedfeedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_fixedfeedingtask`;
CREATE TABLE `cdp_batch_fixedfeedingtask`  (
  `BatchTaskID` int NOT NULL AUTO_INCREMENT,
  `TaskNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `ConfigId` int NULL DEFAULT NULL COMMENT '策略ID',
  `SoureType` int NULL DEFAULT NULL COMMENT '1:Protocol\r\n 3:User Creation   \r\n5:SubSystem Insert\r\n7.异常处理新增',
  `Mode` int NOT NULL DEFAULT 1 COMMENT '1:Automatic\r\n            3:Maunal',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingMediumID` int NULL DEFAULT NULL COMMENT 'ID',
  `FeedingTime` datetime NOT NULL COMMENT 'ID',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n            3:Feeding By Volume',
  `FeedingVolumePercent` decimal(18, 3) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingTimeOut` int NULL DEFAULT NULL,
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
  `ReactorWeightFeedingBefore` decimal(18, 2) NULL DEFAULT NULL,
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `TotalFeedingTime` int NULL DEFAULT NULL COMMENT 's',
  `TotalFeedingRealVolume` decimal(18, 2) NULL DEFAULT NULL,
  `ReactorWeightFeedingAfter` decimal(18, 2) NULL DEFAULT NULL,
  `CurrentVolumeBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料前净重',
  `CurrentVolumeAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料后净重',
  `GlucoseWeightBefore` decimal(18, 10) NULL DEFAULT NULL COMMENT '补料前糖重量',
  `GlucoseWeightAfter` decimal(18, 10) NULL DEFAULT NULL COMMENT '补料后糖重量',
  `Status` int NOT NULL COMMENT '1：Pending Review\r\n2：Pending Cancel\r\n3：Pending Approve\r\n5：Pending Execute\r\n7：Executing\r\n9：执行出错\r\n11：执行出错已处理       \r\n17：Skiped\r\n19：Executed\r\n99: Canceled',
  `AbnormalCause` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '异常原因',
  `CreateCause` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '创建原因',
  `AbnormalCompleteVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '异常时完成的重量',
  `FeedingExpectTime` int NULL DEFAULT NULL COMMENT '预计补料耗时（手动用）',
  `ExtraFeedingMode` int NULL DEFAULT NULL COMMENT '额外策略ID',
  `FeedingErrorVolumnPercent` decimal(18, 0) NULL DEFAULT NULL COMMENT '补料量误差比例',
  `FeedingPumpSpeedMode` int NULL DEFAULT NULL COMMENT '泵速方案(1-二段式，3-三段式)',
  `FeedingPumpSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT '泵速(g/min)',
  `RelationBatchTaskID` int NULL DEFAULT NULL COMMENT '关联上料批次',
  `ErrorNeedFeedingVolumn` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料异常需要补料量',
  `OldConfigId` int NULL DEFAULT NULL COMMENT '之前的ConfigId',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchTaskID`) USING BTREE,
  INDEX `FK_Reference_90`(`BatchID` ASC) USING BTREE,
  INDEX `TaskNo`(`TaskNo` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_90` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料任务规则' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_fixedfeedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_fixedfeedingtask_approvalrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_fixedfeedingtask_approvalrecord`;
CREATE TABLE `cdp_batch_fixedfeedingtask_approvalrecord`  (
  `ApprovalRecordID` int NOT NULL AUTO_INCREMENT COMMENT '审批记录ID',
  `BatchTaskID` int NOT NULL COMMENT '补料任务ID',
  `HandleErrorUserID` int NULL DEFAULT NULL COMMENT '处理错误用戶ID',
  `HandleErrorTime` datetime NULL DEFAULT NULL COMMENT '处理错误时间',
  `ApprovalUserID` int NULL DEFAULT NULL COMMENT '审批用戶ID',
  `ApprovalTime` datetime NULL DEFAULT NULL COMMENT '审批时间',
  `CancelUserID` int NULL DEFAULT NULL COMMENT '取消用戶ID',
  `CancelTime` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ApprovalRecordID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料审批记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_fixedfeedingtask_approvalrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_fixedfeedingtask_execution
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_fixedfeedingtask_execution`;
CREATE TABLE `cdp_batch_fixedfeedingtask_execution`  (
  `ExecuteId` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NOT NULL COMMENT '关联细胞培养id',
  `BatchTaskID` int NOT NULL COMMENT '关联喂料任务id',
  `ReactorInitialWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '罐体初始重量g',
  `FeedScaleInitialWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料地秤初始重量g',
  `BagInitialWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '操作液袋初始重量g',
  `ExeNumber` decimal(18, 2) NULL DEFAULT NULL COMMENT '已执行完成重量g',
  `TotalExeNumber` decimal(18, 2) NULL DEFAULT NULL COMMENT '目标执行总重量g',
  `StartTime` datetime NULL DEFAULT NULL COMMENT '开始时间',
  `EndTime` datetime NULL DEFAULT NULL COMMENT '结束时间',
  `Finished` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否完成',
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ExecuteId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料执行记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_fixedfeedingtask_execution
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_batch_fixedfeedingtask_log
-- ----------------------------
DROP TABLE IF EXISTS `cdp_batch_fixedfeedingtask_log`;
CREATE TABLE `cdp_batch_fixedfeedingtask_log`  (
  `BatchTaskLogID` int NOT NULL AUTO_INCREMENT,
  `BatchTaskID` int NULL DEFAULT NULL,
  `OperateType` int NULL DEFAULT NULL,
  `OperateTypeStr` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `NowStatus` int NULL DEFAULT NULL COMMENT '当前状态',
  `Cause` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BatchTaskLogID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料执行记录日志' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_batch_fixedfeedingtask_log
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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '暂时无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_coderule
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_cultureprotocol
-- ----------------------------
DROP TABLE IF EXISTS `cdp_cultureprotocol`;
CREATE TABLE `cdp_cultureprotocol`  (
  `CultureProtocolId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `CultureProtocolName` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '培养方案名称',
  `EquReactorId` int NULL DEFAULT NULL COMMENT '反应器id',
  `EquFeedingScaleId` int NULL DEFAULT NULL COMMENT '补料地秤id',
  `Days` int NULL DEFAULT NULL COMMENT '天数',
  `InitialWorkingVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '初始体积',
  `InitialWorkingMediumId` int NULL DEFAULT NULL COMMENT '初始培养基id',
  `TransferCellVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '转移细胞容量',
  `TransferCellTypeId` int NULL DEFAULT NULL COMMENT '转移细胞类型',
  `ExperimentalGroupId` int NULL DEFAULT NULL COMMENT '用户ID',
  `GlucoseFeedingVerification` bit(1) NULL DEFAULT NULL COMMENT '糖补料确认',
  `Remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '备注',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`CultureProtocolId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_cultureprotocol
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_cultureprotocol_autoglucosefeedingrule
-- ----------------------------
DROP TABLE IF EXISTS `cdp_cultureprotocol_autoglucosefeedingrule`;
CREATE TABLE `cdp_cultureprotocol_autoglucosefeedingrule`  (
  `ProtocolAutoGlucoseFeedingRuleID` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `CultureProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `CultureDayStarting` tinyint NOT NULL COMMENT '开始第几天',
  `CultureDayEnding` tinyint NOT NULL COMMENT '结束第几天',
  `LowerLimit` decimal(18, 2) NOT NULL COMMENT 'g/L',
  `FeedingTo` decimal(18, 2) NOT NULL COMMENT 'g/L',
  `LowerLimitOperator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '1: < 2:<=',
  `CalculationMode` int NULL DEFAULT 1 COMMENT '计算模式 1：残糖 3：残糖和乳酸',
  PRIMARY KEY (`ProtocolAutoGlucoseFeedingRuleID`) USING BTREE,
  INDEX `FK_Reference_138`(`CultureProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_138` FOREIGN KEY (`CultureProtocolId`) REFERENCES `cdp_cultureprotocol` (`CultureProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案--自动补糖规则' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_cultureprotocol_autoglucosefeedingrule
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_cultureprotocol_feedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_cultureprotocol_feedingtask`;
CREATE TABLE `cdp_cultureprotocol_feedingtask`  (
  `ProtocolFeedingTaskId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `CultureProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `Day` int NOT NULL COMMENT 'ID',
  `FeedingTime` time NULL DEFAULT NULL,
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n            3:Feeding By Volume',
  `FeedingVolumePercent` decimal(18, 3) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolFeedingTaskId`) USING BTREE,
  INDEX `FK_Reference_101`(`CultureProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_101` FOREIGN KEY (`CultureProtocolId`) REFERENCES `cdp_cultureprotocol` (`CultureProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案---固定补料泵任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_cultureprotocol_feedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_cultureprotocol_fixedfeedingpump
-- ----------------------------
DROP TABLE IF EXISTS `cdp_cultureprotocol_fixedfeedingpump`;
CREATE TABLE `cdp_cultureprotocol_fixedfeedingpump`  (
  `ProtocolFixedFeedingPumpId` int NOT NULL AUTO_INCREMENT COMMENT '固定补料泵ID',
  `CultureProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `ConfigId` int NULL DEFAULT NULL COMMENT '策略ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `ItemDefBagID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `EquPumpId` int NULL DEFAULT NULL COMMENT '外置泵ID',
  PRIMARY KEY (`ProtocolFixedFeedingPumpId`) USING BTREE,
  INDEX `FK_Reference_132`(`ItemDefBagID` ASC) USING BTREE,
  INDEX `FK_Reference_133`(`ItemDefFeedingMediumID` ASC) USING BTREE,
  INDEX `FK_Reference_96`(`CultureProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_132` FOREIGN KEY (`ItemDefBagID`) REFERENCES `cdp_item_def_bag` (`ItemDefBagID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_133` FOREIGN KEY (`ItemDefFeedingMediumID`) REFERENCES `cdp_item_def_feedingmedium` (`ItemDefFeedingMediumID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_96` FOREIGN KEY (`CultureProtocolId`) REFERENCES `cdp_cultureprotocol` (`CultureProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案---固定补料泵设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_cultureprotocol_fixedfeedingpump
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_cultureprotocol_otherfeedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_cultureprotocol_otherfeedingtask`;
CREATE TABLE `cdp_cultureprotocol_otherfeedingtask`  (
  `ProtocolOtherFeedingTaskId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `CultureProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `EquPumpId` int NULL DEFAULT NULL,
  `Day` int NOT NULL COMMENT 'ID',
  `FeedingTime` time NULL DEFAULT NULL,
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n            3:Feeding By Volume',
  `FeedingVolumePercent` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `PreRemindingTime` int NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolOtherFeedingTaskId`) USING BTREE,
  INDEX `FK_Reference_137`(`CultureProtocolId` ASC) USING BTREE,
  INDEX `FK_Reference_139`(`ItemDefFeedingMediumID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_137` FOREIGN KEY (`CultureProtocolId`) REFERENCES `cdp_cultureprotocol` (`CultureProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_139` FOREIGN KEY (`ItemDefFeedingMediumID`) REFERENCES `cdp_item_def_feedingmedium` (`ItemDefFeedingMediumID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '暂时无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_cultureprotocol_otherfeedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_db_versions
-- ----------------------------
DROP TABLE IF EXISTS `cdp_db_versions`;
CREATE TABLE `cdp_db_versions`  (
  `VersionId` int NOT NULL AUTO_INCREMENT COMMENT '版本ID',
  `BackFileName` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `BackTime` datetime NULL DEFAULT NULL,
  `MajorNumber` int NOT NULL DEFAULT 0,
  `MinorNumber` int NOT NULL DEFAULT 0,
  `RevisionNumber` int NOT NULL DEFAULT 0,
  `BuildNumber` int NOT NULL DEFAULT 0,
  `FullVersion` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`VersionId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置--关于系统--更新数据库版本' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_db_versions
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_department
-- ----------------------------
DROP TABLE IF EXISTS `cdp_department`;
CREATE TABLE `cdp_department`  (
  `DepartmentId` int NOT NULL AUTO_INCREMENT COMMENT '部门ID',
  `DepartmentName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DepartmentCode` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Description` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`DepartmentId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---部门设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_department
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_description
-- ----------------------------
DROP TABLE IF EXISTS `cdp_description`;
CREATE TABLE `cdp_description`  (
  `DescriptionID` int NOT NULL AUTO_INCREMENT COMMENT '描述ID',
  `DescriptionType` int NOT NULL COMMENT 'Description类型：1：Weight 、 3：Filter',
  `Description` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '描述内容',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '状态',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`DescriptionID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---描述管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_description
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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---字典' ROW_FORMAT = DYNAMIC;

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
  `DictDtlName` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '字典明细名称',
  `SortNo` int NULL DEFAULT NULL COMMENT '排序',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`DictDtlId`) USING BTREE,
  INDEX `FK_Reference_62`(`DictId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_62` FOREIGN KEY (`DictId`) REFERENCES `cdp_dict` (`DictId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---字典子表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_dictdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_agitation_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_agitation_rec`;
CREATE TABLE `cdp_ep_agitation_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '在线数据（所有）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_agitation_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_agitation_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_agitation_stat`;
CREATE TABLE `cdp_ep_agitation_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '在线数据（临时）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_agitation_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_airoverlayflowrate_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_airoverlayflowrate_rec`;
CREATE TABLE `cdp_ep_airoverlayflowrate_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_AirOverlayFlowRate_Rec_126`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_AirOverlayFlowRate_Rec_128`(`EPSettingId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_AirOverlayFlowRate_Rec_126` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_AirOverlayFlowRate_Rec_128` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '在线数据airoverlayflowrate-------weight是分类型的在线数据。建议改成分时间建表。\r\nrec_current单独拎出（所有反应器当前最新值）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_airoverlayflowrate_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_airoverlayflowrate_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_airoverlayflowrate_stat`;
CREATE TABLE `cdp_ep_airoverlayflowrate_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_airoverlayflowrate_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_airspargerflowrate_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_airspargerflowrate_rec`;
CREATE TABLE `cdp_ep_airspargerflowrate_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_125`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_AirSpargerFlowRate_127`(`EPSettingId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_125` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_AirSpargerFlowRate_127` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_airspargerflowrate_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_airspargerflowrate_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_airspargerflowrate_stat`;
CREATE TABLE `cdp_ep_airspargerflowrate_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '空气分布器流量统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_airspargerflowrate_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_co2flowrate_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_co2flowrate_rec`;
CREATE TABLE `cdp_ep_co2flowrate_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_117`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_119`(`EPSettingId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_117` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_119` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_co2flowrate_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_co2flowrate_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_co2flowrate_stat`;
CREATE TABLE `cdp_ep_co2flowrate_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'CO₂流量统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_co2flowrate_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_do_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_do_rec`;
CREATE TABLE `cdp_ep_do_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_59`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_112`(`EquReactorId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_112` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_122` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '溶解氧统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_do_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate2_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate2_rec`;
CREATE TABLE `cdp_ep_oxygenflowrate2_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_114`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_120`(`EPSettingId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
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
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '氧气流量2统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate2_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate_rec`;
CREATE TABLE `cdp_ep_oxygenflowrate_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_114`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_120`(`EPSettingId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_114` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_120` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowrate_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowrate_stat`;
CREATE TABLE `cdp_ep_oxygenflowrate_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '氧气流量统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowrate_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowratemicro_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowratemicro_rec`;
CREATE TABLE `cdp_ep_oxygenflowratemicro_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_114`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_120`(`EPSettingId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowratemicro_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_oxygenflowratemicro_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_oxygenflowratemicro_stat`;
CREATE TABLE `cdp_ep_oxygenflowratemicro_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '微氧流量统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_oxygenflowratemicro_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_ph_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_ph_rec`;
CREATE TABLE `cdp_ep_ph_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_111` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_121` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_ph_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_ph_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_ph_stat`;
CREATE TABLE `cdp_ep_ph_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'pH统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_ph_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pressure_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pressure_rec`;
CREATE TABLE `cdp_ep_pressure_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_115`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_123`(`EPSettingId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_115` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_123` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pressure_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pressure_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pressure_stat`;
CREATE TABLE `cdp_ep_pressure_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '压力统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pressure_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump1_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump1_rec`;
CREATE TABLE `cdp_ep_pump1_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
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
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '泵1统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump1_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump2_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump2_rec`;
CREATE TABLE `cdp_ep_pump2_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
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
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '泵2统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump2_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump3_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump3_rec`;
CREATE TABLE `cdp_ep_pump3_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
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
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '泵3统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump3_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_pump4_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_pump4_rec`;
CREATE TABLE `cdp_ep_pump4_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE,
  INDEX `RecordTime`(`RecordTime` ASC) USING BTREE
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
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `RecTime` datetime NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '泵4统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_pump4_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_rec_current
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_rec_current`;
CREATE TABLE `cdp_ep_rec_current`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '所有反应器当前最新值\r\n\r\nEquReactorId  EPSettingId  区分反应器、数据类' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_rec_current
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_rec_currentv2
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_rec_currentv2`;
CREATE TABLE `cdp_ep_rec_currentv2`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_111`(`EquReactorId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '实时记录表V2' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_rec_currentv2
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_temp_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_temp_rec`;
CREATE TABLE `cdp_ep_temp_rec`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecId`) USING BTREE,
  INDEX `FK_Reference_113`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_124`(`EPSettingId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_113` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_124` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_temp_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_temp_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_temp_stat`;
CREATE TABLE `cdp_ep_temp_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '温度统计表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_temp_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_weight_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_weight_rec`;
CREATE TABLE `cdp_ep_weight_rec`  (
  `EPRecID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `Value` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '值',
  `RecordTime` datetime NULL DEFAULT NULL COMMENT '记录时间',
  PRIMARY KEY (`EPRecID`) USING BTREE,
  INDEX `FK_Reference_55`(`EPSettingId` ASC) USING BTREE,
  INDEX `FK_Reference_116`(`EquReactorId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_116` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_118` FOREIGN KEY (`EPSettingId`) REFERENCES `cdp_epsetting` (`EPSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_weight_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_ep_weight_stat
-- ----------------------------
DROP TABLE IF EXISTS `cdp_ep_weight_stat`;
CREATE TABLE `cdp_ep_weight_stat`  (
  `EPRecId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPSettingId` int NULL DEFAULT NULL COMMENT 'ID',
  `PeriodCode` datetime NOT NULL,
  `MaxVal` decimal(8, 2) NOT NULL COMMENT '值',
  `MaxValTime` datetime NOT NULL COMMENT '记录时间',
  `MinVal` decimal(8, 2) NOT NULL,
  `MinValTime` datetime NOT NULL,
  `Value` int NULL DEFAULT NULL,
  `RecordTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPRecId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '在线数据airoverlayflowrate-------weight是分类型的在线数据。建议改成分时间建表。' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_ep_weight_stat
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epdef
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epdef`;
CREATE TABLE `cdp_epdef`  (
  `EPDefID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EPNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'Code',
  `EPName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '名称',
  `NeedConfig` bit(1) NULL DEFAULT NULL,
  `Sort` int NULL DEFAULT NULL,
  `UpperLimit` decimal(10, 0) NULL DEFAULT NULL,
  `LowerLimit` decimal(10, 0) NULL DEFAULT NULL,
  `Unit` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '单位',
  `Status` bit(1) NOT NULL COMMENT '状态: 0 正常 1 删除',
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EPDefID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '在线参数定义----动态设置agitation-weight' ROW_FORMAT = DYNAMIC;

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
  `EPDefAlias` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '别名',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `WarningLowerBuffer` int NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT '记录时间',
  `WarningUpperBuffer` int NULL DEFAULT NULL,
  `WarningTimeBuffer` int NULL DEFAULT NULL,
  `ActioLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionUpperLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionTimeBuffer` int NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '记录修改人ID',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '记录修改时间',
  PRIMARY KEY (`EPSettingId`) USING BTREE,
  INDEX `FK_Reference_14`(`EPDefId` ASC) USING BTREE,
  CONSTRAINT `cdp_epsetting_ibfk_1` FOREIGN KEY (`EPDefId`) REFERENCES `cdp_epdef` (`EPDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '通用报警设置----参数指标上下限' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epsetting_batch
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epsetting_batch`;
CREATE TABLE `cdp_epsetting_batch`  (
  `EPSettingId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `RecordNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '记录编号 20230612142401',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPDefId` int NOT NULL COMMENT 'ID',
  `EPDefAlias` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '别名',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次ID',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `WarningLowerBuffer` int NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT '记录时间',
  `WarningUpperBuffer` int NULL DEFAULT NULL,
  `ActioLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionUpperLimit` decimal(18, 2) NULL DEFAULT NULL,
  `IsEnable` bit(1) NULL DEFAULT NULL COMMENT '是否启用',
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  PRIMARY KEY (`EPSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '批次报警设置----参数指标上下限' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epsetting_batch
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epsetting_equreactor
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epsetting_equreactor`;
CREATE TABLE `cdp_epsetting_equreactor`  (
  `EPSettingId` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EPDefId` int NOT NULL COMMENT 'ID',
  `EPDefAlias` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '别名',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `WarningLowerBuffer` int NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT '记录时间',
  `WarningUpperBuffer` int NULL DEFAULT NULL,
  `ActioLowerLimit` decimal(18, 2) NULL DEFAULT NULL,
  `ActionUpperLimit` decimal(18, 2) NULL DEFAULT NULL,
  `IsEnable` bit(1) NULL DEFAULT NULL COMMENT '是否启用',
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  PRIMARY KEY (`EPSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '反应器报警设置----参数指标上下限' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epsetting_equreactor
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_epyaxissetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_epyaxissetting`;
CREATE TABLE `cdp_epyaxissetting`  (
  `EPYaxisSettingId` int NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `UserID` int NULL DEFAULT NULL COMMENT '用户ID',
  `EpDefId` int NULL DEFAULT NULL COMMENT '外键ID',
  `MinY` decimal(18, 3) NULL DEFAULT NULL COMMENT '最小值',
  `MaxY` decimal(18, 3) NULL DEFAULT NULL COMMENT '最大值',
  `IsDelete` bit(1) NULL DEFAULT NULL,
  `Create_by` int NULL DEFAULT NULL COMMENT '创建人ID',
  `Create_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '更新人ID',
  `Last_updated_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`EPYaxisSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '在线指标的y轴。' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_epyaxissetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibration
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibration`;
CREATE TABLE `cdp_equ_calibration`  (
  `EquipmentCalibrationID` int NOT NULL AUTO_INCREMENT COMMENT '校准主表主键',
  `EquipmentId` int NOT NULL COMMENT '关联设备Id',
  `CalibrationType` int NOT NULL DEFAULT 1 COMMENT '校准类型\r\n1. Weight\r\n3. Multiparameter - pH\r\n5. Multiparameter - pH Ver\r\n7. Multiparameter - Conductivity',
  `CalibrationDate` date NOT NULL COMMENT '校准日期',
  `Status` int NOT NULL COMMENT '1：完成通过，3：完成失败 5：进行中，7：清空',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`EquipmentCalibrationID`) USING BTREE,
  INDEX `fkCDP_Equ_Calibration1`(`EquipmentId` ASC) USING BTREE,
  CONSTRAINT `fkCDP_Equ_Calibration1` FOREIGN KEY (`EquipmentId`) REFERENCES `cdp_equipment` (`EquipmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibration
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationcellconstant_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationcellconstant_dtl`;
CREATE TABLE `cdp_equ_calibrationcellconstant_dtl`  (
  `CellConstantDtlID` int NOT NULL AUTO_INCREMENT,
  `EquipmentCalibrationID` int NOT NULL COMMENT '校准记录ID',
  `StandardCond` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准液',
  `ValueStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '结果',
  `Value` decimal(18, 7) NULL DEFAULT NULL COMMENT '结果',
  `CellConstantMin` decimal(18, 7) NULL DEFAULT NULL COMMENT '电极常数最小值',
  `CellConstantMax` decimal(18, 7) NULL DEFAULT NULL COMMENT '电极常数最大值',
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`CellConstantDtlID`) USING BTREE,
  INDEX `fk_EquipmentCalibrationID001`(`EquipmentCalibrationID` ASC) USING BTREE,
  CONSTRAINT `fk_EquipmentCalibrationID001` FOREIGN KEY (`EquipmentCalibrationID`) REFERENCES `cdp_equ_calibration` (`EquipmentCalibrationID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准--电极常数' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationcellconstant_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationph_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationph_dtl`;
CREATE TABLE `cdp_equ_calibrationph_dtl`  (
  `PHCalibrationDtlID` int NOT NULL AUTO_INCREMENT,
  `EquipmentCalibrationID` int NOT NULL,
  `StandardSolution` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准液',
  `mVStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电压',
  `mV` decimal(18, 2) NULL DEFAULT NULL COMMENT '电压',
  `TempStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '温度',
  `Temp` decimal(18, 2) NULL DEFAULT NULL COMMENT '温度',
  `SlopeStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '斜率',
  `Slope` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率',
  `OffsetStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '偏移量',
  `Offset` decimal(18, 2) NULL DEFAULT NULL COMMENT '偏移量',
  `SlopeMin` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率最小值',
  `SlopeMax` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率最大值',
  `OffsetMin` decimal(18, 2) NULL DEFAULT NULL COMMENT '偏移量最小值',
  `OffsetMax` decimal(18, 2) NULL DEFAULT NULL COMMENT '偏移量最大值',
  `Status` bit(1) NOT NULL COMMENT '状态',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`PHCalibrationDtlID`) USING BTREE,
  INDEX `CalibrationID`(`EquipmentCalibrationID` ASC) USING BTREE,
  CONSTRAINT `cdp_equ_calibrationph_dtl_ibfk_1` FOREIGN KEY (`EquipmentCalibrationID`) REFERENCES `cdp_equ_calibration` (`EquipmentCalibrationID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准--ph--记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationph_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationphver_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationphver_dtl`;
CREATE TABLE `cdp_equ_calibrationphver_dtl`  (
  `PHVerificationDtlID` int NOT NULL AUTO_INCREMENT,
  `EquipmentCalibrationID` int NOT NULL COMMENT '校准记录ID',
  `StandardSolutionID` int NULL DEFAULT NULL COMMENT '校准液',
  `ValueStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '结果',
  `Value` decimal(18, 2) NULL DEFAULT NULL COMMENT '结果',
  `TempStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '温度',
  `Temp` decimal(18, 2) NULL DEFAULT NULL COMMENT '温度',
  `VerificationMin` decimal(18, 2) NULL DEFAULT NULL COMMENT '校验最小值',
  `VerificationMax` decimal(18, 2) NULL DEFAULT NULL COMMENT '校验最大值',
  `Status` bit(1) NOT NULL,
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`PHVerificationDtlID`) USING BTREE,
  INDEX `CalibrationID`(`EquipmentCalibrationID` ASC) USING BTREE,
  CONSTRAINT `cdp_equ_calibrationphver_dtl_ibfk_1` FOREIGN KEY (`EquipmentCalibrationID`) REFERENCES `cdp_equ_calibration` (`EquipmentCalibrationID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准--ph--无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationphver_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationscale_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationscale_dtl`;
CREATE TABLE `cdp_equ_calibrationscale_dtl`  (
  `CalibrationDtlID` int NOT NULL AUTO_INCREMENT,
  `EquipmentId` int NOT NULL COMMENT '关联设备ID',
  `ScaleCalibrationID` int NOT NULL COMMENT '主表关联字段',
  `CounterWeightID` int NOT NULL COMMENT '关联砝码id',
  `MinNetWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '允许偏差最低重量',
  `MaxNetWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '允许偏差最高重量',
  `NetWeight` decimal(18, 2) NOT NULL COMMENT '校准实际重量',
  `NetWeightStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准实际重量中文',
  `Unit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准数据单位',
  `Status` bit(1) NOT NULL COMMENT '是否有效 0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`CalibrationDtlID`) USING BTREE,
  INDEX `ScaleCalibrationID`(`ScaleCalibrationID` ASC) USING BTREE,
  CONSTRAINT `ScaleCalibrationID` FOREIGN KEY (`ScaleCalibrationID`) REFERENCES `cdp_equ_calibration` (`EquipmentCalibrationID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准--称重设备--记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationscale_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationsetting`;
CREATE TABLE `cdp_equ_calibrationsetting`  (
  `CalibrationSettingId` int NOT NULL AUTO_INCREMENT,
  `EquipmentId` int NOT NULL COMMENT '设备ID',
  `ExpireDays` int NULL DEFAULT NULL COMMENT '过期天数',
  `StandardSolutionID` int NULL DEFAULT NULL COMMENT '标准液\r\n1.  2.0\r\n3.  4.01\r\n5.  7.00\r\n7.  9.21',
  `PHVerificationMin` decimal(18, 2) NULL DEFAULT NULL COMMENT '验证液最小值',
  `PHVerificationMax` decimal(18, 2) NULL DEFAULT NULL COMMENT '验证液最大值',
  `PHchecked` bit(1) NULL DEFAULT NULL COMMENT '是否进行PH验证',
  `Condchecked` bit(1) NULL DEFAULT NULL COMMENT '是否进行电导率校正',
  `ConductivityCalibration` decimal(18, 2) NULL DEFAULT NULL COMMENT '电导率标准液体',
  `ConductivityCalibrationMin` decimal(18, 6) NULL DEFAULT NULL COMMENT '电极常数最小值',
  `ConductivityCalibrationMax` decimal(18, 6) NULL DEFAULT NULL COMMENT '电极常数最大值',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NOT NULL,
  `Last_update_time` datetime NOT NULL,
  PRIMARY KEY (`CalibrationSettingId`) USING BTREE,
  INDEX `fk_CalibrationSetting1`(`EquipmentId` ASC) USING BTREE,
  CONSTRAINT `fk_CalibrationSetting1` FOREIGN KEY (`EquipmentId`) REFERENCES `cdp_equipment` (`EquipmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准--设置主表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationsettingdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationsettingdtl`;
CREATE TABLE `cdp_equ_calibrationsettingdtl`  (
  `CalibrationSettingDtlId` int NOT NULL AUTO_INCREMENT,
  `CalibrationSettingId` int NOT NULL,
  `StandardSolutionID` int NULL DEFAULT NULL COMMENT '标准液\r\n1.  2.0\r\n3.  4.01\r\n5.  7.00\r\n7.  9.21',
  `SlopeMin` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率最小值',
  `SlopeMax` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率最大值',
  `OffsetMin` decimal(18, 2) NULL DEFAULT NULL COMMENT '偏移量最小值',
  `OffsetMax` decimal(18, 2) NULL DEFAULT NULL COMMENT '偏移量最大值',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NOT NULL,
  `Last_update_time` datetime NOT NULL,
  PRIMARY KEY (`CalibrationSettingDtlId`) USING BTREE,
  INDEX `fk_CalibrationSettingDtl1`(`CalibrationSettingId` ASC) USING BTREE,
  CONSTRAINT `fk_CalibrationSettingDtl1` FOREIGN KEY (`CalibrationSettingId`) REFERENCES `cdp_equ_calibrationsetting` (`CalibrationSettingId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准设置--多参数仪' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationsettingdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equ_calibrationsettingscale_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equ_calibrationsettingscale_dtl`;
CREATE TABLE `cdp_equ_calibrationsettingscale_dtl`  (
  `EquScaleCounterWeightID` int NOT NULL AUTO_INCREMENT,
  `EquScaleId` int NOT NULL COMMENT '地秤id',
  `CounterWeightID` int NOT NULL COMMENT '砝码id',
  `QualifiedInterval` decimal(18, 2) NOT NULL COMMENT '偏差/g',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新人',
  PRIMARY KEY (`EquScaleCounterWeightID`) USING BTREE,
  INDEX `fkequscale001`(`EquScaleId` ASC) USING BTREE,
  INDEX `fk2countweightid001`(`CounterWeightID` ASC) USING BTREE,
  CONSTRAINT `fk2countweightid001` FOREIGN KEY (`CounterWeightID`) REFERENCES `cdp_standard_counterweight` (`CounterWeightID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fkequscale001` FOREIGN KEY (`EquScaleId`) REFERENCES `cdp_equipment` (`EquipmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '设备校准设置--称重设备' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equ_calibrationsettingscale_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equalarm
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equalarm`;
CREATE TABLE `cdp_equalarm`  (
  `EquAlarmId` int NOT NULL AUTO_INCREMENT,
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '设备编号',
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '资产编号',
  `RoomId` int NULL DEFAULT NULL COMMENT '房间Id',
  `IP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `Port` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '端口号',
  `ServiceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '对应服务名称',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '是否有效',
  `IsRuning` bit(1) NULL DEFAULT NULL COMMENT '是否在运行中',
  `IsDelete` bit(1) NULL DEFAULT NULL COMMENT '是否删除',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`EquAlarmId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置-生化报警器' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equalarm
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equculturevessel
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equculturevessel`;
CREATE TABLE `cdp_equculturevessel`  (
  `EquCultureVesselId` int NOT NULL AUTO_INCREMENT,
  `Sort` int NULL DEFAULT NULL,
  `CultureVesselNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '培养容器编号',
  `CultureVesselName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `CultureVesselType` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RoomID` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `Remark` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`EquCultureVesselId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置-培养容器\r\ncdp_equreactor' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equculturevessel
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equipment
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equipment`;
CREATE TABLE `cdp_equipment`  (
  `EquipmentId` int NOT NULL AUTO_INCREMENT,
  `Type` int NOT NULL COMMENT '设备类型\r\n1. Scale\r\n3. Densitometer\r\n5. Multiparameter\r\n7.Spectrophotometer\r\n9. Filter Integrity Tester',
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '设备编号',
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '资产编号',
  `Model` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '型号标识',
  `Brand` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '品牌',
  `DeviceModel` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备型号',
  `Range` int NULL DEFAULT NULL COMMENT '称重最大重量g',
  `Icon` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '1' COMMENT 'icon地址',
  `SubSystemIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备系统ip',
  `SubSystemIPPort` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备系统ip端口号',
  `FilePath` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '文件地址',
  `SubSystemMAC` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备系统mac地址',
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '实时端口名称',
  `SerialPortBaudRate` int NULL DEFAULT NULL COMMENT '实时端口传播速率',
  `SerialPortDataBits` int NULL DEFAULT NULL COMMENT '实时端口数据位',
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '停止位',
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '流控',
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检验位',
  `IsAllowPad` bit(1) NULL DEFAULT NULL COMMENT '是否支持pad',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NOT NULL,
  `Creation_time` datetime NOT NULL,
  `Last_updated_by` int NOT NULL,
  `Last_update_time` datetime NOT NULL,
  PRIMARY KEY (`EquipmentId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---设备管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equipment
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equipment_record
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equipment_record`;
CREATE TABLE `cdp_equipment_record`  (
  `EquipmentRecordId` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `DataType` int NOT NULL COMMENT '数据类型',
  `EquID` int NULL DEFAULT NULL COMMENT '关联设备',
  `Value` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '数据',
  `Unit` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '单位',
  `PreBatchID` int NULL DEFAULT NULL COMMENT '关联批次id',
  `PreBatchTestingID` int NULL DEFAULT NULL COMMENT '检测任务id',
  `StepID` int NULL DEFAULT NULL COMMENT '步骤id',
  `StepName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '步骤名称',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`EquipmentRecordId`) USING BTREE,
  INDEX `fkscaleid002`(`EquID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---设备管理--记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equipment_record
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equprinter
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equprinter`;
CREATE TABLE `cdp_equprinter`  (
  `PrinterID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '设备编号',
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '资产编号',
  `Ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `Port` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '端口号',
  `PrinterIP` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PrinterPort` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PrinterHeight` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PrinterHeightOne` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印高度',
  `PrinterHeightTwo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印高度',
  `PrinterHeightThree` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印高度',
  `PrinterWidth` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印宽度',
  `PrinterWidthOne` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印宽度',
  `PrinterWidthTwo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印宽度',
  `PrinterWidthThree` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印宽度',
  `PrinterFont` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印字体',
  `PrinterFontOne` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印字体',
  `PrinterFontTwo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印字体',
  `PrinterFontThree` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '打印字体',
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`PrinterID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---打印机设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equprinter
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equprinteruser
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equprinteruser`;
CREATE TABLE `cdp_equprinteruser`  (
  `EquPrinterUserID` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `EquPrinterID` int NULL DEFAULT NULL COMMENT '打印机ID',
  `UserID` int NULL DEFAULT NULL COMMENT '用户ID',
  PRIMARY KEY (`EquPrinterUserID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---打印机用户' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equprinteruser
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equprobe
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equprobe`;
CREATE TABLE `cdp_equprobe`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ProbeType` int NOT NULL COMMENT '电极类型\r\n1 内置pH 电极\r\n3 非内置pH 电极\r\n5. 外置光感 DO 电极\r\n7. 内置光感 DO 电极\r\n9. 极谱DO电极\r\n',
  `Brand` int NOT NULL COMMENT '品牌',
  `SerialNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极序号',
  `UseCount` int NULL DEFAULT NULL COMMENT '使用次数',
  `ProbeName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '名称',
  `Remark` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '备注',
  `Status` bit(1) NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '电极维护--无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equprobe
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equpump
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equpump`;
CREATE TABLE `cdp_equpump`  (
  `EquPumpId` int NOT NULL AUTO_INCREMENT,
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Model` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '1:SUB500L\r\n            3:SUB250L\r\n            5:SUB100L\r\n            7:SUB50L',
  `Specification` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PumpSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `PrincipalId` int NULL DEFAULT NULL,
  `PumpTimeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `MaintenanceFlag` tinyint(1) NULL DEFAULT NULL COMMENT '0:Offline;1:Idle;2:Busy;3:Error',
  `IP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'ip地址',
  `Port` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '端口号',
  `SpeedCoefficient` decimal(18, 2) NULL DEFAULT NULL COMMENT '泵速系数（每分钟流量转泵速系数）',
  `ServiceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '服务名称',
  `IsAirPump` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否空气泵 1是 其他否',
  `WorkingSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT '工作泵速 g/min',
  `WorkingTime` decimal(18, 2) NULL DEFAULT NULL COMMENT '工作时长  min',
  `ConfigId` int NULL DEFAULT NULL COMMENT '默认的泵速策略ID',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EquPumpId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---泵设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equpump
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equpump_volume_realtion
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equpump_volume_realtion`;
CREATE TABLE `cdp_equpump_volume_realtion`  (
  `EquPumpRelationID` int NOT NULL AUTO_INCREMENT,
  `MinSpeed` decimal(10, 2) NOT NULL COMMENT 'g/min',
  `MaxSpeed` decimal(10, 2) NOT NULL COMMENT 'g/min',
  `SpeedUpVolume` decimal(18, 2) NOT NULL COMMENT '提速到目标值，总灌装量',
  `SpeedUpConsume` int NOT NULL COMMENT '提速耗时s',
  `SpeedDownVolume` decimal(18, 2) NOT NULL COMMENT '降速到0，总灌装量',
  `SpeedDownConsume` int NOT NULL COMMENT '降速到0耗时s',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EquPumpRelationID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '泵加速降速执行量--无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equpump_volume_realtion
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equreactor
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equreactor`;
CREATE TABLE `cdp_equreactor`  (
  `EquReactorId` int NOT NULL AUTO_INCREMENT,
  `Sort` int NULL DEFAULT NULL,
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ProductID` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Model` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Specification` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Capacity` int NULL DEFAULT NULL COMMENT 'g',
  `RoomID` int NULL DEFAULT NULL,
  `PrincipalId` int NULL DEFAULT NULL,
  `DeviceStatus` int NULL DEFAULT NULL COMMENT '1:Idle;3:Working 5.Feeding',
  `MaintenanceFlag` tinyint(1) NULL DEFAULT NULL COMMENT '0:Offline;1:Idle;2:Busy;3:Error',
  `EquScaleId` int NULL DEFAULT NULL,
  `FeedingScaleId` int NULL DEFAULT NULL COMMENT '关联补料地秤id',
  `RelayID` int NULL DEFAULT NULL,
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `WarningUpperLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `ErrorCode` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '错误码',
  `Pump1Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min  速度',
  `Pump1Timeout` int NULL DEFAULT NULL COMMENT 'g/min   超时时间',
  `Pump1Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump1ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备自身异常',
  `Pump1IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump1ConfigId` int NULL DEFAULT NULL COMMENT '泵速策略id',
  `Pump2Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump2Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump2Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump2ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump2IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump2ConfigId` int NULL DEFAULT NULL,
  `Pump3Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump3Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump3ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump3Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump3IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump3ConfigId` int NULL DEFAULT NULL,
  `Pump4Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump4Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump4ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump4Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump4IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump4ConfigId` int NULL DEFAULT NULL,
  `Pump1SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump2SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump3SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump4SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump5Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump5Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump5ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump5Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump5IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump5SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump5ConfigId` int NULL DEFAULT NULL,
  `Pump6Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump6Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump6ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump6Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump6IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump6SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump6ConfigId` int NULL DEFAULT NULL,
  `Pump7Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump7Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump7ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump7Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump7IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump7SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump7ConfigId` int NULL DEFAULT NULL,
  `Pump8Speed` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `Pump8Timeout` int NULL DEFAULT NULL COMMENT 'g/min',
  `Pump8ErrorCode` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump8Exception` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Pump8IsFeeding` bit(1) NULL DEFAULT b'0' COMMENT '是否正在补料',
  `Pump8SpeedOffset` decimal(5, 2) NULL DEFAULT NULL,
  `Pump8ConfigId` int NULL DEFAULT NULL,
  `IsExternalPump` bit(1) NULL DEFAULT NULL COMMENT '是否支持外置泵',
  `OPCIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '关联的OPC ip地址',
  `OPCPort` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '关联的OPC 端口号',
  `EquAlarmId` int NULL DEFAULT NULL COMMENT '声光报警器id',
  `Status` bit(1) NOT NULL DEFAULT b'0' COMMENT '启用禁用',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `IsMaintenance` bit(1) NULL DEFAULT b'0',
  `MaintenanceTime` datetime NULL DEFAULT NULL,
  `PressureUnit` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '压力单位',
  PRIMARY KEY (`EquReactorId`) USING BTREE,
  INDEX `FK_Reference_94`(`EquScaleId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_94` FOREIGN KEY (`EquScaleId`) REFERENCES `cdp_equscale` (`EquScaleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---反应器设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equreactor
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equrelay
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equrelay`;
CREATE TABLE `cdp_equrelay`  (
  `RelayID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '设备编号',
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '资产编号',
  `Ip` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `Port` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '端口号',
  `ServiceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '对应服务名称',
  `IsDelete` bit(1) NOT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`RelayID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---继电器' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equrelay
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equscale
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equscale`;
CREATE TABLE `cdp_equscale`  (
  `EquScaleId` int NOT NULL AUTO_INCREMENT,
  `DeviceNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `AssetNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Model` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '' COMMENT '1:SUB500L\r\n            3:SUB250L\r\n            5:SUB100L\r\n            7:SUB50L',
  `Brand` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '品牌',
  `Specification` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RoomID` int NULL DEFAULT NULL,
  `PrincipalId` int NULL DEFAULT NULL,
  `MaintenanceFlag` tinyint(1) NULL DEFAULT NULL COMMENT '0:Offline;1:Idle;2:Busy;3:Error',
  `WarningLowerLimit` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/min',
  `ReferenceStatus` int NOT NULL DEFAULT 1 COMMENT '引用模块\r\n1 空闲、\r\n3 补料、\r\n5 补料单元连接、\r\n7 补料液袋补充、\r\n9 下罐',
  `ErrorCode` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '错误码',
  `SubSystemIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备系统ip',
  `SubSystemIPPort` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备系统端口号',
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '实时串口名称',
  `SerialPortBaudRate` int NULL DEFAULT NULL COMMENT '实时串口传播速率',
  `SerialPortDataBits` int NULL DEFAULT NULL COMMENT '实时串口数据位',
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '停止位',
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '流控',
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检查位',
  `IsFeedingScale` bit(1) NULL DEFAULT NULL COMMENT '是否补料地秤 0否1是',
  `DeviceIP` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备ip',
  `DeviceIPPort` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备端口号',
  `ScalePrecision` decimal(18, 2) NULL DEFAULT NULL COMMENT '地秤精度',
  `ServiceName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '对应服务名称',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EquScaleId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---反应器相关地秤（反应器地秤，补料地秤IsFeedingScale判断）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equscale
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_equscale_itemserials
-- ----------------------------
DROP TABLE IF EXISTS `cdp_equscale_itemserials`;
CREATE TABLE `cdp_equscale_itemserials`  (
  `EquScaleItemID` int NOT NULL AUTO_INCREMENT COMMENT '物料明细ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `EquFeedingScaleId` int NULL DEFAULT NULL,
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `SourceType` int NULL DEFAULT NULL COMMENT '1:Workflow Feeding Unit Connection\r\n            3:Workflow Supply Medium(Feeding Unit)',
  `ReferenceID` int NULL DEFAULT NULL,
  `ItemDefBagID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `CurrentVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '内部液体余量g',
  `ItemStatus` int NOT NULL DEFAULT 0 COMMENT '物料状态:\r\n            0 Normal：正常物料\r\n            99 Closed：已换下/已下罐',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`EquScaleItemID`) USING BTREE,
  INDEX `FK_Reference_140`(`ItemDefBagID` ASC) USING BTREE,
  INDEX `FK_Reference_141`(`ItemDefFeedingMediumID` ASC) USING BTREE,
  INDEX `FK_Reference_77`(`BatchID` ASC) USING BTREE,
  INDEX `FK_Reference_80`(`EquFeedingScaleId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_140` FOREIGN KEY (`ItemDefBagID`) REFERENCES `cdp_item_def_bag` (`ItemDefBagID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_141` FOREIGN KEY (`ItemDefFeedingMediumID`) REFERENCES `cdp_item_def_feedingmedium` (`ItemDefFeedingMediumID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_77` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_80` FOREIGN KEY (`EquFeedingScaleId`) REFERENCES `cdp_equscale` (`EquScaleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '补料地秤上物料信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_equscale_itemserials
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_events
-- ----------------------------
DROP TABLE IF EXISTS `cdp_events`;
CREATE TABLE `cdp_events`  (
  `EventsID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `SoureType` int NULL DEFAULT NULL COMMENT '1	Workflow:Start Cell Culture\r\n            2	Workflow:Inoculation\r\n            3	Workflow:Feeding Unit Connection\r\n            4	Workflow:Feeding Manual\r\n            5	Workflow:Sampling Manual\r\n            6	Workflow:Supply Medium(Feeding Unit)\r\n            7	Workflow:Complete Cell Culture\r\n            8	Auto:Fixed Feeding\r\n            10	Manual:Fixed Feeding\r\n            11	Manual:Other Feeding\r\n            12	Manual:BGA\r\n            13	Manual:Vicell\r\n            14	Manual:OSMO\r\n            15	Manual:Cedex\r\n16       Vicell Tupe overflow ',
  `SoureID` int NULL DEFAULT NULL,
  `EventType` int NULL DEFAULT NULL COMMENT '1：Normal\r\n            3：Warning\r\n            5：Error',
  `EventTime` datetime NULL DEFAULT NULL,
  `EventMessage` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ErrorCode` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` int NULL DEFAULT 0 COMMENT '0:New;1:Handled',
  PRIMARY KEY (`EventsID`) USING BTREE,
  INDEX `BatchID`(`BatchID` ASC) USING BTREE,
  INDEX `EventType`(`EventType` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '主页上的事件' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_events
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_events_handlingrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_events_handlingrecord`;
CREATE TABLE `cdp_events_handlingrecord`  (
  `HandlingID` int NOT NULL AUTO_INCREMENT,
  `EventsID` int NULL DEFAULT NULL COMMENT '关联事件ID',
  `RootCause` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '根本原因',
  `HandlingContent` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '处理内容',
  `HandlingResult` int NULL DEFAULT NULL COMMENT '1：Retry  （重试，重新执行） \r\n            3：Skip    (代表本地任务不执行)\r\n5:Go （继续执行）',
  `HandlingTime` datetime NULL DEFAULT NULL COMMENT '处理时间',
  `HandlingUserID` int NULL DEFAULT NULL COMMENT '处理人',
  PRIMARY KEY (`HandlingID`) USING BTREE,
  INDEX `FK_Reference_99`(`EventsID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_99` FOREIGN KEY (`EventsID`) REFERENCES `cdp_events` (`EventsID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '事件处理记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_events_handlingrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_experimentalgroup
-- ----------------------------
DROP TABLE IF EXISTS `cdp_experimentalgroup`;
CREATE TABLE `cdp_experimentalgroup`  (
  `GroupId` int NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `GroupName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `GroupNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Team` int NULL DEFAULT NULL COMMENT '团队：1：UpStream 3：DowmStream 5：Both',
  `PrincipalId` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`GroupId`) USING BTREE,
  INDEX `fk1`(`PrincipalId` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---实验组管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_experimentalgroup
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_experimentalgroupuser
-- ----------------------------
DROP TABLE IF EXISTS `cdp_experimentalgroupuser`;
CREATE TABLE `cdp_experimentalgroupuser`  (
  `PreBatchUserId` int NOT NULL AUTO_INCREMENT,
  `GroupId` int NULL DEFAULT NULL COMMENT '用户ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`PreBatchUserId`) USING BTREE,
  INDEX `FK_Reference_60`(`GroupId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_60` FOREIGN KEY (`GroupId`) REFERENCES `cdp_experimentalgroup` (`GroupId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---实验组和用户关联关系' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_experimentalgroupuser
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_feedingconfig
-- ----------------------------
DROP TABLE IF EXISTS `cdp_feedingconfig`;
CREATE TABLE `cdp_feedingconfig`  (
  `ConfigId` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `ConfigName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '策略名称',
  `IntervalTime` int NOT NULL COMMENT '环控间隔时间（s）',
  `SetSpeed` decimal(18, 2) NULL DEFAULT NULL COMMENT '下发泵速',
  `SpeedDiff` decimal(18, 2) NULL DEFAULT NULL COMMENT '泵速差值',
  `CalibrateDuration` int NOT NULL COMMENT '校准阶段时长',
  `CalibrateVolumePercent` decimal(18, 2) NOT NULL COMMENT '校准阶段材料占总量百分比',
  `HighSpeedPercent` decimal(18, 2) NOT NULL COMMENT '加速阶段泵速百分比',
  `HighSpeedVolumePercent` decimal(18, 2) NOT NULL DEFAULT 85.00 COMMENT '加速阶段补料占总量百分比',
  `LowSpeedPercent` decimal(18, 2) NOT NULL COMMENT '减速阶段泵速占比',
  `LowSpeedVolumePercent` decimal(18, 2) NOT NULL COMMENT '减速阶段补料占总量百分比',
  `ExcessPercentage` decimal(18, 2) NOT NULL COMMENT '补料超量百分比',
  `TimeOutSeconds` int NOT NULL COMMENT '超时时间（s）',
  `FeedTime` int NULL DEFAULT NULL COMMENT '补料时间（s）',
  `TerminalVolumePercent` decimal(18, 2) NOT NULL COMMENT '终点百分比',
  `DitherCoefficient` decimal(18, 2) NOT NULL COMMENT '抖动系数',
  `DitherIntervalCoefficient` int NOT NULL COMMENT '抖动环控时间系数',
  `DitherMonitorTime` int NOT NULL COMMENT '抖动观察时间系数',
  `DitherScaleCoefficient` int NOT NULL COMMENT '抖动地秤系数',
  `JamCoefficient` decimal(18, 2) NOT NULL COMMENT '堵塞系数',
  `JamIntervalCoefficient` int NOT NULL COMMENT '堵塞环控时间系数',
  `RebateCoefficient` decimal(18, 2) NOT NULL COMMENT '返水系数',
  `RebateIntervalCoefficient` int NOT NULL COMMENT '返水环控时间系数',
  `IsTwoStep` int NULL DEFAULT NULL COMMENT '是否二段式',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '启用状态',
  `IsDelete` bit(1) NULL DEFAULT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`ConfigId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---补料策略' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_feedingconfig
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_feedingweight_designate
-- ----------------------------
DROP TABLE IF EXISTS `cdp_feedingweight_designate`;
CREATE TABLE `cdp_feedingweight_designate`  (
  `DesignateID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `BatchID` int NOT NULL,
  `Weight` decimal(18, 2) NOT NULL COMMENT '罐子重量',
  `Date` datetime NOT NULL COMMENT '指定日期',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Created_by` int NOT NULL COMMENT '创建人',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`DesignateID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料重量---执行过程中的重量指定' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_feedingweight_designate
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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料任务执行记录' ROW_FORMAT = DYNAMIC;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '补料任务--下发泵速历史记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_fixedfeedingtask_speedset
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_iot
-- ----------------------------
DROP TABLE IF EXISTS `cdp_iot`;
CREATE TABLE `cdp_iot`  (
  `TokenId` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `Token` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '令牌',
  PRIMARY KEY (`TokenId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'token缓存---无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_iot
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_def_bag
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_def_bag`;
CREATE TABLE `cdp_item_def_bag`  (
  `ItemDefBagID` int NOT NULL AUTO_INCREMENT COMMENT '物料定义ID',
  `ItemDescription` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Model` int NULL DEFAULT NULL COMMENT '1:50L\r\n            3:20L\r\n            5:10L\r\n            7:5L',
  `Capacity` decimal(18, 2) NULL DEFAULT NULL COMMENT '物料容量',
  `TareWeight` decimal(18, 2) NULL DEFAULT NULL,
  `LowerLimitVolume` decimal(18, 2) NULL DEFAULT NULL,
  `ResidualVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '残余量',
  `MaterialIcon` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemDefBagID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置----液袋（物料定义表）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_def_bag
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_def_basicmedium
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_def_basicmedium`;
CREATE TABLE `cdp_item_def_basicmedium`  (
  `ItemDefBasicMediumID` int NOT NULL AUTO_INCREMENT COMMENT '物料定义ID',
  `MediumName` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '培养基名称',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemDefBasicMediumID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置----基础培养基（物料定义表）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_def_basicmedium
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_def_cell
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_def_cell`;
CREATE TABLE `cdp_item_def_cell`  (
  `ItemDefCellID` int NOT NULL AUTO_INCREMENT COMMENT '物料定义ID',
  `CellName` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemDefCellID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置----细胞类型（物料定义表）' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_def_cell
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_item_def_feedingmedium
-- ----------------------------
DROP TABLE IF EXISTS `cdp_item_def_feedingmedium`;
CREATE TABLE `cdp_item_def_feedingmedium`  (
  `ItemDefFeedingMediumID` int NOT NULL AUTO_INCREMENT COMMENT '物料定义ID',
  `MediumCode` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `MediumName` varchar(60) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `GlucoseConc` decimal(18, 2) NULL DEFAULT NULL COMMENT 'g/L糖浓度',
  `IsGlucose` bit(1) NULL DEFAULT NULL COMMENT '是否糖补料',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ItemDefFeedingMediumID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---补料培养基' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_item_def_feedingmedium
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_kpiitem
-- ----------------------------
DROP TABLE IF EXISTS `cdp_kpiitem`;
CREATE TABLE `cdp_kpiitem`  (
  `KPIItemId` int NOT NULL AUTO_INCREMENT COMMENT 'KPI项目ID',
  `KPIRecordId` int NULL DEFAULT NULL COMMENT 'KPI记录ID',
  `ItemKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '项目键',
  `ItemValue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '项目值',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`KPIItemId`) USING BTREE,
  INDEX `CDP_KPIItem_fk001`(`KPIRecordId` ASC) USING BTREE,
  CONSTRAINT `CDP_KPIItem_fk001` FOREIGN KEY (`KPIRecordId`) REFERENCES `cdp_kpirecord` (`KPIRecordId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_kpiitem
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_kpirecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_kpirecord`;
CREATE TABLE `cdp_kpirecord`  (
  `KPIRecordId` int NOT NULL AUTO_INCREMENT COMMENT 'KPI记录ID',
  `ProjectId` int NULL DEFAULT NULL COMMENT '项目Id',
  `BatchId` int NULL DEFAULT NULL COMMENT '批次Id',
  `CultureId` int NULL DEFAULT NULL COMMENT '培养Id',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`KPIRecordId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'KPI记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_kpirecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_lab
-- ----------------------------
DROP TABLE IF EXISTS `cdp_lab`;
CREATE TABLE `cdp_lab`  (
  `LabID` int NOT NULL AUTO_INCREMENT COMMENT '机器ID',
  `LabNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LabName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LabKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `LabSecret` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`LabID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '机器定义表   \r\n系统设置---实验室' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_lab
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_lab_sakula
-- ----------------------------
DROP TABLE IF EXISTS `cdp_lab_sakula`;
CREATE TABLE `cdp_lab_sakula`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `Algerbra` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL COMMENT '代数',
  `Kangar` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL COMMENT '袋鼠',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_lab_sakula
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_labroom
-- ----------------------------
DROP TABLE IF EXISTS `cdp_labroom`;
CREATE TABLE `cdp_labroom`  (
  `RoomID` int NOT NULL AUTO_INCREMENT COMMENT '机器ID',
  `RoomNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `RoomName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`RoomID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---房间管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_labroom
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_machinemodeswitchrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_machinemodeswitchrecord`;
CREATE TABLE `cdp_machinemodeswitchrecord`  (
  `ModeSwitchRecordId` int NOT NULL AUTO_INCREMENT COMMENT '机器ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `SwitchCase` int NULL DEFAULT NULL COMMENT '1. Manual->Automatic\r\n               3. Automatic->Manual',
  `SwitchTime` datetime NULL DEFAULT NULL COMMENT '软件版本',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ModeSwitchRecordId`) USING BTREE,
  INDEX `FK_Reference_54`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_54` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_machinemodeswitchrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_manualop_basicmedium_rec
-- ----------------------------
DROP TABLE IF EXISTS `cdp_manualop_basicmedium_rec`;
CREATE TABLE `cdp_manualop_basicmedium_rec`  (
  `ManualOPRecID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `MediumPumpNo` int NULL DEFAULT NULL,
  `MediumRealVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '培养基温度',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '1:开始\r\n3:结束\r\n99:取消',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ManualOPRecID`) USING BTREE,
  INDEX `FK_Reference_95`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_75` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_manualop_basicmedium_rec
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_mfcsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_mfcsetting`;
CREATE TABLE `cdp_mfcsetting`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL,
  `ReactorID` int NULL DEFAULT NULL,
  `O2DHS1` int NULL DEFAULT NULL,
  `O2DHS2` int NULL DEFAULT NULL,
  `O2Micro` int NULL DEFAULT NULL,
  `CO2DHS` int NULL DEFAULT NULL,
  `AirSP` int NULL DEFAULT NULL,
  `AIrOV` int NULL DEFAULT NULL,
  `O2DHS1TOT` int NULL DEFAULT NULL COMMENT '1:SP1、2：SP2、3：HS',
  `O2DHS2TOT` int NULL DEFAULT NULL COMMENT '1:SP1、2：SP2、3：HS',
  `O2MicroTOT` int NULL DEFAULT NULL COMMENT '1:SP1、2：SP2、3：HS',
  `CO2DHSTOT` int NULL DEFAULT NULL COMMENT '1:SP1、2：SP2、3：HS',
  `AirSPTOT` int NULL DEFAULT NULL COMMENT '1:SP1、2：SP2、3：HS',
  `AIrOVTOT` int NULL DEFAULT NULL COMMENT '1:SP1、2：SP2、3：HS',
  `Status` bit(1) NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_mfcsetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_notificationuser
-- ----------------------------
DROP TABLE IF EXISTS `cdp_notificationuser`;
CREATE TABLE `cdp_notificationuser`  (
  `NotificationUserId` int NOT NULL AUTO_INCREMENT COMMENT '通知用户ID',
  `UserId` int NULL DEFAULT NULL,
  `Email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`NotificationUserId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_notificationuser
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_operateevents
-- ----------------------------
DROP TABLE IF EXISTS `cdp_operateevents`;
CREATE TABLE `cdp_operateevents`  (
  `OperateEventsID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `SoureID` int NULL DEFAULT NULL COMMENT '来源表主键id',
  `EventType` int NOT NULL COMMENT '1、Review\r\n3、Revoke Review\r\n',
  `EventMessage` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '操作事件描述',
  `ExecContent` text CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL COMMENT '执行内容',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除 0否1是',
  `OperationUserID` int NOT NULL COMMENT '操作人',
  `OparationTime` datetime NOT NULL COMMENT '操作时间',
  PRIMARY KEY (`OperateEventsID`) USING BTREE,
  INDEX `EventType`(`EventType` ASC) USING BTREE,
  INDEX `Status`(`IsDelete` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '下游操作说明记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_operateevents
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch`;
CREATE TABLE `cdp_prebatch`  (
  `PreBatchId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `PreBatchName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `PreBatchNo` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ProjectId` int NULL DEFAULT NULL,
  `IsDown` bit(1) NULL DEFAULT NULL COMMENT '是否下游 0否1是',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `Titer` decimal(18, 3) NULL DEFAULT NULL,
  PRIMARY KEY (`PreBatchId`) USING BTREE,
  INDEX `FK_Reference_67`(`ProjectId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_67` FOREIGN KEY (`ProjectId`) REFERENCES `cdp_project` (`ProjectId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置---批次管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch_searchrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch_searchrecord`;
CREATE TABLE `cdp_prebatch_searchrecord`  (
  `SearchRecordID` int NOT NULL AUTO_INCREMENT,
  `UserID` int NOT NULL,
  `BeginTime` datetime NOT NULL COMMENT '查询开始时间',
  `EndTime` datetime NOT NULL COMMENT '查询截止时间',
  `ProjectID` int NOT NULL COMMENT '项目id',
  `PreBatchID` int NOT NULL COMMENT '批次id',
  `PreBatchTestingIDs` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测ids',
  `SearchStatus` int NULL DEFAULT NULL COMMENT '查询的状态 1进行中、2已完成',
  `RecordTime` datetime NOT NULL COMMENT '操作记录时间',
  PRIMARY KEY (`SearchRecordID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游个人批次缓存记录----生物多维检测' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch_searchrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch_testing
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch_testing`;
CREATE TABLE `cdp_prebatch_testing`  (
  `PreBatchTestingID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `PreBatchID` int NOT NULL COMMENT '关联批次主键',
  `StepID` int NULL DEFAULT NULL COMMENT '关联步骤id',
  `StepName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '步骤名称',
  `SampleID` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '样品id',
  `SampleIDSatatus` bit(1) NULL DEFAULT NULL,
  `TareWeightScanID` int NULL DEFAULT NULL COMMENT '皮重检测地秤id',
  `TareWeightScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重检测地秤name',
  `TareWeightCalibration` bit(1) NULL DEFAULT NULL COMMENT '皮重设备是否做过校准：0否1是',
  `TareWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '皮重g',
  `TareWeightUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重单位',
  `TareWeight_Testing_By` int NULL DEFAULT NULL COMMENT '皮重检测人',
  `TareWeight_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重检测人（名称）',
  `TareWeight_Testing_time` datetime NULL DEFAULT NULL COMMENT '皮重检测时间',
  `TareWeightSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n5：Cancel、7、CALC\r\n',
  `RoughWeightBeforeScanID` int NULL DEFAULT NULL COMMENT '毛重检测地秤id（之前）',
  `RoughWeightBeforeScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测地秤名称',
  `RoughWeightBeforeCalibration` bit(1) NULL DEFAULT NULL COMMENT '毛重检测地秤是否做过校验（之前）0否1是',
  `RoughWeightBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '毛重重量（之前）',
  `RoughWeightBeforeUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重重量（之前）单位',
  `RoughWeightBefore_Testing_By` int NULL DEFAULT NULL COMMENT '毛重检测人id（之前）',
  `RoughWeightBefore_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测人（之前）',
  `RoughWeightBefore_Testing_time` datetime NULL DEFAULT NULL COMMENT '毛重检测时间（之前）',
  `RoughWeightBeforeSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n',
  `NetWeightBeforeScanID` int NULL DEFAULT NULL COMMENT '净重检测地秤id（之前）',
  `NetWeightBeforeScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测地秤名称',
  `NetWeightBeforeCalibration` bit(1) NULL DEFAULT NULL COMMENT '净重检测地秤之前是否做过校验（之前）0否1是',
  `NetWeightBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '净重重量（之前）',
  `NetWeightBeforeUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重重量（之前）单位',
  `NetWeightBefore_Testing_By` int NULL DEFAULT NULL COMMENT '净重检测人id（之前）',
  `NetWeightBefore_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测人（之前）',
  `NetWeightBefore_Testing_time` datetime NULL DEFAULT NULL COMMENT '净重检测时间（之前）',
  `NetWeightBeforeSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `RoughWeightAfterScanID` int NULL DEFAULT NULL COMMENT '毛重检测地秤id（之后）',
  `RoughWeightAfterScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测地秤名称（之后）',
  `RoughWeightAfterCalibration` bit(1) NULL DEFAULT NULL COMMENT '毛重检测地秤之后是否做过校验 0否1是',
  `RoughWeightAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '毛重重量（之后）',
  `RoughWeightAfterUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重重量（之后）单位',
  `RoughWeightAfter_Testing_By` int NULL DEFAULT NULL COMMENT '毛重检测人id（之后）',
  `RoughWeightAfter_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测人（之后）',
  `RoughWeightAfter_Testing_time` datetime NULL DEFAULT NULL COMMENT '毛重检测时间（之后）',
  `RoughWeightAfterSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n',
  `NetWeightAfterScanID` int NULL DEFAULT NULL COMMENT '净重检测地秤id（之后）',
  `NetWeightAfterScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测地秤名称',
  `NetWeightAfterCalibration` bit(1) NULL DEFAULT NULL COMMENT '净重检测地秤之后是否做过校验0否1是',
  `NetWeightAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '净重重量（之后）',
  `NetWeightAfterUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重重量（之后）单位',
  `NetWeightAfter_Testing_By` int NULL DEFAULT NULL COMMENT '净重检测人id（之后）',
  `NetWeightAfter_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测人（之后）',
  `NetWeightAfter_Testing_time` datetime NULL DEFAULT NULL COMMENT '净重检测时间（之后）',
  `NetWeightAfterSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `PHDeviceID` int NULL DEFAULT NULL COMMENT 'PH检测设备ID',
  `PHDeviceName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'PH检测设备名称',
  `PH` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'PH检测值',
  `PHTemp` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'PH温度',
  `PH_Testing_By` int NULL DEFAULT NULL COMMENT 'PH检测人',
  `PH_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'PH检测人名',
  `PH_Testing_time` datetime NULL DEFAULT NULL COMMENT 'PH检测时间',
  `PH_TestingSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `CondDeviceID` int NULL DEFAULT NULL COMMENT 'Cond检测设备ID',
  `CondDeviceName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Cond检测设备名称',
  `Cond` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Cond检测值',
  `CondTemp` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Cond温度',
  `Cond_Testing_By` int NULL DEFAULT NULL COMMENT 'Cond检测人',
  `Cond_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Cond检测人',
  `Cond_Testing_time` datetime NULL DEFAULT NULL COMMENT 'Cond检测时间',
  `Cond_TestingSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `ConcDeviceID` int NULL DEFAULT NULL COMMENT 'Conc检测设备ID',
  `ConcDeviceName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Conc检测设备名称',
  `Conc` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Conc检测值',
  `Conc_SoloVPE_ID` int NULL DEFAULT NULL,
  `Conc_RSD` decimal(11, 3) NULL DEFAULT NULL COMMENT 'ConcRSD值',
  `Conc_Testing_By` int NULL DEFAULT NULL COMMENT 'Conc检测人',
  `Conc_Testing_Byname` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'Conc检测人',
  `Conc_Testing_time` datetime NULL DEFAULT NULL COMMENT 'Conc检测时间',
  `Conc_TestingSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `DensityDeviceID` int NULL DEFAULT NULL COMMENT '密度检测设备ID',
  `DensityDeviceName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '密度检测设备名称',
  `Density` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '密度检测值',
  `Density_Testing_By` int NULL DEFAULT NULL COMMENT '密度检测人',
  `Density_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '密度检测人名',
  `Density_Testing_time` datetime NULL DEFAULT NULL COMMENT '密度检测时间',
  `Density_IsValid` bit(1) NULL DEFAULT NULL COMMENT '是否有效',
  `Density_TestingSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `FilterIntegrityTestDeviceID` int NULL DEFAULT NULL COMMENT '完整性检测设备ID',
  `FilterIntegrityTestDeviceName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性检测设备名称',
  `FilterIntegrityTestType` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性类型',
  `FilterIntegrityTestResult` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性结果',
  `FilterIntegrityTestEval` varchar(18) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性结论',
  `FilterIntegrityTest_Testing_By` int NULL DEFAULT NULL COMMENT '完整性检测人',
  `FilterIntegrityTest_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性检测人名',
  `FilterIntegrityTest_Testing_time` datetime NULL DEFAULT NULL COMMENT '完整性检测时间',
  `FilterIntegrityTest_TestingSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n9： select',
  `ReviewUser` int NULL DEFAULT NULL COMMENT '审核人员id',
  `ReviewUserName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '审核人员名称',
  `ReviewTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `Status` bit(1) NOT NULL COMMENT '是否有效：0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`PreBatchTestingID`) USING BTREE,
  INDEX `fkprebatch001`(`PreBatchID` ASC) USING BTREE,
  CONSTRAINT `fkprebatch001` FOREIGN KEY (`PreBatchID`) REFERENCES `cdp_prebatch` (`PreBatchId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游个批次检测记录----生物多维检测' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch_testing
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch_testingfilterintegritytest
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch_testingfilterintegritytest`;
CREATE TABLE `cdp_prebatch_testingfilterintegritytest`  (
  `PreBatchTestingFilterTestID` int NOT NULL AUTO_INCREMENT,
  `DescriptionID` int NULL DEFAULT NULL,
  `PreBatchTestingID` int NOT NULL,
  `FilterIntegrityTestDeviceID` int NULL DEFAULT NULL COMMENT '完整性检测设备ID',
  `TestingFilterIntegrityId` int NULL DEFAULT NULL,
  `FilterIntegrityTestDeviceName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性检测设备名称',
  `FilterIntegrityTestType` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性类型',
  `FilterIntegrityTestPath` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '文件地址',
  `FilterIntegrityTestResult` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性结果',
  `FilterIntegrityTestEval` decimal(18, 2) NULL DEFAULT NULL COMMENT '完整性结论',
  `FilterIntegrityTest_Testing_By` int NULL DEFAULT NULL COMMENT '完整性检测人',
  `FilterIntegrityTest_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '完整性检测人名',
  `FilterIntegrityTest_Testing_time` datetime NULL DEFAULT NULL COMMENT '完整性检测时间',
  `FilterIntegrityTest_TestingSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n9： select',
  `Status` bit(1) NOT NULL COMMENT '是否有效：0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`PreBatchTestingFilterTestID`) USING BTREE,
  INDEX `PreBatchTestingID`(`PreBatchTestingID` ASC) USING BTREE,
  CONSTRAINT `cdp_prebatch_testingfilterintegritytest_ibfk_1` FOREIGN KEY (`PreBatchTestingID`) REFERENCES `cdp_prebatch_testing` (`PreBatchTestingID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游个批次检测记录（完整性测试仪）----生物多维检测' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch_testingfilterintegritytest
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch_testingrecord
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch_testingrecord`;
CREATE TABLE `cdp_prebatch_testingrecord`  (
  `TestingDtlID` int NOT NULL AUTO_INCREMENT,
  `PreBatchTestingID` int NOT NULL COMMENT '批次检测表id',
  `TestItem` int NOT NULL COMMENT '检测项：\r\n1：Tare Wight(g)、\r\n3：Rough Wight(g)、\r\n5：Net Weight(g)、\r\n7：Rough Weight(g)(After sampling)、\r\n9：Net Weight(g)(After sampling)\r\n11：pH \r\n13：Cond.\r\n15：Conc.(μg/mL)',
  `TestItemName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测项中文名',
  `EquID` int NULL DEFAULT NULL COMMENT '设备id',
  `EquName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '设备名称',
  `Value` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测数值',
  `OperationType` int NOT NULL COMMENT '操作类型\r\n1：Capture \r\n3：Save \r\n5：Cancel、7、CALC',
  `Status` bit(1) NOT NULL COMMENT '是否有效 0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `OperationUserID` int NOT NULL COMMENT '操作人',
  `OperationTime` datetime NOT NULL COMMENT '操作时间',
  `CancelResult` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '取消原因',
  PRIMARY KEY (`TestingDtlID`) USING BTREE,
  INDEX `fkprebatchtestingid001`(`PreBatchTestingID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游批次检测历史记录----生物多维检测' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch_testingrecord
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch_testingrecordsource
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch_testingrecordsource`;
CREATE TABLE `cdp_prebatch_testingrecordsource`  (
  `TestingRecordSourceID` int NOT NULL AUTO_INCREMENT,
  `TestingDtlID` int NOT NULL,
  `SourcePreBatchTestingID` int NULL DEFAULT NULL COMMENT '项目、批号、步骤、样本ID',
  `DescriptionID` int NULL DEFAULT NULL COMMENT '描述',
  `SourceDeviceID` int NULL DEFAULT NULL COMMENT 'Equ信息',
  `SourceTestItem` int NULL DEFAULT NULL COMMENT '测试项目',
  `SourceValue` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '检测数值',
  `SourceUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测单位',
  `SourceOperationType` int NOT NULL COMMENT '操作类型\r\n1：Capture \r\n3：Save \r\n5：Cancel、\r\n7、CALC\r\n9、COPY',
  `SourceOperationUserID` int NOT NULL COMMENT '操作人',
  `SourceOperationTime` datetime NOT NULL COMMENT '操作时间',
  `CopyUserID` int NULL DEFAULT NULL COMMENT '复制人',
  `CopyTime` datetime NULL DEFAULT NULL COMMENT '复制时间',
  PRIMARY KEY (`TestingRecordSourceID`) USING BTREE,
  INDEX `TestingDtlID`(`TestingDtlID` ASC) USING BTREE,
  CONSTRAINT `cdp_prebatch_testingrecordsource_ibfk_1` FOREIGN KEY (`TestingDtlID`) REFERENCES `cdp_prebatch_testingrecord` (`TestingDtlID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游批次检测操作数据----生物多维检测' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch_testingrecordsource
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_prebatch_testingweight
-- ----------------------------
DROP TABLE IF EXISTS `cdp_prebatch_testingweight`;
CREATE TABLE `cdp_prebatch_testingweight`  (
  `PreBatchTestingWeightID` int NOT NULL AUTO_INCREMENT,
  `PreBatchTestingID` int NOT NULL,
  `DescriptionID` int NOT NULL,
  `TareWeightScanID` int NULL DEFAULT NULL COMMENT '皮重检测地秤id',
  `TareWeightScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重检测地秤name',
  `TareWeightCalibration` bit(1) NULL DEFAULT NULL COMMENT '皮重设备是否做过校准：0否1是',
  `TareWeight` decimal(18, 2) NULL DEFAULT NULL COMMENT '皮重g',
  `TareWeightStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重 中文',
  `TareWeightUnit` varchar(225) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重单位',
  `TareWeight_Testing_By` int NULL DEFAULT NULL COMMENT '皮重检测人',
  `TareWeight_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '皮重检测人（名称）',
  `TareWeight_Testing_time` datetime NULL DEFAULT NULL COMMENT '皮重检测时间',
  `TareWeightSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n5：Cancel、7、CALC\r\n',
  `RoughWeightBeforeScanID` int NULL DEFAULT NULL COMMENT '毛重检测地秤id（之前）',
  `RoughWeightBeforeScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测地秤名称',
  `RoughWeightBeforeCalibration` bit(1) NULL DEFAULT NULL COMMENT '毛重检测地秤是否做过校验（之前）0否1是',
  `RoughWeightBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '毛重重量（之前）',
  `RoughWeightBeforeStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重重量（之前）中文',
  `RoughWeightBeforeUnit` varchar(225) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重重量(之前)单位',
  `RoughWeightBefore_Testing_By` int NULL DEFAULT NULL COMMENT '毛重检测人id（之前）',
  `RoughWeightBefore_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测人（之前）',
  `RoughWeightBefore_Testing_time` datetime NULL DEFAULT NULL COMMENT '毛重检测时间（之前）',
  `RoughWeightBeforeSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n',
  `NetWeightBeforeScanID` int NULL DEFAULT NULL COMMENT '净重检测地秤id（之前）',
  `NetWeightBeforeScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测地秤名称',
  `NetWeightBeforeCalibration` bit(1) NULL DEFAULT NULL COMMENT '净重检测地秤之前是否做过校验（之前）0否1是',
  `NetWeightBefore` decimal(18, 2) NULL DEFAULT NULL COMMENT '净重重量（之前）',
  `NetWeightBeforeStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重重量（之前）中文',
  `NetWeightBeforeUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重重量（之前）单位',
  `NetWeightBefore_Testing_By` int NULL DEFAULT NULL COMMENT '净重检测人id（之前）',
  `NetWeightBefore_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测人（之前）',
  `NetWeightBefore_Testing_time` datetime NULL DEFAULT NULL COMMENT '净重检测时间（之前）',
  `NetWeightBeforeSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `RoughWeightAfterScanID` int NULL DEFAULT NULL COMMENT '毛重检测地秤id（之后）',
  `RoughWeightAfterScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测地秤名称（之后）',
  `RoughWeightAfterCalibration` bit(1) NULL DEFAULT NULL COMMENT '毛重检测地秤之后是否做过校验 0否1是',
  `RoughWeightAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '毛重重量（之后）',
  `RoughWeightAfterStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重重量（之后）中文',
  `RoughWeightAfterUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重重量（之后）单位',
  `RoughWeightAfter_Testing_By` int NULL DEFAULT NULL COMMENT '毛重检测人id（之后）',
  `RoughWeightAfter_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '毛重检测人（之后）',
  `RoughWeightAfter_Testing_time` datetime NULL DEFAULT NULL COMMENT '毛重检测时间（之后）',
  `RoughWeightAfterSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n',
  `NetWeightAfterScanID` int NULL DEFAULT NULL COMMENT '净重检测地秤id（之后）',
  `NetWeightAfterScanName` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测地秤名称',
  `NetWeightAfterCalibration` bit(1) NULL DEFAULT NULL COMMENT '净重检测地秤之后是否做过校验0否1是',
  `NetWeightAfter` decimal(18, 2) NULL DEFAULT NULL COMMENT '净重重量（之后）',
  `NetWeightAfterStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重重量（之后）中文',
  `NetWeightAfterUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重重量（之后）单位',
  `NetWeightAfter_Testing_By` int NULL DEFAULT NULL COMMENT '净重检测人id（之后）',
  `NetWeightAfter_Testing_Byname` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '净重检测人（之后）',
  `NetWeightAfter_Testing_time` datetime NULL DEFAULT NULL COMMENT '净重检测时间（之后）',
  `NetWeightAfterSourceType` int NULL DEFAULT NULL COMMENT '数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC\r\n数据来源类型\r\n1：Capture \r\n3：Save \r\n4：Cancel、7、CALC',
  `Status` bit(1) NOT NULL COMMENT '是否有效：0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`PreBatchTestingWeightID`) USING BTREE,
  INDEX `PreBatchTestingID`(`PreBatchTestingID` ASC) USING BTREE,
  CONSTRAINT `cdp_prebatch_testingweight_ibfk_1` FOREIGN KEY (`PreBatchTestingID`) REFERENCES `cdp_prebatch_testing` (`PreBatchTestingID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游批次检测记录（称重设备）----生物多维检测' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_prebatch_testingweight
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_preculture
-- ----------------------------
DROP TABLE IF EXISTS `cdp_preculture`;
CREATE TABLE `cdp_preculture`  (
  `PreCultureID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `EquReactorId` int NULL DEFAULT NULL,
  `CultureCode` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `PreBatchId` int NULL DEFAULT NULL,
  `ReferenceProtocolId` int NULL DEFAULT NULL COMMENT '引用的协议ID',
  `CultureProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `Alias` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '别名',
  `ScheduledStartDate` date NULL DEFAULT NULL,
  `IsNProduction` bit(1) NULL DEFAULT NULL COMMENT '是否为N代培养',
  `ScheduledEndDate` date NULL DEFAULT NULL,
  `CultureStatus` int NOT NULL DEFAULT 1 COMMENT '1:Not Started\r\n            3:Started\r\n            99：Cancel',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `TrainingType` int NULL DEFAULT NULL COMMENT '1普通培养 3补料培养',
  `Day` int NULL DEFAULT NULL COMMENT '普通培养天数',
  `FeedingBasis` int NULL DEFAULT NULL COMMENT '补料依据 1：初始重量  3：当前重量',
  `AirPumpId` int NULL DEFAULT NULL COMMENT '空气泵',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `RoomID` int NULL DEFAULT NULL COMMENT '房间Id',
  `EquCultureVesselId` int NULL DEFAULT NULL COMMENT '培养容器Id',
  `CultivationStartTime` datetime NULL DEFAULT NULL COMMENT '培养开始时间',
  `IsSynchro` bit(1) NULL DEFAULT b'0' COMMENT '是否同步',
  `CultivationEndTime` datetime NULL DEFAULT NULL COMMENT '培养结束时间',
  PRIMARY KEY (`PreCultureID`) USING BTREE,
  INDEX `PreBatchId`(`PreBatchId` ASC) USING BTREE,
  INDEX `FK_Reference_71`(`CultureProtocolId` ASC) USING BTREE,
  INDEX `FK_Reference_85`(`ReferenceProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_68` FOREIGN KEY (`PreBatchId`) REFERENCES `cdp_prebatch` (`PreBatchId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_71` FOREIGN KEY (`CultureProtocolId`) REFERENCES `cdp_cultureprotocol` (`CultureProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_85` FOREIGN KEY (`ReferenceProtocolId`) REFERENCES `cdp_protocol` (`ProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置------培养管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_preculture
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_project
-- ----------------------------
DROP TABLE IF EXISTS `cdp_project`;
CREATE TABLE `cdp_project`  (
  `ProjectId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `DepartmentId` int NULL DEFAULT NULL,
  `ProjectNo` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ProjectName` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `PrincipalId` int NULL DEFAULT NULL COMMENT '责任人',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProjectId`) USING BTREE,
  INDEX `FK_Reference_129`(`DepartmentId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_129` FOREIGN KEY (`DepartmentId`) REFERENCES `cdp_department` (`DepartmentId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '系统设置------项目管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_project
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_projectprincipal
-- ----------------------------
DROP TABLE IF EXISTS `cdp_projectprincipal`;
CREATE TABLE `cdp_projectprincipal`  (
  `ProjectPrincipalId` int NOT NULL AUTO_INCREMENT COMMENT '项目负责人ID',
  `ProjectId` int NULL DEFAULT NULL COMMENT '项目ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProjectPrincipalId`) USING BTREE,
  INDEX `ProjectId`(`ProjectId` ASC) USING BTREE,
  CONSTRAINT `cdp_projectprincipal_ibfk_1` FOREIGN KEY (`ProjectId`) REFERENCES `cdp_project` (`ProjectId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置------项目管理负责人信息' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_projectprincipal
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_projectuser
-- ----------------------------
DROP TABLE IF EXISTS `cdp_projectuser`;
CREATE TABLE `cdp_projectuser`  (
  `ProjectUserId` int NOT NULL AUTO_INCREMENT,
  `ProjectId` int NULL DEFAULT NULL COMMENT '用户ID',
  `GroupId` int NULL DEFAULT NULL COMMENT '所属组ID',
  `UserId` int NOT NULL COMMENT '用户ID',
  `LimitToDate` datetime NULL DEFAULT NULL COMMENT '用户过期时间',
  `Upload` bit(1) NOT NULL DEFAULT b'1' COMMENT '上传',
  `RevokeUpload` bit(1) NOT NULL DEFAULT b'1' COMMENT '撤回上传',
  `Review` bit(1) NOT NULL DEFAULT b'1' COMMENT '审核',
  `RevokeReview` bit(1) NOT NULL DEFAULT b'1' COMMENT '撤回审核',
  `Signature` bit(1) NOT NULL DEFAULT b'1' COMMENT '签名',
  `RevokeSignature` bit(1) NOT NULL DEFAULT b'1' COMMENT '撤回签名',
  `Verify` bit(1) NOT NULL DEFAULT b'1' COMMENT '审核',
  `RevokeVerify` bit(1) NOT NULL DEFAULT b'1' COMMENT '撤回审核',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProjectUserId`) USING BTREE,
  INDEX `ProjectId`(`ProjectId` ASC) USING BTREE,
  CONSTRAINT `cdp_projectuser_ibfk_1` FOREIGN KEY (`ProjectId`) REFERENCES `cdp_project` (`ProjectId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置------项目管理和用户关联关系' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_projectuser
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_protocol
-- ----------------------------
DROP TABLE IF EXISTS `cdp_protocol`;
CREATE TABLE `cdp_protocol`  (
  `ProtocolId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `EquReactorId` int NULL DEFAULT NULL,
  `EquFeedingScaleId` int NULL DEFAULT NULL,
  `Days` int NULL DEFAULT NULL,
  `InitialWorkingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `InitialWorkingMediumId` int NULL DEFAULT NULL,
  `TransferCellVolume` decimal(18, 2) NULL DEFAULT NULL,
  `TransferCellTypeId` int NULL DEFAULT NULL,
  `ExperimentalGroupId` int NULL DEFAULT NULL COMMENT '用户ID',
  `GlucoseFeedingVerification` bit(1) NULL DEFAULT NULL,
  `Remark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` bit(1) NULL DEFAULT b'1' COMMENT '禁用 启用',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  `ProtocolName` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolId`) USING BTREE,
  INDEX `FK_Reference_61`(`ExperimentalGroupId` ASC) USING BTREE,
  INDEX `FK_Reference_69`(`EquReactorId` ASC) USING BTREE,
  INDEX `FK_Reference_70`(`EquFeedingScaleId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_61` FOREIGN KEY (`ExperimentalGroupId`) REFERENCES `cdp_experimentalgroup` (`GroupId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_69` FOREIGN KEY (`EquReactorId`) REFERENCES `cdp_equreactor` (`EquReactorId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_70` FOREIGN KEY (`EquFeedingScaleId`) REFERENCES `cdp_equscale` (`EquScaleId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案模板' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_protocol
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_protocol_autoglucosefeedingrule
-- ----------------------------
DROP TABLE IF EXISTS `cdp_protocol_autoglucosefeedingrule`;
CREATE TABLE `cdp_protocol_autoglucosefeedingrule`  (
  `ProtocolAutoGlucoseFeedingRuleID` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `ProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `CultureDayStarting` tinyint NOT NULL COMMENT '开始第几天',
  `CultureDayEnding` tinyint NOT NULL COMMENT '结束第几天',
  `LowerLimit` decimal(18, 2) NOT NULL COMMENT 'g/L',
  `FeedingTo` decimal(18, 2) NOT NULL COMMENT 'g/L',
  `LowerLimitOperator` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL COMMENT '1:< 2:<=',
  `CalculationMode` int NULL DEFAULT NULL COMMENT '计算模式 1：残糖 3：残糖和乳酸',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolAutoGlucoseFeedingRuleID`) USING BTREE,
  INDEX `FK_Reference_AutoGlucoseFeedingRule_66`(`ProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_AutoGlucoseFeedingRule_66` FOREIGN KEY (`ProtocolId`) REFERENCES `cdp_protocol` (`ProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案模板--自动补糖规则' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_protocol_autoglucosefeedingrule
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_protocol_feedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_protocol_feedingtask`;
CREATE TABLE `cdp_protocol_feedingtask`  (
  `ProtocolFeedingTaskId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `ProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `Day` int NOT NULL COMMENT 'ID',
  `FeedingTime` time NOT NULL COMMENT 'ID',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n            3:Feeding By Volume',
  `FeedingVolumePercent` decimal(18, 3) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolFeedingTaskId`) USING BTREE,
  INDEX `FK_Reference_64`(`ProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_64` FOREIGN KEY (`ProtocolId`) REFERENCES `cdp_protocol` (`ProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案---补料任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_protocol_feedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_protocol_fixedfeedingpump
-- ----------------------------
DROP TABLE IF EXISTS `cdp_protocol_fixedfeedingpump`;
CREATE TABLE `cdp_protocol_fixedfeedingpump`  (
  `ProtocolFixedFeedingPumpId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `ProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `ConfigId` int NULL DEFAULT NULL COMMENT '策略ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `ItemDefBagID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `EquPumpId` int NULL DEFAULT NULL COMMENT '外置泵ID',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolFixedFeedingPumpId`) USING BTREE,
  INDEX `FK_Reference_130`(`ItemDefBagID` ASC) USING BTREE,
  INDEX `FK_Reference_131`(`ItemDefFeedingMediumID` ASC) USING BTREE,
  INDEX `FK_Reference_95`(`ProtocolId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_130` FOREIGN KEY (`ItemDefBagID`) REFERENCES `cdp_item_def_bag` (`ItemDefBagID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_131` FOREIGN KEY (`ItemDefFeedingMediumID`) REFERENCES `cdp_item_def_feedingmedium` (`ItemDefFeedingMediumID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_95` FOREIGN KEY (`ProtocolId`) REFERENCES `cdp_protocol` (`ProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '培养方案---泵关联关系' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_protocol_fixedfeedingpump
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_protocol_otherfeedingtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_protocol_otherfeedingtask`;
CREATE TABLE `cdp_protocol_otherfeedingtask`  (
  `ProtocolOtherFeedingTaskId` int NOT NULL AUTO_INCREMENT COMMENT '项目ID',
  `ProtocolId` int NULL DEFAULT NULL COMMENT '项目ID',
  `Day` int NOT NULL COMMENT 'ID',
  `FeedingTime` time NOT NULL COMMENT 'ID',
  `EquPumpId` int NULL DEFAULT NULL,
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `FeedingType` int NULL DEFAULT NULL COMMENT '1:Feeding By Percent\r\n            3:Feeding By Volume',
  `FeedingVolumePercent` decimal(18, 2) NULL DEFAULT NULL,
  `FeedingVolume` decimal(18, 2) NULL DEFAULT NULL,
  `PreRemindingTime` int NULL DEFAULT NULL COMMENT 'min',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ProtocolOtherFeedingTaskId`) USING BTREE,
  INDEX `FK_Reference_OtherFeedingTask_65`(`ProtocolId` ASC) USING BTREE,
  INDEX `FK_Reference_72`(`EquPumpId` ASC) USING BTREE,
  INDEX `FK_Reference_97`(`ItemDefFeedingMediumID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_72` FOREIGN KEY (`EquPumpId`) REFERENCES `cdp_equpump` (`EquPumpId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_97` FOREIGN KEY (`ItemDefFeedingMediumID`) REFERENCES `cdp_item_def_feedingmedium` (`ItemDefFeedingMediumID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_OtherFeedingTask_65` FOREIGN KEY (`ProtocolId`) REFERENCES `cdp_protocol` (`ProtocolId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_protocol_otherfeedingtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe`;
CREATE TABLE `cdp_replaceprobe`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `Type` int NULL DEFAULT NULL COMMENT '1. 仅更换\r\n3. 流程更换',
  `UserID` int NOT NULL COMMENT 'UserID',
  `EquReactorId` int NULL DEFAULT NULL COMMENT '反应器ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `ExternalProbe` bit(1) NULL DEFAULT NULL COMMENT '是否包含外置电极',
  `Status` int NULL DEFAULT NULL COMMENT '1. 开始\r\n3.电极校正提交\r\n4.电极校正审核\r\n5.电极灭菌提交\r\n6.电极灭菌审核\r\n7.电极安装提交\r\n8.电极安装审核\r\n9.电极线安装提交\r\n10.电极线安装审核\r\n11. 完成提交\r\n12 完成审核（直接完成）\r\n99 取消',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Creation_FinishTime` datetime NULL DEFAULT NULL,
  `Creation_FinishBy` int NULL DEFAULT NULL COMMENT '记录完成人',
  `CancelTime` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `CancelUser` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '更换电极cdp_replaceprobe--------cdp_replaceprobe_sterilizationprobe都无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_directdtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_directdtl`;
CREATE TABLE `cdp_replaceprobe_directdtl`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL COMMENT '更换电极ID',
  `OriginalKeyID` int NOT NULL,
  `OriginalKeyType` int NULL DEFAULT NULL COMMENT '1.PH\r\n3.DO',
  `MainProbe` bit(1) NULL DEFAULT NULL COMMENT '主要电极',
  `OriginalProbeType` int NULL DEFAULT NULL COMMENT '电极类型\r\n1 内置pH 电极\r\n3 非内置pH 电极\r\n5. 外置光感 DO 电极\r\n7. 内置光感 DO 电极\r\n9. 极谱DO电极\r\n',
  `OriginalProbeID` int NULL DEFAULT NULL COMMENT '电极ID',
  `OriginalBrandID` int NULL DEFAULT NULL COMMENT '品牌ID',
  `OriginalProbeBrand` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极品牌',
  `OriginalProbeSerialNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极序列号',
  `FreshProbeType` int NULL DEFAULT NULL COMMENT '电极类型\r\n1 内置pH 电极\r\n3 非内置pH 电极\r\n5. 外置光感 DO 电极\r\n7. 内置光感 DO 电极\r\n9. 极谱DO电极\r\n',
  `FreshProbeID` int NULL DEFAULT NULL COMMENT '电极ID',
  `FreshBrandID` int NULL DEFAULT NULL COMMENT '品牌ID',
  `FreshProbeBrand` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极品牌',
  `FreshProbeSerialNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极序列号',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '仅更换电极' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_directdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_doprobetest
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_doprobetest`;
CREATE TABLE `cdp_replaceprobe_doprobetest`  (
  `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `OriginalKeyID` int NOT NULL,
  `ProbeType` int NULL DEFAULT NULL COMMENT '电极类型\r\n1 内置pH 电极\r\n3 非内置pH 电极\r\n5. 外置光感 DO 电极\r\n7. 内置光感 DO 电极\r\n9. 极谱DO电极\r\n',
  `ConfirmDOProbe` bit(1) NULL DEFAULT NULL COMMENT '确认光感电极是否正常',
  `CheckProbeWhether` int NULL DEFAULT NULL COMMENT '电极膜是否替换\r\n1. 未更换\r\n3. 更换',
  `AddElectrolyteSolution` bit(1) NULL DEFAULT NULL COMMENT '添加电解液',
  `ElectrolyteSolutionExpirationDate` datetime NULL DEFAULT NULL COMMENT '电解液有效期',
  `ProbeID` int NULL DEFAULT NULL COMMENT '电极ID',
  `BrandID` int NULL DEFAULT NULL COMMENT '品牌ID',
  `ProbeBrand` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极品牌',
  `ProbeSerialNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极序列号',
  `ConfirmConnection` bit(1) NULL DEFAULT NULL COMMENT '确认连接正常并置于容器',
  `CurrentValue` decimal(18, 2) NULL DEFAULT NULL COMMENT '5min 电流值',
  `ConfirmRecovered` bit(1) NULL DEFAULT NULL COMMENT '60 秒 内 恢 复 到 80.00%',
  `AirCurrentValue` decimal(18, 2) NULL DEFAULT NULL COMMENT '空气中电流值',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `Revoke` int NULL DEFAULT NULL COMMENT '撤销人',
  `RevokeDate` datetime NULL DEFAULT NULL COMMENT '撤销时间',
  `RevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销原因',
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销签名',
  `Inconformity` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InconformityDes` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不符合规则描述',
  `Attachment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '附件',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'DO电极检查\r\n' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_doprobetest
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_phprobetest
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_phprobetest`;
CREATE TABLE `cdp_replaceprobe_phprobetest`  (
  `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `OriginalKeyID` int NOT NULL,
  `ProbeType` int NULL DEFAULT NULL COMMENT '电极类型\r\n1 内置pH 电极\r\n3 非内置pH 电极\r\n5. 外置光感 DO 电极\r\n7. 内置光感 DO 电极\r\n9. 极谱DO电极\r\n',
  `ProbeID` int NULL DEFAULT NULL COMMENT '电极ID',
  `BrandID` int NULL DEFAULT NULL COMMENT '品牌ID',
  `ProbeBrand` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极品牌',
  `ProbeSerialNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极序列号',
  `ConfirmBufferDate` bit(1) NULL DEFAULT b'1' COMMENT '确认缓冲液有效期',
  `Buffer1ExpirationDate` datetime NULL DEFAULT NULL COMMENT '4.01 有效期',
  `Buffer2ExpirationDate` datetime NULL DEFAULT NULL COMMENT '7.00 有效期',
  `ConfirmBuffer1` bit(1) NULL DEFAULT b'1' COMMENT '确认buffer1 操作',
  `ChooseTemp` bit(1) NULL DEFAULT NULL COMMENT '选择温度补偿模式',
  `ConfirmBuffer2` bit(1) NULL DEFAULT b'1' COMMENT '确认buffer2 操作',
  `ConfirmrCalibration` bit(1) NULL DEFAULT NULL COMMENT '确认校正完成',
  `CompensationTemp` decimal(18, 2) NULL DEFAULT NULL COMMENT '补偿温度',
  `Zero` decimal(18, 2) NULL DEFAULT NULL COMMENT '零点电压值',
  `SlopeAbsoluteValue` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率绝对值',
  `RemeasurepH` decimal(18, 2) NULL DEFAULT NULL COMMENT '回测pH值',
  `Result` bit(1) NULL DEFAULT NULL COMMENT '结果 失败 成功',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `Revoke` int NULL DEFAULT NULL COMMENT '撤销人',
  `RevokeDate` datetime NULL DEFAULT NULL COMMENT '撤销时间',
  `RevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销原因',
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销签名',
  `Inconformity` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InconformityDes` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不符合规则描述',
  `Attachment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '附件',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'pH电极校准' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_phprobetest
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_phrecalibration
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_phrecalibration`;
CREATE TABLE `cdp_replaceprobe_phrecalibration`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `SamplingTemperature` decimal(18, 2) NULL DEFAULT NULL COMMENT '取样时温度',
  `BGAPH` decimal(18, 3) NULL DEFAULT NULL COMMENT 'BGA pH',
  `OnlinePH` decimal(18, 3) NULL DEFAULT NULL COMMENT 'OnlinePH',
  `ReCalibrationPH` decimal(18, 3) NULL DEFAULT NULL COMMENT '重校pH',
  `AutoMode` bit(1) NULL DEFAULT NULL COMMENT '控制模式',
  `CO2CascadeMode` bit(1) NULL DEFAULT NULL COMMENT '控制模式',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `Revoke` int NULL DEFAULT NULL COMMENT '撤销人',
  `RevokeDate` datetime NULL DEFAULT NULL COMMENT '撤销时间',
  `RevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销原因',
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销签名',
  `Inconformity` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InconformityDes` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不符合规则描述',
  `Attachment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '附件',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'pH 校正记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_phrecalibration
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_probeinstallation
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_probeinstallation`;
CREATE TABLE `cdp_replaceprobe_probeinstallation`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `ConfirmInstallTime` bit(1) NULL DEFAULT NULL COMMENT '确认安装时间',
  `KPCMethod` bit(1) NULL DEFAULT NULL COMMENT 'KPC 连接方法',
  `ProbeFix` bit(1) NULL DEFAULT NULL COMMENT '安装固定电极支架\r\n',
  `PushBag` bit(1) NULL DEFAULT NULL COMMENT '推入培养袋中',
  `PlaceProbeTray` bit(1) NULL DEFAULT NULL COMMENT '置卡入电极托架',
  `ProbeCableConnection` bit(1) NULL DEFAULT NULL COMMENT '电极线连接',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `Revoke` int NULL DEFAULT NULL,
  `RevokeDate` datetime NULL DEFAULT NULL,
  `RevokeReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InconformityDes` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不符合规则描述',
  `Attachment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '附件',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '电极安装' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_probeinstallation
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_probelineinstallation
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_probelineinstallation`;
CREATE TABLE `cdp_replaceprobe_probelineinstallation`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `ProbeCableConnection` bit(1) NULL DEFAULT NULL COMMENT '电极线连接',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `Revoke` int NULL DEFAULT NULL,
  `RevokeDate` datetime NULL DEFAULT NULL,
  `RevokeReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InconformityDes` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不符合规则描述',
  `Attachment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '附件',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '电极安装' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_probelineinstallation
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_probeselection
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_probeselection`;
CREATE TABLE `cdp_replaceprobe_probeselection`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `OriginalKeyID` int NULL DEFAULT NULL,
  `ProbeID` int NULL DEFAULT NULL COMMENT '电极ID',
  `ProbeName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ProbeType` int NULL DEFAULT NULL,
  `IsSelected` bit(1) NULL DEFAULT NULL COMMENT '是否选中',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `RevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销原因',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `RevokeDate` datetime NULL DEFAULT NULL COMMENT '撤销时间',
  `Revoke` int NULL DEFAULT NULL COMMENT '撤销人',
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '撤销签名',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `Creation_time` datetime NULL DEFAULT NULL,
  `Created_by` int NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '电极选择' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_probeselection
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_replaceprobe_sterilizationprobe
-- ----------------------------
DROP TABLE IF EXISTS `cdp_replaceprobe_sterilizationprobe`;
CREATE TABLE `cdp_replaceprobe_sterilizationprobe`  (
  `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ReplaceProbeID` int NULL DEFAULT NULL,
  `CheckKPCKit` bit(1) NULL DEFAULT NULL COMMENT '检查 KPC电极套',
  `KPCInfo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'KPC 路径',
  `KPCPicture` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'KPC图片路径',
  `KPCCatNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'KPC 货号',
  `KPCLotNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'KPC 批号',
  `CheckORing` bit(1) NULL DEFAULT NULL COMMENT '检查电极 O 型圈',
  `ConfirmKPCOperation` bit(1) NULL DEFAULT NULL COMMENT '确认KPC操作',
  `AutoclaveTempSetPoint` decimal(18, 2) NULL DEFAULT NULL COMMENT '灭菌温度设定',
  `AutoclaveDate` date NULL DEFAULT NULL COMMENT '灭菌日期',
  `AutoclaveStartTime` datetime NULL DEFAULT NULL COMMENT '灭菌起始时间',
  `AutoclaveEndTime` datetime NULL DEFAULT NULL COMMENT '灭菌终止时间',
  `AutoclaveRecord` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '灭菌文档路径',
  `AutoclaveRecord1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '灭菌文档路径1',
  `Operator` int NULL DEFAULT NULL COMMENT '操作人',
  `OperateDate` datetime NULL DEFAULT NULL COMMENT '操作时间',
  `OperateUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '操作人签名',
  `Verifier` int NULL DEFAULT NULL COMMENT '复核人',
  `VerifyDate` datetime NULL DEFAULT NULL COMMENT '复核时间',
  `VerifyUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '复核人签名',
  `Revoke` int NULL DEFAULT NULL,
  `RevokeDate` datetime NULL DEFAULT NULL,
  `RevokeReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RevokeUrl` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Inconformity` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InconformityDes` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '不符合规则描述',
  `Attachment` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '附件',
  `Status` int NULL DEFAULT NULL COMMENT '操作状态\r\n1 操作中（可编辑）\r\n2 已撤回 （可编辑）\r\n3 审核不通过 （可编辑）\r\n\r\n5 待审核  （不可编辑）\r\n\r\n9 审核通过 （不可编辑）\r\n',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '传统电极灭菌' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_replaceprobe_sterilizationprobe
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_revokereason
-- ----------------------------
DROP TABLE IF EXISTS `cdp_revokereason`;
CREATE TABLE `cdp_revokereason`  (
  `RevokeReasonID` int NOT NULL AUTO_INCREMENT COMMENT '撤回原因ID',
  `RevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '撤回原因',
  `RevokeType` int NOT NULL COMMENT '撤回类型\r\n            1. BGA 上传撤回\r\n            3. OSMO 上传撤回\r\n            5. Vivell 上传撤回\r\n            7. Cedex 上传撤回\r\n            9. 签名撤回\r\n            11. 审核撤回',
  `IsDown` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否是下游',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`RevokeReasonID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置----撤回原因' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_revokereason
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_rulesetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_rulesetting`;
CREATE TABLE `cdp_rulesetting`  (
  `RuleSettingId` int NOT NULL AUTO_INCREMENT,
  `RuleType` int NOT NULL COMMENT '1.  Difference\r\n3.  RSD',
  `Symbol` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '符号',
  `Value` decimal(18, 7) NULL DEFAULT NULL COMMENT '值',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新人',
  PRIMARY KEY (`RuleSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置----下游规则设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_rulesetting
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_schedulermonitor
-- ----------------------------
DROP TABLE IF EXISTS `cdp_schedulermonitor`;
CREATE TABLE `cdp_schedulermonitor`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `CreationTime` datetime NOT NULL COMMENT '创建时间',
  `Reactors` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '罐子标识',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '自动补料---补料监控' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_schedulermonitor
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_sequence_config
-- ----------------------------
DROP TABLE IF EXISTS `cdp_sequence_config`;
CREATE TABLE `cdp_sequence_config`  (
  `SequenceID` int NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `SiteName` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '站点: \r\nS   外高桥 \r\nW  无锡\r\nF   奉贤',
  `Length` int NULL DEFAULT NULL COMMENT '长度',
  `PaddingChar` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '填充字符',
  `Prefix` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '前缀',
  `OrderType` int NOT NULL COMMENT '单据类型\r\n(1:awo)',
  `Suffix` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '后缀',
  `CreateBy` int NULL DEFAULT NULL COMMENT '创建人',
  `CreateTime` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `UpdateBy` int NULL DEFAULT NULL COMMENT '修改人',
  `UpdateTime` datetime NULL DEFAULT NULL COMMENT '修改时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `OrgKey` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '组织',
  `Team` int NOT NULL COMMENT '部门(1,3)',
  `IsYear` bit(1) NULL DEFAULT b'0' COMMENT '年流水',
  `IsMonth` bit(1) NULL DEFAULT b'0' COMMENT '月流水',
  `IsDay` bit(1) NULL DEFAULT b'0' COMMENT '日流水',
  `EffectiveDate` datetime NOT NULL COMMENT '生效日期',
  PRIMARY KEY (`SequenceID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_sequence_config
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_sequence_generation
-- ----------------------------
DROP TABLE IF EXISTS `cdp_sequence_generation`;
CREATE TABLE `cdp_sequence_generation`  (
  `SequenceConfigId` int NOT NULL COMMENT '序列配置ID',
  `LastSequence` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '当前流水',
  `CreateBy` int NULL DEFAULT NULL,
  `CreateTime` datetime NULL DEFAULT NULL,
  `UpdateBy` int NULL DEFAULT NULL,
  `UpdateTime` datetime NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`SequenceConfigId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_sequence_generation
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_solovpefile
-- ----------------------------
DROP TABLE IF EXISTS `cdp_solovpefile`;
CREATE TABLE `cdp_solovpefile`  (
  `SoloVPEFileID` int NOT NULL AUTO_INCREMENT COMMENT 'SoloVPE文件ID',
  `FileName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `InsertTime` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`SoloVPEFileID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_solovpefile
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_standard_counterweight
-- ----------------------------
DROP TABLE IF EXISTS `cdp_standard_counterweight`;
CREATE TABLE `cdp_standard_counterweight`  (
  `CounterWeightID` int NOT NULL AUTO_INCREMENT,
  `CounterWeightName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '砝码名称',
  `NetWeight` decimal(18, 2) NOT NULL COMMENT '砝码重量',
  `Status` bit(1) NOT NULL COMMENT '是否有效0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`CounterWeightID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---称重标准物' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_standard_counterweight
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_standard_solution
-- ----------------------------
DROP TABLE IF EXISTS `cdp_standard_solution`;
CREATE TABLE `cdp_standard_solution`  (
  `StandardSolutionID` int NOT NULL AUTO_INCREMENT,
  `StandardSolutionName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ItemType` int NULL DEFAULT NULL COMMENT '1标准液体 3电导率',
  `ItemValue` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '更新人',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`StandardSolutionID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---多参数仪标准物' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_standard_solution
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_alarmsetting
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_alarmsetting`;
CREATE TABLE `cdp_testing_alarmsetting`  (
  `TestingAlarmSettingID` int NOT NULL AUTO_INCREMENT,
  `TestingDefID` int NOT NULL COMMENT '检测项目定义',
  `WarningLowerLimit` decimal(18, 4) NULL DEFAULT NULL,
  `WarningUpperLimit` decimal(18, 4) NULL DEFAULT NULL,
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingAlarmSettingID`) USING BTREE,
  INDEX `TestingDefID`(`TestingDefID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_59` FOREIGN KEY (`TestingDefID`) REFERENCES `cdp_testingdef` (`TestingDefID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置---离线检测报警设置' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_alarmsetting
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
  INDEX `FK_Reference_104`(`BGADeviceID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_104` FOREIGN KEY (`BGADeviceID`) REFERENCES `cdp_testing_bgadevice` (`BGADeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `TestingEquipmentID` int NULL DEFAULT NULL,
  `DeviceNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DeviceModel` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '串口相关设置',
  `SerialPortBaudRate` int NULL DEFAULT NULL,
  `SerialPortDataBits` int NULL DEFAULT NULL,
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`BGADeviceID`) USING BTREE,
  INDEX `FK_Reference_103`(`TestingEquipmentID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_103` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '离线检测BGA仪器设备' ROW_FORMAT = DYNAMIC;

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
  `TEMP` decimal(18, 2) NULL DEFAULT NULL,
  `BGADeviceID` int NOT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Position` int NULL DEFAULT NULL COMMENT '位置',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '状态',
  PRIMARY KEY (`TestingBGAOrderID`) USING BTREE,
  INDEX `FK_Reference_97`(`BGADeviceID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_BGAOrder_97` FOREIGN KEY (`BGADeviceID`) REFERENCES `cdp_testing_bgadevice` (`BGADeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `SEQNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OriginalSampleID` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：New 等待检测 (下发订单成功，等待进样开始检测)\r\n3：Start 开始检测   （进样成功检测中）\r\n5：Pending 检测新数据（检测完成待请求检测结果）\r\n7：Closed 检测完成（成功存储检测结果）\r\n9：Abnormal 检测数据丢失（请求检测数据无结果）\r\n18:Overtime 检测超时\r\n99：Cancel  取消检测',
  `Mode` int NULL DEFAULT NULL COMMENT '1:Manual\r\n            3:Automatic',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingBGATaskID`) USING BTREE,
  INDEX `FK_Reference_100`(`BatchID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `SignatureID`(`SignatureUserID` ASC) USING BTREE,
  INDEX `VerifyID`(`VerifyUserID` ASC) USING BTREE,
  INDEX `FK_Reference_105`(`BGADeviceID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_105` FOREIGN KEY (`BGADeviceID`) REFERENCES `cdp_testing_bgadevice` (`BGADeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_BGATask_100` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `Name` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Value` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
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
  `SubSystemIP` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemMAC` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `TestingEquipmentID` int NULL DEFAULT NULL,
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SerialPortBaudRate` int NULL DEFAULT NULL,
  `SerialPortDataBits` int NULL DEFAULT NULL,
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`CedexDeviceID`) USING BTREE,
  INDEX `FK_Reference_106`(`TestingEquipmentID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_106` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `CedexDeviceID` int NULL DEFAULT NULL,
  `PositionNo` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SampleID` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `OriginalSampleID` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '5：Testing\r\n7:  Tested\r\n9:   Uploaded\r\n11:  Signed\r\n13:  Verified\r\n99. Canceled',
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `AbnormalUserID` int NULL DEFAULT NULL,
  `AbnormalTime` datetime NULL DEFAULT NULL,
  `AbnormalReason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsReference` bit(1) NULL DEFAULT NULL COMMENT '是否被引用过',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingCedexTaskID`) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `cdp_testing_cedextaskdtl_ibfk_1`(`SignatureUserID` ASC) USING BTREE,
  INDEX `cdp_testing_cedextaskdtl_ibfk_2`(`VerifyUserID` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = 'cedex检测任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedextask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cedextaskresult
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cedextaskresult`;
CREATE TABLE `cdp_testing_cedextaskresult`  (
  `TestingCedexTaskResultId` int NOT NULL AUTO_INCREMENT,
  `TestingCedexTaskID` int NULL DEFAULT NULL COMMENT '检测详情ID',
  `TestingItem` varchar(5) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测项目',
  `SpecticFactor` decimal(18, 2) NULL DEFAULT NULL COMMENT '稀释倍数',
  `TestingValue` decimal(18, 4) NULL DEFAULT NULL COMMENT '检测结果',
  `TestingValueStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `TestingUnit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '检测单位',
  `Status` int NULL DEFAULT NULL COMMENT '1NotCancel,3Cancel',
  `CancelReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '取消原因',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingCedexTaskResultId`) USING BTREE,
  INDEX `FK_Reference_107`(`TestingCedexTaskID` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_cedextaskresult_ibfk_1` FOREIGN KEY (`TestingCedexTaskID`) REFERENCES `cdp_testing_cedextask` (`TestingCedexTaskID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = 'cedextask检测结果' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cedextaskresult
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_cellconstantcalibration
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_cellconstantcalibration`;
CREATE TABLE `cdp_testing_cellconstantcalibration`  (
  `TestPHCalibrationID` int NOT NULL AUTO_INCREMENT,
  `EquRecordId` int NULL DEFAULT NULL COMMENT '检测记录ID',
  `EquID` int NULL DEFAULT NULL COMMENT '设备ID',
  `StandardSolution` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准液',
  `ValueStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电极常数',
  `Value` decimal(18, 7) NULL DEFAULT NULL COMMENT '电极常数',
  `TestingTime` datetime NULL DEFAULT NULL COMMENT '检测时间点',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '是否有效值',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`TestPHCalibrationID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测多参数仪电极常数记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_cellconstantcalibration
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_concentrationorder
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_concentrationorder`;
CREATE TABLE `cdp_testing_concentrationorder`  (
  `ConcentrationOrderId` int NOT NULL AUTO_INCREMENT,
  `EquId` int NOT NULL COMMENT '设备ID',
  `PreBatchTestingID` int NOT NULL COMMENT '批次检测ID',
  `SampleID` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '样本ID',
  `Baseline` int NULL DEFAULT NULL COMMENT '吸光度',
  `Status` bit(1) NOT NULL COMMENT '是否有效：0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`ConcentrationOrderId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测nd2000记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_concentrationorder
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_concentrationsolovpetask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_concentrationsolovpetask`;
CREATE TABLE `cdp_testing_concentrationsolovpetask`  (
  `ConcentrationSoloVPETaskId` int NOT NULL AUTO_INCREMENT,
  `SampleID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PreBatchTestingID` int NULL DEFAULT NULL,
  `EquId` int NULL DEFAULT NULL,
  `EquRecordId` int NULL DEFAULT NULL COMMENT '任务id',
  `Avg` decimal(11, 5) NULL DEFAULT NULL,
  `RSD` decimal(11, 5) NULL DEFAULT NULL,
  `File` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ECSource` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ECName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ECID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ECValue` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ECUnits` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `UploadFile` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Status` int NOT NULL,
  `ResultTime` datetime NULL DEFAULT NULL,
  `IsDelete` bit(1) NULL DEFAULT NULL,
  PRIMARY KEY (`ConcentrationSoloVPETaskId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测solovpe任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_concentrationsolovpetask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_concentrationsolovpetask_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_concentrationsolovpetask_dtl`;
CREATE TABLE `cdp_testing_concentrationsolovpetask_dtl`  (
  `ConcentrationSoloVPETaskDtlId` int NOT NULL AUTO_INCREMENT,
  `ConcentrationSoloVPETaskId` int NOT NULL,
  `ProteinConc` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RSqr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL,
  PRIMARY KEY (`ConcentrationSoloVPETaskDtlId`) USING BTREE,
  INDEX `ConcentrationSoloVPETaskId`(`ConcentrationSoloVPETaskId` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_concentrationsolovpetask_dtl_ibfk_1` FOREIGN KEY (`ConcentrationSoloVPETaskId`) REFERENCES `cdp_testing_concentrationsolovpetask` (`ConcentrationSoloVPETaskId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测solovpe任务详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_concentrationsolovpetask_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_concentrationtask
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_concentrationtask`;
CREATE TABLE `cdp_testing_concentrationtask`  (
  `ConcentrationTaskId` int NOT NULL AUTO_INCREMENT,
  `EquId` int NOT NULL COMMENT '设备ID',
  `Protein` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `CursorNM` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `CursorAbs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Comments` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BaseLineCorrAbs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `BaseLineCorrNM` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SampleModel` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Software` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Reprocessed` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `MW` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `A1000` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `E1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SSV` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `IntegrationMs` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Serial` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Model` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Firmware` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SampleType` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PreBatchTestingID` int NOT NULL COMMENT '批次检测表',
  `EquRecordId` int NULL DEFAULT NULL COMMENT '检测任务ID',
  `ConcentrationOrderId` int NULL DEFAULT NULL COMMENT '订单ID',
  `SampleID` varchar(128) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '样本ID',
  `ProteinConc` decimal(18, 5) NULL DEFAULT NULL COMMENT '浓度',
  `ProteinConcStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `RSD` decimal(18, 5) NULL DEFAULT NULL COMMENT '平均差',
  `Duration` int NULL DEFAULT NULL COMMENT '距离最近一次blank 时间差',
  `Avg` decimal(18, 5) NULL DEFAULT NULL COMMENT '平均值',
  `Unit` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '单位',
  `A280` decimal(18, 5) NULL DEFAULT NULL COMMENT 'A280',
  `A260280` decimal(18, 5) NULL DEFAULT NULL COMMENT '260/280',
  `Status` int NOT NULL COMMENT '订单状态 \r\n1. 等待中\r\n3. 已检测',
  `SendTime` datetime NULL DEFAULT NULL COMMENT '下发时间',
  `ResultTime` datetime NULL DEFAULT NULL COMMENT '结果时间',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`ConcentrationTaskId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测solovpe任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_concentrationtask
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_d4task
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_d4task`;
CREATE TABLE `cdp_testing_d4task`  (
  `DensityID` int NOT NULL AUTO_INCREMENT,
  `SampleID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `Temp` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Dens` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `OSC` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Conc` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `MeasTime` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `FileName` varchar(120) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL,
  `FailCount` int NULL DEFAULT NULL,
  `CreateTime` datetime NULL DEFAULT NULL,
  `ResultTime` datetime NULL DEFAULT NULL,
  `UploadTime` datetime NULL DEFAULT NULL,
  `CollectionMethod` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `EquID` int NULL DEFAULT NULL,
  `PreBatchTestingID` int NULL DEFAULT NULL,
  `EquRecordId` int NOT NULL,
  `CreateBy` int NULL DEFAULT NULL,
  `UpdateBy` int NULL DEFAULT NULL,
  `UpdateTime` int NULL DEFAULT NULL,
  PRIMARY KEY (`DensityID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测d4任务' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_d4task
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_density
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_density`;
CREATE TABLE `cdp_testing_density`  (
  `DensityID` int NOT NULL AUTO_INCREMENT COMMENT '密度计ID',
  `EquID` int NOT NULL COMMENT '设备ID',
  `PreBatchTestingID` int NULL DEFAULT NULL COMMENT '批次检测ID',
  `EquRecordId` int NULL DEFAULT NULL COMMENT '检测任务ID',
  `ValueStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '密度结果',
  `Value` decimal(18, 5) NULL DEFAULT NULL COMMENT '密度结果',
  `TestingTime` datetime NULL DEFAULT NULL COMMENT '检测时间点',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '是否有效值',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`DensityID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '下游检测密度计' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_density
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_equipment
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_equipment`;
CREATE TABLE `cdp_testing_equipment`  (
  `TestingEquipmentID` int NOT NULL AUTO_INCREMENT,
  `EquipmentType` int NOT NULL COMMENT '1：BGA\r\n            3：Vicell\r\n            5：OSMO\r\n            7：Cedex',
  `EquipmentNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialNumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `PrivateKey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `AssetNo` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `EquipmenModel` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `PrincipalId` int NULL DEFAULT NULL,
  `Description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingEquipmentID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '离线检测----设备管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_equipment
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_filterintegrity
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_filterintegrity`;
CREATE TABLE `cdp_testing_filterintegrity`  (
  `TestingFilterIntegrityId` int NOT NULL AUTO_INCREMENT,
  `EquId` int NULL DEFAULT NULL COMMENT '设备ID',
  `PreBatchTestingID` int NULL DEFAULT NULL COMMENT '批次检测ID',
  `EquRecordId` int NULL DEFAULT NULL COMMENT '检测任务ID',
  `ReportName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '报告名称',
  `FilePath` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '文件路径',
  `Product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Productlot` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Filter` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Filterlot` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Comment1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Comment2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Comment3` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Evaluation` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Type` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '类型',
  `Result` decimal(18, 5) NULL DEFAULT NULL COMMENT '结果',
  `Status` int NOT NULL COMMENT '订单状态 \r\n1. 等待中\r\n3. 已检测\r\n5. 已绑定',
  `SendTime` datetime NULL DEFAULT NULL COMMENT '下发时间',
  `ResultTime` datetime NULL DEFAULT NULL COMMENT '结果时间',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`TestingFilterIntegrityId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----完整性测试仪' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_filterintegrity
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_multiparameter
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_multiparameter`;
CREATE TABLE `cdp_testing_multiparameter`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `EquID` int NOT NULL COMMENT '设备ID',
  `PreBatchTestingID` int NULL DEFAULT NULL COMMENT '批次检测ID',
  `EquRecordId` int NULL DEFAULT NULL COMMENT '任务ID',
  `DataType` int NULL DEFAULT NULL COMMENT '数据类型 \r\n1. PH\r\n2. 电导率\r\n3. pH和电导率\r\n4. ph 验证',
  `TempStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '温度',
  `Temp` decimal(18, 5) NULL DEFAULT NULL COMMENT '温度',
  `PHStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT 'PH',
  `PH` decimal(18, 5) NULL DEFAULT NULL COMMENT 'PH',
  `CondStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '电导率',
  `Cond` decimal(18, 5) NULL DEFAULT NULL COMMENT '电导率',
  `TestingTime` datetime NULL DEFAULT NULL COMMENT '检测时间点',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '是否有效值',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----多参数仪' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_multiparameter
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_osmodevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_osmodevice`;
CREATE TABLE `cdp_testing_osmodevice`  (
  `OSMODeviceID` int NOT NULL AUTO_INCREMENT,
  `TestingEquipmentID` int NULL DEFAULT NULL,
  `SubSystemMAC` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemIP` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SerialPortName` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortBaudRate` int NULL DEFAULT NULL,
  `SerialPortDataBits` int NULL DEFAULT NULL,
  `SerialPortStopBits` varchar(8) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortParity` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SerialPortFlowType` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`OSMODeviceID`) USING BTREE,
  INDEX `FK_Reference_108`(`TestingEquipmentID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_108` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `PositionNo` int NULL DEFAULT NULL COMMENT '位置',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Status` bit(1) NULL DEFAULT NULL COMMENT '1下发 0暂存',
  `TempSave_by` int NULL DEFAULT NULL COMMENT '暂存人',
  `TempSave_time` datetime NULL DEFAULT NULL COMMENT '暂存时间',
  PRIMARY KEY (`TestingOSMOOrderID`) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `FK_Reference_109`(`OSMODeviceID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_109` FOREIGN KEY (`OSMODeviceID`) REFERENCES `cdp_testing_osmodevice` (`OSMODeviceID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  INDEX `OSMODeviceNo`(`OSMODeviceID` ASC) USING BTREE
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
  `OriginalSampleID` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n3：Testing\r\n5：Tested\r\n9:  Uploaded\r\n11: Signed\r\n13: Verified\r\n99. Canceled',
  `OSMO` decimal(18, 4) NULL DEFAULT NULL COMMENT '结果数据',
  `OSMOStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL COMMENT '结果数据',
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingOSMOTaskDtlID`) USING BTREE,
  INDEX `FK_Reference_88`(`TestingOSMOTaskID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `SignatureUserID`(`SignatureUserID` ASC) USING BTREE,
  INDEX `VerifyUserID`(`VerifyUserID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_88` FOREIGN KEY (`TestingOSMOTaskID`) REFERENCES `cdp_testing_osmotask` (`TestingOSMOTaskID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '下游检测osmo检测任务详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_osmotaskdtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_phcalibration
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_phcalibration`;
CREATE TABLE `cdp_testing_phcalibration`  (
  `TestPHCalibrationID` int NOT NULL AUTO_INCREMENT,
  `EquRecordId` int NULL DEFAULT NULL COMMENT '检测记录ID',
  `EquID` int NULL DEFAULT NULL COMMENT '设备ID',
  `StandardSolution` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '校准液',
  `PHStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `PH` decimal(18, 2) NULL DEFAULT NULL,
  `mVStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `mV` decimal(18, 2) NULL DEFAULT NULL COMMENT '电压',
  `TempStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '温度',
  `Temp` decimal(18, 2) NULL DEFAULT NULL COMMENT '温度',
  `SlopeStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '斜率',
  `Slope` decimal(18, 2) NULL DEFAULT NULL COMMENT '斜率',
  `OffsetStr` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '偏移量',
  `Offset` decimal(18, 2) NULL DEFAULT NULL COMMENT '偏移量',
  `TestingTime` datetime NULL DEFAULT NULL COMMENT '检测时间点',
  `Status` bit(1) NULL DEFAULT NULL COMMENT '是否有效值',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除：0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '末次更新人id',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`TestPHCalibrationID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----ph校准' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_phcalibration
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
  `TestCategory` int NULL DEFAULT NULL COMMENT '1.Bga 3.Osmo 5.Vicell 7.Cedex 9.CedexSingular',
  PRIMARY KEY (`TestingSignatureID`) USING BTREE
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
  `Context` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  PRIMARY KEY (`TestingSignatureDtlID`) USING BTREE,
  INDEX `TestingSignatureID`(`TestingSignatureID` ASC) USING BTREE,
  CONSTRAINT `cdp_testing_signaturedtl_ibfk_1` FOREIGN KEY (`TestingSignatureID`) REFERENCES `cdp_testing_signature` (`TestingSignatureID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '离线检测----数字签名详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_signaturedtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_step
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_step`;
CREATE TABLE `cdp_testing_step`  (
  `StepID` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `StepName` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '步骤名称',
  `Status` bit(1) NOT NULL COMMENT '是否有效 0否1是',
  `IsDelete` bit(1) NOT NULL COMMENT '是否删除 0否1是',
  `Created_by` int NOT NULL COMMENT '创建人id',
  `Creation_time` datetime NOT NULL COMMENT '创建时间',
  `Last_updated_by` int NOT NULL COMMENT '末次更新人',
  `Last_update_time` datetime NOT NULL COMMENT '末次更新时间',
  PRIMARY KEY (`StepID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统设置----下游离线检测---步骤管理' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_testing_step
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_testing_vicelldevice
-- ----------------------------
DROP TABLE IF EXISTS `cdp_testing_vicelldevice`;
CREATE TABLE `cdp_testing_vicelldevice`  (
  `VicellDeviceID` int NOT NULL AUTO_INCREMENT,
  `TestingEquipmentID` int NULL DEFAULT NULL,
  `SubSystemMAC` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SubSystemIP` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ExcelPath` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `WasteUpperLimit` int NOT NULL DEFAULT 0 COMMENT '废料上限',
  `CurrentWasteCount` int NOT NULL DEFAULT 0 COMMENT '当前废料数',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`VicellDeviceID`) USING BTREE,
  INDEX `FK_Reference_110`(`TestingEquipmentID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_110` FOREIGN KEY (`TestingEquipmentID`) REFERENCES `cdp_testing_equipment` (`TestingEquipmentID`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  INDEX `VicellDeviceNo`(`VicellDeviceID` ASC) USING BTREE
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
  `OriginalSampleID` varchar(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `CellType` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `DilutionFactor` decimal(18, 2) NULL DEFAULT NULL,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `StartTime` datetime NULL DEFAULT NULL,
  `EndTime` datetime NULL DEFAULT NULL,
  `VCD` decimal(18, 4) NULL DEFAULT NULL COMMENT '物料明细ID',
  `Viability` decimal(18, 4) NULL DEFAULT NULL COMMENT 'ID',
  `AvgDiam` decimal(18, 4) NULL DEFAULT NULL COMMENT 'ID',
  `VCDStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ViabilityStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `AvgDiamStr` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1：New\r\n3：Testing\r\n5:  Tested\r\n9:  Uploaded\r\n11: Signed\r\n13: Verified\r\n99. Canceled',
  `ExcelFileLocation` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UploadUserID` int NULL DEFAULT NULL COMMENT '上传人ID',
  `UploadTime` datetime NULL DEFAULT NULL COMMENT '上传时间',
  `UploadRevokeReason` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `UploadRevokeRemark` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `SignatureUserID` int NULL DEFAULT NULL COMMENT '签名人ID',
  `SignatureTime` datetime NULL DEFAULT NULL COMMENT '签名时间',
  `IsDesignate` bit(1) NULL DEFAULT NULL COMMENT '是否指定',
  `VerifyUserID` int NULL DEFAULT NULL COMMENT '审核人ID',
  `VerifyTime` datetime NULL DEFAULT NULL COMMENT '审核时间',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`TestingVicellTaskDtlID`) USING BTREE,
  INDEX `FK_Reference_87`(`TestingVicellTaskID` ASC) USING BTREE,
  INDEX `SampleID`(`SampleID` ASC) USING BTREE,
  INDEX `cdp_testing_vicelltaskdtl_ibfk_1`(`SignatureUserID` ASC) USING BTREE,
  INDEX `cdp_testing_vicelltaskdtl_ibfk_2`(`VerifyUserID` ASC) USING BTREE,
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
  `TestingType` int NULL DEFAULT NULL COMMENT 'BGA 1\r\n            Vicell 3\r\n            OMSO 5\r\n            Cedex 7',
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
  `MinY` decimal(18, 3) NULL DEFAULT NULL COMMENT 'Y轴最小值',
  `MaxY` decimal(18, 3) NULL DEFAULT NULL COMMENT 'Y轴最大值',
  `IsDelete` bit(1) NULL DEFAULT NULL,
  `Create_by` int NULL DEFAULT NULL,
  `Create_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_updated_time` datetime NULL DEFAULT NULL,
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
  `BeforeData` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `AfterData` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL,
  `IPAddress` varchar(30) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  PRIMARY KEY (`OperateId`) USING BTREE,
  INDEX `FK_Reference_42`(`UserId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_42` FOREIGN KEY (`UserId`) REFERENCES `auth_user` (`UserId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '用户操作记录' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_useroperatelog
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_weightdata
-- ----------------------------
DROP TABLE IF EXISTS `cdp_weightdata`;
CREATE TABLE `cdp_weightdata`  (
  `WeightID` int NOT NULL AUTO_INCREMENT,
  `Weight` decimal(11, 2) NULL DEFAULT NULL,
  `Time` datetime NULL DEFAULT NULL,
  `WeightUnit` varchar(11) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`WeightID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_weightdata
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow`;
CREATE TABLE `cdp_workflow`  (
  `WorkflowID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowType` int NULL DEFAULT NULL COMMENT '1.Start Culture\r\n3.Inoculation\r\n5.Feeding Unit Connection\r\n7.Supply Liquid(Sampling Unit)\r\n9.Supply Liquid(Feeding Unit)\r\n11.Waste Clean\r\n13.Material Import\r\n15.Complete Culture\r\n17.Feeding Other\r\n19.Feeding Manual\r\n21.Sampling Manual',
  `UserID` int NOT NULL COMMENT 'UserID',
  `EquReactorId` int NULL DEFAULT NULL COMMENT '反应器ID',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人ID',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Creation_FinishTime` datetime NULL DEFAULT NULL,
  `Creation_FinishBy` int NULL DEFAULT NULL COMMENT '记录完成人',
  `CancelTime` datetime NULL DEFAULT NULL COMMENT '取消时间',
  `CancelUser` int NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`WorkflowID`) USING BTREE
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
  `Status` int NULL DEFAULT NULL COMMENT '1:开始\r\n            3:完成Workflow\r\n            99:取消',
  PRIMARY KEY (`BatchCompleteID`) USING BTREE,
  INDEX `FK_Reference_75`(`WorkflowID` ASC) USING BTREE,
  INDEX `FK_Reference_78`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `FK_BatchComplete_Reference_75` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_78` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流--结束细胞培养' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchcomplete
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchfeedingunitconnection
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchfeedingunitconnection`;
CREATE TABLE `cdp_workflow_batchfeedingunitconnection`  (
  `BatchFeedingUnitConnectionID` int NOT NULL AUTO_INCREMENT,
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `Status` int NULL DEFAULT NULL COMMENT '1:用户开始连接补料单元\r\n            3:完成Workflow\r\n            99:取消',
  PRIMARY KEY (`BatchFeedingUnitConnectionID`) USING BTREE,
  INDEX `WorkflowID`(`WorkflowID` ASC) USING BTREE,
  INDEX `FK_Reference_76`(`BatchID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_batchsupplyconnection_ibfk_1` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_76` FOREIGN KEY (`BatchID`) REFERENCES `cdp_batch` (`BatchID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---连接补料单元' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchfeedingunitconnection
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchfeedingunitconnection_dtl
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchfeedingunitconnection_dtl`;
CREATE TABLE `cdp_workflow_batchfeedingunitconnection_dtl`  (
  `BatchFeedingUnitConnectionDtlID` int NOT NULL AUTO_INCREMENT,
  `BatchFeedingUnitConnectionID` int NULL DEFAULT NULL COMMENT 'ID',
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `ItemDefBagID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `WeightMediumBefore` decimal(18, 2) NULL DEFAULT NULL,
  `WeightMediumBeforeUserId` decimal(18, 2) NULL DEFAULT NULL,
  `WeightMediumAfter` decimal(18, 2) NULL DEFAULT NULL,
  `WeightMediumAfterUserId` int NULL DEFAULT NULL,
  `MediumRoughWeight` decimal(18, 2) NULL DEFAULT NULL,
  `LiquidBagTareWeight` decimal(18, 2) NULL DEFAULT NULL,
  `MediumNetWeight` decimal(18, 2) NULL DEFAULT NULL,
  `ModeStatus` bit(1) NULL DEFAULT NULL COMMENT '内控模式 1是指定的 其他都是非指定的',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '最后操作时间',
  PRIMARY KEY (`BatchFeedingUnitConnectionDtlID`) USING BTREE,
  INDEX `WorkflowID`(`BatchFeedingUnitConnectionID` ASC) USING BTREE,
  INDEX `FK_Reference_134`(`ItemDefBagID` ASC) USING BTREE,
  CONSTRAINT `cdp_workflow_batchfeedingunitconnection_dtl_ibfk_1` FOREIGN KEY (`ItemDefBagID`) REFERENCES `cdp_item_def_bag` (`ItemDefBagID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `cdp_workflow_batchfeedingunitconnection_dtl_ibfk_3` FOREIGN KEY (`BatchFeedingUnitConnectionID`) REFERENCES `cdp_workflow_batchfeedingunitconnection` (`BatchFeedingUnitConnectionID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---连接补料单元详情' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_batchfeedingunitconnection_dtl
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_batchinoculation
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_batchinoculation`;
CREATE TABLE `cdp_workflow_batchinoculation`  (
  `BatchInoculationID` int NOT NULL AUTO_INCREMENT,
  `BatchID` int NULL DEFAULT NULL COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `WeightSeedBefore` decimal(18, 2) NULL DEFAULT NULL,
  `WeightSeedBeforeUserId` decimal(18, 2) NULL DEFAULT NULL,
  `WeightSeedAfter` decimal(18, 2) NULL DEFAULT NULL,
  `WeightSeedAfterUserId` int NULL DEFAULT NULL,
  `SeedNetWeight` decimal(18, 2) NULL DEFAULT NULL,
  `Status` int NOT NULL COMMENT '1:用户开始接种\r\n            3:完成Workflow\r\n            99:取消',
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
-- Table structure for cdp_workflow_feedingmanual
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_feedingmanual`;
CREATE TABLE `cdp_workflow_feedingmanual`  (
  `FeedingManualID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT '流程ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `ItemDefFeedingMediumID` int NULL DEFAULT NULL COMMENT '物料定义ID',
  `MediumVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料液量',
  `Status` int NULL DEFAULT NULL COMMENT '1:开始\r\n            3:完成Workflow\r\n            99:取消',
  PRIMARY KEY (`FeedingManualID`) USING BTREE,
  INDEX `FK_Reference_135`(`ItemDefFeedingMediumID` ASC) USING BTREE,
  INDEX `FK_FeedingManual_Reference_78`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `FK_FeedingManual_Reference_78` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_135` FOREIGN KEY (`ItemDefFeedingMediumID`) REFERENCES `cdp_item_def_feedingmedium` (`ItemDefFeedingMediumID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '工作流---手动补料' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_feedingmanual
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_liquidimport_supplyunit
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_liquidimport_supplyunit`;
CREATE TABLE `cdp_workflow_liquidimport_supplyunit`  (
  `SupplyUnitLiquidImportID` int NOT NULL AUTO_INCREMENT,
  `WorkflowID` int NULL DEFAULT NULL COMMENT 'ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `EquFeedingScaleId` int NULL DEFAULT NULL,
  `FeedingPumpNo` int NULL DEFAULT NULL,
  `ExportItemDefBagID` int NULL DEFAULT NULL,
  `ExportFluidDefID` int NULL DEFAULT NULL,
  `ExportVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT 'μL',
  `lotNo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NULL DEFAULT NULL,
  `ExpirationDate` datetime NULL DEFAULT NULL COMMENT '过期时间',
  `LiquidBagTareWeight` decimal(18, 2) NULL DEFAULT NULL,
  `MediumRoughBefore` decimal(18, 2) NULL DEFAULT NULL,
  `WeightMediumBeforeUserId` decimal(18, 2) NULL DEFAULT NULL,
  `MediumRoughAfter` decimal(18, 2) NULL DEFAULT NULL,
  `WeightMediumAfterUserId` int NULL DEFAULT NULL,
  `MediumNetWeight` decimal(18, 2) NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1.开始\r\n            3.完成Workflow\r\n            99：取消',
  `ReplaceItemDefBagId` int NULL DEFAULT NULL COMMENT '替换液袋id',
  `ReplaceTareWeight` decimal(11, 0) NULL DEFAULT NULL COMMENT '替换的液袋皮重',
  PRIMARY KEY (`SupplyUnitLiquidImportID`) USING BTREE,
  INDEX `FK_Reference_76`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `FK_LiquidImport_SupplyUnit_Reference_76` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_bin COMMENT = '工作流---更换手动补料' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_liquidimport_supplyunit
-- ----------------------------

-- ----------------------------
-- Table structure for cdp_workflow_samplingmanual
-- ----------------------------
DROP TABLE IF EXISTS `cdp_workflow_samplingmanual`;
CREATE TABLE `cdp_workflow_samplingmanual`  (
  `SamplingManualID` int NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `WorkflowID` int NULL DEFAULT NULL COMMENT '流程ID',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `SampleVolume` decimal(18, 2) NULL DEFAULT NULL COMMENT '补料液量',
  `Type` int NULL DEFAULT NULL COMMENT '1:Sample、3：Preserve',
  `Status` int NULL DEFAULT NULL COMMENT '1:开始\r\n            3:完成Workflow\r\n            99:取消',
  PRIMARY KEY (`SamplingManualID`) USING BTREE,
  INDEX `FK_Reference_79`(`WorkflowID` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_79` FOREIGN KEY (`WorkflowID`) REFERENCES `cdp_workflow` (`WorkflowID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '工作流---手动取样' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cdp_workflow_samplingmanual
-- ----------------------------

-- ----------------------------
-- Table structure for da100data
-- ----------------------------
DROP TABLE IF EXISTS `da100data`;
CREATE TABLE `da100data`  (
  `DA100ID` int NOT NULL AUTO_INCREMENT,
  `SampleID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Date` datetime NULL DEFAULT NULL,
  `Temp` decimal(11, 3) NULL DEFAULT NULL,
  `Dens` decimal(11, 3) NULL DEFAULT NULL,
  `Sg` decimal(11, 3) NULL DEFAULT NULL,
  `Conc` decimal(11, 3) NULL DEFAULT NULL,
  `MeasTime` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL COMMENT '1:下发  \r\n3:执行中  \r\n5:执行完成  \r\n99:取消  ',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`DA100ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of da100data
-- ----------------------------

-- ----------------------------
-- Table structure for sys_globalsetting
-- ----------------------------
DROP TABLE IF EXISTS `sys_globalsetting`;
CREATE TABLE `sys_globalsetting`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KeyVal` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Val` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `Description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL,
  `Creation_time` datetime NULL DEFAULT NULL,
  `Last_updated_by` int NULL DEFAULT NULL,
  `Last_update_time` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '无用' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_globalsetting
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_email_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_email_rec`;
CREATE TABLE `sys_notification_email_rec`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '通知主键',
  `NotificationRecId` int NULL DEFAULT NULL,
  `From` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人',
  `CC` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `UserID` int NULL DEFAULT NULL COMMENT '用户',
  `Email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '邮件',
  `SenderPlatformName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发送平台名称',
  `Subject` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '主题',
  `Body` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '邮件主体',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `FK_Reference_56`(`NotificationRecId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_56` FOREIGN KEY (`NotificationRecId`) REFERENCES `sys_notification_rec` (`NotificationRecId`) ON DELETE RESTRICT ON UPDATE RESTRICT
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
  `SenderPlatformName` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人平台地址',
  `EmailServiceAddress` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发送邮件服务器地址',
  `EmailServicePort` int NOT NULL COMMENT '发送邮件服务器端口',
  `SendAccount` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发件人账号',
  `SenderPassword` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人密码',
  `FromEmail` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人邮箱',
  `FromDefault` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发件人默认邮箱',
  PRIMARY KEY (`EmailSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '邮件通知设置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_emailsetting
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_rec`;
CREATE TABLE `sys_notification_rec`  (
  `NotificationRecId` int NOT NULL AUTO_INCREMENT COMMENT '消息记录ID',
  `NotificationCode` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '消息提醒Code',
  `BatchID` int NULL DEFAULT NULL COMMENT '批次ID',
  `SecondID` int NULL DEFAULT NULL COMMENT '第二ID\r\n\r\n\r\nPumpID\r\n检测设备ID',
  `SendTime` datetime NULL DEFAULT NULL COMMENT '发送时间',
  `DeviceUserID` int NULL DEFAULT NULL COMMENT '设备用户ID',
  PRIMARY KEY (`NotificationRecId`) USING BTREE,
  INDEX `NotificationRecId`(`NotificationRecId` ASC) USING BTREE,
  INDEX `SendTime`(`SendTime` ASC) USING BTREE
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
  `NotificationDescription` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '描述',
  `BufferEditable` bit(1) NULL DEFAULT b'0' COMMENT '间隔时间是否可编辑',
  `NotificationTimeBuffer` int NOT NULL COMMENT '描述',
  `NotificationTime` int NULL DEFAULT NULL COMMENT '通知时间',
  `NotificationTimeOfStart` int NULL DEFAULT NULL COMMENT '自定义 起始时间',
  `NotificationTimeOfEnd` int NULL DEFAULT NULL COMMENT '自定义 结束时间',
  `NotificationMethodOfWeb` bit(1) NOT NULL DEFAULT b'0',
  `NotificationMethodOfEmail` bit(1) NOT NULL DEFAULT b'0',
  `NotificationMethodOfPhone` bit(1) NOT NULL DEFAULT b'0',
  `NotificationMethodOfWechart` bit(1) NOT NULL DEFAULT b'0',
  `NotificationFrequency` int NULL DEFAULT NULL COMMENT '通知频率',
  `NotificationFrequencyOfMinutes` int NULL DEFAULT NULL COMMENT '多少分钟通知一次',
  `IsDelete` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人主键',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '记录修改人主键',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '记录修改时间',
  PRIMARY KEY (`NotificationSettingID`) USING BTREE,
  INDEX `NotificationCode`(`NotificationCode` ASC) USING BTREE
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
  `LabID` int NULL DEFAULT NULL COMMENT '机器ID',
  `NotificationRecId` int NULL DEFAULT NULL,
  `Title` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '标题',
  `NotificationContent` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '通知内容',
  `Status` bit(1) NOT NULL DEFAULT b'1',
  `UserId` int NOT NULL DEFAULT 0,
  `NotificationFlag` bit(1) NOT NULL DEFAULT b'0',
  `Created_by` int NULL DEFAULT NULL COMMENT '记录创建人主键',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '记录创建时间',
  `Last_updated_by` int NULL DEFAULT NULL COMMENT '记录修改人主键',
  `Last_update_time` datetime NULL DEFAULT NULL COMMENT '记录修改时间',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `FK_Reference_58`(`NotificationRecId` ASC) USING BTREE,
  INDEX `FK_Reference_55`(`UserId` ASC) USING BTREE,
  INDEX `Status`(`Status` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_58` FOREIGN KEY (`NotificationRecId`) REFERENCES `sys_notification_rec` (`NotificationRecId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '站内通知记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_site_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_sms_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_sms_rec`;
CREATE TABLE `sys_notification_sms_rec`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '通知主键',
  `NotificationRecId` int NULL DEFAULT NULL,
  `Subject` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '主题',
  `Body` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '主体',
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '手机',
  `UserID` int NULL DEFAULT NULL COMMENT '用户ID',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `FK_Reference_57`(`NotificationRecId` ASC) USING BTREE,
  CONSTRAINT `sys_notification_sms_rec_ibfk_1` FOREIGN KEY (`NotificationRecId`) REFERENCES `sys_notification_rec` (`NotificationRecId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '短信通知记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_sms_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_smssetting
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_smssetting`;
CREATE TABLE `sys_notification_smssetting`  (
  `SmsSettingId` int NOT NULL AUTO_INCREMENT COMMENT '自增主键',
  `SpCode` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'Sp编码',
  `Account` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '账号',
  `Secret` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '密码',
  `Url` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT 'Url',
  `Creation_time` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `Created_by` int NULL DEFAULT NULL COMMENT '创建人',
  PRIMARY KEY (`SmsSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_smssetting
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_wechart_rec
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_wechart_rec`;
CREATE TABLE `sys_notification_wechart_rec`  (
  `ID` int NOT NULL AUTO_INCREMENT COMMENT '通知主键',
  `NotificationRecId` int NULL DEFAULT NULL,
  `CorpId` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人邮箱',
  `AgentId` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发件人默认邮箱',
  `Subject` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '主题',
  `Body` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL COMMENT '主体',
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '手机',
  `UserID` int NULL DEFAULT NULL COMMENT '用户ID',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `FK_Reference_57`(`NotificationRecId` ASC) USING BTREE,
  CONSTRAINT `FK_Reference_57` FOREIGN KEY (`NotificationRecId`) REFERENCES `sys_notification_rec` (`NotificationRecId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '邮件通知记录表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_wechart_rec
-- ----------------------------

-- ----------------------------
-- Table structure for sys_notification_wechartsetting
-- ----------------------------
DROP TABLE IF EXISTS `sys_notification_wechartsetting`;
CREATE TABLE `sys_notification_wechartsetting`  (
  `WechartSettingId` int NOT NULL AUTO_INCREMENT COMMENT '通知设置主键',
  `CorpId` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人邮箱',
  `AgentId` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '发件人默认邮箱',
  `Corpsecret` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '发件人密码',
  PRIMARY KEY (`WechartSettingId`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '邮件通知设置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_notification_wechartsetting
-- ----------------------------

-- ----------------------------
-- View structure for v_electronic_configuration_sheet
-- ----------------------------
DROP VIEW IF EXISTS `v_electronic_configuration_sheet`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `v_electronic_configuration_sheet` AS select `td`.`TestingDescription` AS `Test_Item`,`tbtr`.`Value` AS `Value`,`td`.`Unit` AS `Unit`,substring_index(`tbt`.`SampleID`,'-',1) AS `Mark`,substring_index(`tbt`.`SampleID`,'-',-(1)) AS `CultureIdentity`,`te`.`EquipmentNo` AS `Instrument_Code`,`tbt`.`StartTime` AS `SampleTime`,`tbt`.`EndTime` AS `TestingTime` from ((((`cdp_testing_bgataskresult` `tbtr` join `cdp_testing_bgatask` `tbt` on((`tbtr`.`TestingBGATaskID` = `tbt`.`TestingBGATaskID`))) join `cdp_testing_bgadevice` `bd` on((`tbt`.`BGADeviceID` = `bd`.`BGADeviceID`))) join `cdp_testing_equipment` `te` on((`bd`.`TestingEquipmentID` = `te`.`TestingEquipmentID`))) left join `cdp_testingdef` `td` on((`tbtr`.`Name` = `td`.`TestingNo`))) where ((`tbt`.`Status` > 5) and substring_index(`tbt`.`SampleID`,'-',-(1)) in (select `c`.`CultureCode` from ((`cdp_preculture` `c` join `cdp_prebatch` `pb` on((`c`.`PreBatchId` = `pb`.`PreBatchId`))) join `cdp_project` `p` on((`pb`.`ProjectId` = `p`.`ProjectId`))) where ((`c`.`IsDelete` <> 1) and (`pb`.`IsDelete` <> 1) and (`p`.`IsDelete` <> 1))) and (`td`.`TestingType` = 1) and (`tbt`.`IsDelete` <> 1) and (`bd`.`IsDelete` <> 1) and (`te`.`IsDelete` <> 1) and (`td`.`IsDelete` <> 1)) union all select `td`.`TestingDescription` AS `Test_Item`,`otd`.`OSMO` AS `Value`,`td`.`Unit` AS `Unit`,substring_index(`otd`.`SampleID`,'-',1) AS `Mark`,substring_index(`otd`.`SampleID`,'-',-(1)) AS `CultureIdentity`,`te`.`EquipmentNo` AS `Instrument_Code`,`otd`.`StartTime` AS `SampleTime`,`otd`.`EndTime` AS `TestingTime` from ((((`cdp_testing_osmotaskdtl` `otd` join `cdp_testing_osmotask` `ot` on((`otd`.`TestingOSMOTaskID` = `ot`.`TestingOSMOTaskID`))) join `cdp_testing_osmodevice` `od` on((`ot`.`OSMODeviceID` = `od`.`OSMODeviceID`))) join `cdp_testing_equipment` `te` on((`od`.`TestingEquipmentID` = `te`.`TestingEquipmentID`))) left join `cdp_testingdef` `td` on(('OSMO' = `td`.`TestingNo`))) where ((`otd`.`Status` >= 5) and substring_index(`otd`.`SampleID`,'-',-(1)) in (select `c`.`CultureCode` from ((`cdp_preculture` `c` join `cdp_prebatch` `pb` on((`c`.`PreBatchId` = `pb`.`PreBatchId`))) join `cdp_project` `p` on((`pb`.`ProjectId` = `p`.`ProjectId`))) where ((`c`.`IsDelete` <> 1) and (`pb`.`IsDelete` <> 1) and (`p`.`IsDelete` <> 1))) and (`td`.`TestingType` = 5) and (`otd`.`IsDelete` <> 1) and (`ot`.`IsDelete` <> 1) and (`od`.`IsDelete` <> 1) and (`te`.`IsDelete` <> 1) and (`td`.`IsDelete` <> 1)) union all select `td`.`TestingDescription` AS `Test_Item`,(case when (`td`.`TestingDescription` = 'VCD') then `tvtd`.`VCD` when (`td`.`TestingDescription` = 'Viability') then `tvtd`.`Viability` else `tvtd`.`AvgDiam` end) AS `Value`,`td`.`Unit` AS `Unit`,substring_index(`tvtd`.`SampleID`,'-',1) AS `Mark`,substring_index(`tvtd`.`SampleID`,'-',-(1)) AS `CultureIdentity`,`te`.`EquipmentNo` AS `Instrument_Code`,`tvtd`.`StartTime` AS `SampleTime`,`tvtd`.`EndTime` AS `TestingTime` from ((((`cdp_testing_vicelltaskdtl` `tvtd` join `cdp_testing_vicelltask` `tvt` on((`tvtd`.`TestingVicellTaskID` = `tvt`.`TestingVicellTaskID`))) join `cdp_testing_vicelldevice` `tvd` on((`tvt`.`VicellDeviceID` = `tvd`.`VicellDeviceID`))) join `cdp_testing_equipment` `te` on((`tvd`.`TestingEquipmentID` = `te`.`TestingEquipmentID`))) left join (select `cdp_testingdef`.`TestingDefID` AS `TestingDefID`,`cdp_testingdef`.`TestingNo` AS `TestingNo`,`cdp_testingdef`.`TestingName` AS `TestingName`,`cdp_testingdef`.`TestingDescription` AS `TestingDescription`,`cdp_testingdef`.`TestingType` AS `TestingType`,`cdp_testingdef`.`UpperLimit` AS `UpperLimit`,`cdp_testingdef`.`LowerLimit` AS `LowerLimit`,`cdp_testingdef`.`IsDataSignature` AS `IsDataSignature`,`cdp_testingdef`.`Unit` AS `Unit`,`cdp_testingdef`.`Status` AS `Status`,`cdp_testingdef`.`IsDelete` AS `IsDelete`,`cdp_testingdef`.`Created_by` AS `Created_by`,`cdp_testingdef`.`Creation_time` AS `Creation_time`,`cdp_testingdef`.`Last_updated_by` AS `Last_updated_by`,`cdp_testingdef`.`Last_update_time` AS `Last_update_time` from `cdp_testingdef` where ((`cdp_testingdef`.`TestingType` = 3) and ((`cdp_testingdef`.`TestingDefID` = 7) or (`cdp_testingdef`.`TestingDefID` = 8) or (`cdp_testingdef`.`TestingDefID` = 9)))) `td` on((1 = 1))) where ((`tvtd`.`Status` >= 5) and substring_index(`tvtd`.`SampleID`,'-',-(1)) in (select `c`.`CultureCode` from ((`cdp_preculture` `c` join `cdp_prebatch` `pb` on((`c`.`PreBatchId` = `pb`.`PreBatchId`))) join `cdp_project` `p` on((`pb`.`ProjectId` = `p`.`ProjectId`))) where ((`c`.`IsDelete` <> 1) and (`pb`.`IsDelete` <> 1) and (`p`.`IsDelete` <> 1))) and (`tvtd`.`IsDelete` <> 1) and (`te`.`IsDelete` <> 1) and (`tvt`.`IsDelete` <> 1) and (`tvd`.`IsDelete` <> 1)) union all select `td`.`TestingDescription` AS `Test_Item`,`tctr`.`TestingValue` AS `Value`,`td`.`Unit` AS `Unit`,substring_index(`tctd`.`SampleID`,'-',1) AS `Mark`,substring_index(`tctd`.`SampleID`,'-',-(1)) AS `CultureIdentity`,`te`.`EquipmentNo` AS `Instrument_Code`,`tctd`.`StartTime` AS `SampleTime`,`tctd`.`EndTime` AS `TestingTime` from ((((`cdp_testing_cedextaskresult` `tctr` join (select `cdp_testing_cedextask`.`SampleID` AS `SampleID`,`cdp_testing_cedextask`.`StartTime` AS `StartTime`,`cdp_testing_cedextask`.`EndTime` AS `EndTime`,`cdp_testing_cedextask`.`TestingCedexTaskID` AS `TestingCedexTaskID`,`cdp_testing_cedextask`.`CedexDeviceID` AS `CedexDeviceID`,`cdp_testing_cedextask`.`Status` AS `Status` from `cdp_testing_cedextask` where (substring_index(`cdp_testing_cedextask`.`SampleID`,'-',-(1)) in (select `c`.`CultureCode` from ((`cdp_preculture` `c` join `cdp_prebatch` `pb` on((`c`.`PreBatchId` = `pb`.`PreBatchId`))) join `cdp_project` `p` on((`pb`.`ProjectId` = `p`.`ProjectId`))) where ((`c`.`IsDelete` <> 1) and (`pb`.`IsDelete` <> 1) and (`p`.`IsDelete` <> 1))) and (`cdp_testing_cedextask`.`IsDelete` <> 1))) `tctd` on((`tctr`.`TestingCedexTaskID` = `tctd`.`TestingCedexTaskID`))) join `cdp_testing_cedexdevice` `tcd` on((`tctd`.`CedexDeviceID` = `tcd`.`CedexDeviceID`))) join `cdp_testing_equipment` `te` on((`tcd`.`TestingEquipmentID` = `te`.`TestingEquipmentID`))) left join `cdp_testingdef` `td` on((`tctr`.`TestingItem` = `td`.`TestingNo`))) where ((`tctd`.`Status` > 5) and (`td`.`TestingType` = 7) and (`te`.`IsDelete` <> 1) and (`tcd`.`IsDelete` <> 1));

-- ----------------------------
-- View structure for view_osmo_sheet
-- ----------------------------
DROP VIEW IF EXISTS `view_osmo_sheet`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `view_osmo_sheet` AS select `td`.`TestingDescription` AS `Test_Item`,`otd`.`OSMO` AS `Value`,`td`.`Unit` AS `Unit`,substring_index(`otd`.`SampleID`,'-',1) AS `Mark`,substring_index(`otd`.`SampleID`,'-',-(1)) AS `CultureIdentity`,`te`.`EquipmentNo` AS `Instrument_Code`,`otd`.`StartTime` AS `SampleTime`,`otd`.`EndTime` AS `TestingTime` from ((((`cdp_testing_osmotaskdtl` `otd` join `cdp_testing_osmotask` `ot` on((`otd`.`TestingOSMOTaskID` = `ot`.`TestingOSMOTaskID`))) join `cdp_testing_osmodevice` `od` on((`ot`.`OSMODeviceID` = `od`.`OSMODeviceID`))) join `cdp_testing_equipment` `te` on((`od`.`TestingEquipmentID` = `te`.`TestingEquipmentID`))) left join `cdp_testingdef` `td` on(('OSMO' = `td`.`TestingNo`))) where ((`otd`.`Status` >= 5) and substring_index(`otd`.`SampleID`,'-',-(1)) in (select `c`.`CultureCode` from ((`cdp_preculture` `c` join `cdp_prebatch` `pb` on((`c`.`PreBatchId` = `pb`.`PreBatchId`))) join `cdp_project` `p` on((`pb`.`ProjectId` = `p`.`ProjectId`))) where ((`c`.`IsDelete` <> 1) and (`pb`.`IsDelete` <> 1) and (`p`.`IsDelete` <> 1))) and (`td`.`TestingType` = 5) and (`otd`.`IsDelete` <> 1) and (`ot`.`IsDelete` <> 1) and (`od`.`IsDelete` <> 1) and (`te`.`IsDelete` <> 1) and (`td`.`IsDelete` <> 1));

-- ----------------------------
-- Procedure structure for xsp_Gen_DB_Version
-- ----------------------------
DROP PROCEDURE IF EXISTS `xsp_Gen_DB_Version`;
delimiter ;;
CREATE PROCEDURE `xsp_Gen_DB_Version`(IN iBackFileName VARCHAR(64))
BEGIN
	IF (SELECT count(1) FROM CDP_DB_Versions)=0 THEN 
		INSERT INTO CDP_DB_Versions(BackFileName,BackTime,MajorNumber,MinorNumber,RevisionNumber,BuildNumber,FullVersion) VALUES(iBackFileName,NOW(),1,0,0,1,'1.0.0.1');
	ELSE 
		INSERT INTO CDP_DB_Versions(BackFileName,BackTime,MajorNumber,MinorNumber,RevisionNumber,BuildNumber,FullVersion)
		SELECT iBackFileName,NOW(),MajorNumber,MinorNumber,RevisionNumber+1,1,CONCAT(MajorNumber,'.',MinorNumber,'.',RevisionNumber+1,'.',1) FROM CDP_DB_Versions ORDER BY BackTime desc LIMIT 0,1;
	END IF;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
