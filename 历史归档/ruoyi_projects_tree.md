# RuoYi-Cloud 与 RuoYi-Cloud-Vue3 目录结构

> 生成时间：自动生成

> 说明：已排除 `node_modules / target / .git / dist / build` 等依赖与构建目录，仅展示源码与配置结构。


## RuoYi-Cloud

```text
RuoYi-Cloud/
├── ruoyi-api/
│   ├── ruoyi-api-system/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── system/
│   │   │       │               └── api/
│   │   │       │                   ├── domain/
│   │   │       │                   │   ├── SysDept.java
│   │   │       │                   │   ├── SysDictData.java
│   │   │       │                   │   ├── SysDictType.java
│   │   │       │                   │   ├── SysFile.java
│   │   │       │                   │   ├── SysLogininfor.java
│   │   │       │                   │   ├── SysOperLog.java
│   │   │       │                   │   ├── SysRole.java
│   │   │       │                   │   └── SysUser.java
│   │   │       │                   ├── factory/
│   │   │       │                   │   ├── RemoteFileFallbackFactory.java
│   │   │       │                   │   ├── RemoteLogFallbackFactory.java
│   │   │       │                   │   └── RemoteUserFallbackFactory.java
│   │   │       │                   ├── model/
│   │   │       │                   │   └── LoginUser.java
│   │   │       │                   ├── RemoteFileService.java
│   │   │       │                   ├── RemoteLogService.java
│   │   │       │                   └── RemoteUserService.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   └── pom.xml
├── ruoyi-auth/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/
│   │       │       └── ruoyi/
│   │       │           └── auth/
│   │       │               ├── controller/
│   │       │               │   └── TokenController.java
│   │       │               ├── form/
│   │       │               │   ├── LoginBody.java
│   │       │               │   ├── RegisterBody.java
│   │       │               │   └── UnLockBody.java
│   │       │               ├── service/
│   │       │               │   ├── SysLoginService.java
│   │       │               │   ├── SysPasswordService.java
│   │       │               │   └── SysRecordLogService.java
│   │       │               └── RuoYiAuthApplication.java
│   │       └── resources/
│   │           ├── banner.txt
│   │           ├── bootstrap.yml
│   │           └── logback.xml
│   └── pom.xml
├── ruoyi-common/
│   ├── ruoyi-common-core/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── common/
│   │   │       │               └── core/
│   │   │       │                   ├── annotation/
│   │   │       │                   │   ├── Excel.java
│   │   │       │                   │   └── Excels.java
│   │   │       │                   ├── constant/
│   │   │       │                   │   ├── CacheConstants.java
│   │   │       │                   │   ├── Constants.java
│   │   │       │                   │   ├── GenConstants.java
│   │   │       │                   │   ├── HttpStatus.java
│   │   │       │                   │   ├── ScheduleConstants.java
│   │   │       │                   │   ├── SecurityConstants.java
│   │   │       │                   │   ├── ServiceNameConstants.java
│   │   │       │                   │   ├── TokenConstants.java
│   │   │       │                   │   └── UserConstants.java
│   │   │       │                   ├── context/
│   │   │       │                   │   └── SecurityContextHolder.java
│   │   │       │                   ├── domain/
│   │   │       │                   │   └── R.java
│   │   │       │                   ├── enums/
│   │   │       │                   │   └── UserStatus.java
│   │   │       │                   ├── exception/
│   │   │       │                   │   ├── auth/
│   │   │       │                   │   │   ├── NotLoginException.java
│   │   │       │                   │   │   ├── NotPermissionException.java
│   │   │       │                   │   │   └── NotRoleException.java
│   │   │       │                   │   ├── base/
│   │   │       │                   │   │   └── BaseException.java
│   │   │       │                   │   ├── file/
│   │   │       │                   │   │   ├── FileException.java
│   │   │       │                   │   │   ├── FileNameLengthLimitExceededException.java
│   │   │       │                   │   │   ├── FileSizeLimitExceededException.java
│   │   │       │                   │   │   ├── FileUploadException.java
│   │   │       │                   │   │   └── InvalidExtensionException.java
│   │   │       │                   │   ├── job/
│   │   │       │                   │   │   └── TaskException.java
│   │   │       │                   │   ├── user/
│   │   │       │                   │   │   ├── CaptchaExpireException.java
│   │   │       │                   │   │   ├── UserException.java
│   │   │       │                   │   │   └── UserPasswordNotMatchException.java
│   │   │       │                   │   ├── CaptchaException.java
│   │   │       │                   │   ├── CheckedException.java
│   │   │       │                   │   ├── DemoModeException.java
│   │   │       │                   │   ├── GlobalException.java
│   │   │       │                   │   ├── InnerAuthException.java
│   │   │       │                   │   ├── PreAuthorizeException.java
│   │   │       │                   │   ├── ServiceException.java
│   │   │       │                   │   └── UtilException.java
│   │   │       │                   ├── text/
│   │   │       │                   │   ├── CharsetKit.java
│   │   │       │                   │   ├── Convert.java
│   │   │       │                   │   └── StrFormatter.java
│   │   │       │                   ├── utils/
│   │   │       │                   │   ├── bean/
│   │   │       │                   │   │   ├── BeanUtils.java
│   │   │       │                   │   │   └── BeanValidators.java
│   │   │       │                   │   ├── file/
│   │   │       │                   │   │   ├── FileTypeUtils.java
│   │   │       │                   │   │   ├── FileUtils.java
│   │   │       │                   │   │   ├── ImageUtils.java
│   │   │       │                   │   │   └── MimeTypeUtils.java
│   │   │       │                   │   ├── html/
│   │   │       │                   │   │   ├── EscapeUtil.java
│   │   │       │                   │   │   └── HTMLFilter.java
│   │   │       │                   │   ├── ip/
│   │   │       │                   │   │   └── IpUtils.java
│   │   │       │                   │   ├── poi/
│   │   │       │                   │   │   ├── ExcelHandlerAdapter.java
│   │   │       │                   │   │   ├── ExcelSheet.java
│   │   │       │                   │   │   └── ExcelUtil.java
│   │   │       │                   │   ├── reflect/
│   │   │       │                   │   │   └── ReflectUtils.java
│   │   │       │                   │   ├── sign/
│   │   │       │                   │   │   └── Base64.java
│   │   │       │                   │   ├── sql/
│   │   │       │                   │   │   └── SqlUtil.java
│   │   │       │                   │   ├── uuid/
│   │   │       │                   │   │   ├── IdUtils.java
│   │   │       │                   │   │   ├── Seq.java
│   │   │       │                   │   │   └── UUID.java
│   │   │       │                   │   ├── DateUtils.java
│   │   │       │                   │   ├── ExceptionUtil.java
│   │   │       │                   │   ├── JwtUtils.java
│   │   │       │                   │   ├── PageUtils.java
│   │   │       │                   │   ├── ServletUtils.java
│   │   │       │                   │   ├── SpringUtils.java
│   │   │       │                   │   └── StringUtils.java
│   │   │       │                   ├── web/
│   │   │       │                   │   ├── controller/
│   │   │       │                   │   │   └── BaseController.java
│   │   │       │                   │   ├── domain/
│   │   │       │                   │   │   ├── AjaxResult.java
│   │   │       │                   │   │   ├── BaseEntity.java
│   │   │       │                   │   │   └── TreeEntity.java
│   │   │       │                   │   └── page/
│   │   │       │                   │       ├── PageDomain.java
│   │   │       │                   │       ├── TableDataInfo.java
│   │   │       │                   │       └── TableSupport.java
│   │   │       │                   └── xss/
│   │   │       │                       ├── Xss.java
│   │   │       │                       └── XssValidator.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   ├── ruoyi-common-datascope/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── common/
│   │   │       │               └── datascope/
│   │   │       │                   ├── annotation/
│   │   │       │                   │   └── DataScope.java
│   │   │       │                   └── aspect/
│   │   │       │                       └── DataScopeAspect.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   ├── ruoyi-common-datasource/
│   │   ├── src/
│   │   │   └── main/
│   │   │       └── java/
│   │   │           └── com/
│   │   │               └── ruoyi/
│   │   │                   └── common/
│   │   │                       └── datasource/
│   │   │                           └── annotation/
│   │   │                               ├── Master.java
│   │   │                               └── Slave.java
│   │   └── pom.xml
│   ├── ruoyi-common-log/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── common/
│   │   │       │               └── log/
│   │   │       │                   ├── annotation/
│   │   │       │                   │   └── Log.java
│   │   │       │                   ├── aspect/
│   │   │       │                   │   └── LogAspect.java
│   │   │       │                   ├── enums/
│   │   │       │                   │   ├── BusinessStatus.java
│   │   │       │                   │   ├── BusinessType.java
│   │   │       │                   │   └── OperatorType.java
│   │   │       │                   ├── filter/
│   │   │       │                   │   └── PropertyPreExcludeFilter.java
│   │   │       │                   └── service/
│   │   │       │                       └── AsyncLogService.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   ├── ruoyi-common-redis/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── common/
│   │   │       │               └── redis/
│   │   │       │                   ├── configure/
│   │   │       │                   │   ├── FastJson2JsonRedisSerializer.java
│   │   │       │                   │   └── RedisConfig.java
│   │   │       │                   └── service/
│   │   │       │                       └── RedisService.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   ├── ruoyi-common-seata/
│   │   └── pom.xml
│   ├── ruoyi-common-security/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── common/
│   │   │       │               └── security/
│   │   │       │                   ├── annotation/
│   │   │       │                   │   ├── EnableCustomConfig.java
│   │   │       │                   │   ├── EnableRyFeignClients.java
│   │   │       │                   │   ├── InnerAuth.java
│   │   │       │                   │   ├── Logical.java
│   │   │       │                   │   ├── RequiresLogin.java
│   │   │       │                   │   ├── RequiresPermissions.java
│   │   │       │                   │   └── RequiresRoles.java
│   │   │       │                   ├── aspect/
│   │   │       │                   │   ├── InnerAuthAspect.java
│   │   │       │                   │   └── PreAuthorizeAspect.java
│   │   │       │                   ├── auth/
│   │   │       │                   │   ├── AuthLogic.java
│   │   │       │                   │   └── AuthUtil.java
│   │   │       │                   ├── config/
│   │   │       │                   │   ├── ApplicationConfig.java
│   │   │       │                   │   └── WebMvcConfig.java
│   │   │       │                   ├── feign/
│   │   │       │                   │   ├── FeignAutoConfiguration.java
│   │   │       │                   │   └── FeignRequestInterceptor.java
│   │   │       │                   ├── handler/
│   │   │       │                   │   └── GlobalExceptionHandler.java
│   │   │       │                   ├── interceptor/
│   │   │       │                   │   └── HeaderInterceptor.java
│   │   │       │                   ├── service/
│   │   │       │                   │   └── TokenService.java
│   │   │       │                   └── utils/
│   │   │       │                       ├── DictUtils.java
│   │   │       │                       └── SecurityUtils.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   ├── ruoyi-common-sensitive/
│   │   ├── src/
│   │   │   └── main/
│   │   │       └── java/
│   │   │           └── com/
│   │   │               └── ruoyi/
│   │   │                   └── common/
│   │   │                       └── sensitive/
│   │   │                           ├── annotation/
│   │   │                           │   └── Sensitive.java
│   │   │                           ├── config/
│   │   │                           │   └── SensitiveJsonSerializer.java
│   │   │                           ├── enums/
│   │   │                           │   └── DesensitizedType.java
│   │   │                           └── utils/
│   │   │                               └── DesensitizedUtil.java
│   │   └── pom.xml
│   ├── ruoyi-common-swagger/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── common/
│   │   │       │               └── swagger/
│   │   │       │                   └── config/
│   │   │       │                       ├── properties/
│   │   │       │                       │   └── SpringDocProperties.java
│   │   │       │                       └── SpringDocAutoConfiguration.java
│   │   │       └── resources/
│   │   │           └── META-INF/
│   │   │               └── spring/
│   │   │                   └── org.springframework.boot.autoconfigure.AutoConfiguration.imports
│   │   └── pom.xml
│   └── pom.xml
├── ruoyi-gateway/
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── com/
│   │       │       └── ruoyi/
│   │       │           └── gateway/
│   │       │               ├── config/
│   │       │               │   ├── properties/
│   │       │               │   │   ├── CaptchaProperties.java
│   │       │               │   │   ├── IgnoreWhiteProperties.java
│   │       │               │   │   └── XssProperties.java
│   │       │               │   ├── CaptchaConfig.java
│   │       │               │   ├── GatewayConfig.java
│   │       │               │   ├── KaptchaTextCreator.java
│   │       │               │   ├── RouterFunctionConfiguration.java
│   │       │               │   └── SpringDocConfig.java
│   │       │               ├── filter/
│   │       │               │   ├── AuthFilter.java
│   │       │               │   ├── BlackListUrlFilter.java
│   │       │               │   ├── ValidateCodeFilter.java
│   │       │               │   └── XssFilter.java
│   │       │               ├── handler/
│   │       │               │   ├── GatewayExceptionHandler.java
│   │       │               │   ├── SentinelFallbackHandler.java
│   │       │               │   └── ValidateCodeHandler.java
│   │       │               ├── service/
│   │       │               │   ├── impl/
│   │       │               │   │   └── ValidateCodeServiceImpl.java
│   │       │               │   └── ValidateCodeService.java
│   │       │               └── RuoYiGatewayApplication.java
│   │       └── resources/
│   │           ├── banner.txt
│   │           ├── bootstrap.yml
│   │           └── logback.xml
│   └── pom.xml
├── ruoyi-modules/
│   ├── ruoyi-file/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── file/
│   │   │       │               ├── config/
│   │   │       │               │   ├── FilterConfig.java
│   │   │       │               │   ├── MinioConfig.java
│   │   │       │               │   └── ResourcesConfig.java
│   │   │       │               ├── controller/
│   │   │       │               │   └── SysFileController.java
│   │   │       │               ├── filter/
│   │   │       │               │   └── RefererFilter.java
│   │   │       │               ├── service/
│   │   │       │               │   ├── ISysFileService.java
│   │   │       │               │   ├── LocalSysFileServiceImpl.java
│   │   │       │               │   └── MinioSysFileServiceImpl.java
│   │   │       │               ├── utils/
│   │   │       │               │   └── FileUploadUtils.java
│   │   │       │               └── RuoYiFileApplication.java
│   │   │       └── resources/
│   │   │           ├── banner.txt
│   │   │           ├── bootstrap.yml
│   │   │           └── logback.xml
│   │   └── pom.xml
│   ├── ruoyi-gen/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── gen/
│   │   │       │               ├── config/
│   │   │       │               │   └── GenConfig.java
│   │   │       │               ├── controller/
│   │   │       │               │   └── GenController.java
│   │   │       │               ├── domain/
│   │   │       │               │   ├── GenTable.java
│   │   │       │               │   └── GenTableColumn.java
│   │   │       │               ├── mapper/
│   │   │       │               │   ├── GenTableColumnMapper.java
│   │   │       │               │   └── GenTableMapper.java
│   │   │       │               ├── service/
│   │   │       │               │   ├── GenTableColumnServiceImpl.java
│   │   │       │               │   ├── GenTableServiceImpl.java
│   │   │       │               │   ├── IGenTableColumnService.java
│   │   │       │               │   └── IGenTableService.java
│   │   │       │               ├── util/
│   │   │       │               │   ├── GenUtils.java
│   │   │       │               │   ├── VelocityInitializer.java
│   │   │       │               │   └── VelocityUtils.java
│   │   │       │               └── RuoYiGenApplication.java
│   │   │       └── resources/
│   │   │           ├── mapper/
│   │   │           │   └── generator/
│   │   │           │       ├── GenTableColumnMapper.xml
│   │   │           │       └── GenTableMapper.xml
│   │   │           ├── vm/
│   │   │           │   ├── java/
│   │   │           │   │   ├── controller.java.vm
│   │   │           │   │   ├── domain.java.vm
│   │   │           │   │   ├── mapper.java.vm
│   │   │           │   │   ├── service.java.vm
│   │   │           │   │   ├── serviceImpl.java.vm
│   │   │           │   │   └── sub-domain.java.vm
│   │   │           │   ├── js/
│   │   │           │   │   └── api.js.vm
│   │   │           │   ├── sql/
│   │   │           │   │   └── sql.vm
│   │   │           │   ├── ts/
│   │   │           │   │   ├── api.ts.vm
│   │   │           │   │   ├── index.ts.vm
│   │   │           │   │   └── type.ts.vm
│   │   │           │   ├── vue/
│   │   │           │   │   ├── v3/
│   │   │           │   │   │   ├── index-tree.vue.vm
│   │   │           │   │   │   ├── index.vue.vm
│   │   │           │   │   │   └── view.vue.vm
│   │   │           │   │   ├── v3ts/
│   │   │           │   │   │   ├── index-tree.vue.vm
│   │   │           │   │   │   ├── index.vue.vm
│   │   │           │   │   │   └── view.vue.vm
│   │   │           │   │   ├── index-tree.vue.vm
│   │   │           │   │   ├── index.vue.vm
│   │   │           │   │   └── view.vue.vm
│   │   │           │   └── xml/
│   │   │           │       └── mapper.xml.vm
│   │   │           ├── banner.txt
│   │   │           ├── bootstrap.yml
│   │   │           └── logback.xml
│   │   └── pom.xml
│   ├── ruoyi-job/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── job/
│   │   │       │               ├── config/
│   │   │       │               │   └── ScheduleConfig.java
│   │   │       │               ├── controller/
│   │   │       │               │   ├── SysJobController.java
│   │   │       │               │   └── SysJobLogController.java
│   │   │       │               ├── domain/
│   │   │       │               │   ├── SysJob.java
│   │   │       │               │   └── SysJobLog.java
│   │   │       │               ├── mapper/
│   │   │       │               │   ├── SysJobLogMapper.java
│   │   │       │               │   └── SysJobMapper.java
│   │   │       │               ├── service/
│   │   │       │               │   ├── ISysJobLogService.java
│   │   │       │               │   ├── ISysJobService.java
│   │   │       │               │   ├── SysJobLogServiceImpl.java
│   │   │       │               │   └── SysJobServiceImpl.java
│   │   │       │               ├── task/
│   │   │       │               │   └── RyTask.java
│   │   │       │               ├── util/
│   │   │       │               │   ├── AbstractQuartzJob.java
│   │   │       │               │   ├── CronUtils.java
│   │   │       │               │   ├── JobInvokeUtil.java
│   │   │       │               │   ├── QuartzDisallowConcurrentExecution.java
│   │   │       │               │   ├── QuartzJobExecution.java
│   │   │       │               │   └── ScheduleUtils.java
│   │   │       │               └── RuoYiJobApplication.java
│   │   │       └── resources/
│   │   │           ├── mapper/
│   │   │           │   └── job/
│   │   │           │       ├── SysJobLogMapper.xml
│   │   │           │       └── SysJobMapper.xml
│   │   │           ├── banner.txt
│   │   │           ├── bootstrap.yml
│   │   │           └── logback.xml
│   │   └── pom.xml
│   ├── ruoyi-system/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── system/
│   │   │       │               ├── controller/
│   │   │       │               │   ├── SysConfigController.java
│   │   │       │               │   ├── SysDeptController.java
│   │   │       │               │   ├── SysDictDataController.java
│   │   │       │               │   ├── SysDictTypeController.java
│   │   │       │               │   ├── SysLogininforController.java
│   │   │       │               │   ├── SysMenuController.java
│   │   │       │               │   ├── SysNoticeController.java
│   │   │       │               │   ├── SysOperlogController.java
│   │   │       │               │   ├── SysPostController.java
│   │   │       │               │   ├── SysProfileController.java
│   │   │       │               │   ├── SysRoleController.java
│   │   │       │               │   ├── SysUserController.java
│   │   │       │               │   └── SysUserOnlineController.java
│   │   │       │               ├── domain/
│   │   │       │               │   ├── vo/
│   │   │       │               │   │   ├── MetaVo.java
│   │   │       │               │   │   ├── RouterVo.java
│   │   │       │               │   │   └── TreeSelect.java
│   │   │       │               │   ├── SysConfig.java
│   │   │       │               │   ├── SysMenu.java
│   │   │       │               │   ├── SysNotice.java
│   │   │       │               │   ├── SysNoticeRead.java
│   │   │       │               │   ├── SysPost.java
│   │   │       │               │   ├── SysRoleDept.java
│   │   │       │               │   ├── SysRoleMenu.java
│   │   │       │               │   ├── SysUserOnline.java
│   │   │       │               │   ├── SysUserPost.java
│   │   │       │               │   └── SysUserRole.java
│   │   │       │               ├── mapper/
│   │   │       │               │   ├── SysConfigMapper.java
│   │   │       │               │   ├── SysDeptMapper.java
│   │   │       │               │   ├── SysDictDataMapper.java
│   │   │       │               │   ├── SysDictTypeMapper.java
│   │   │       │               │   ├── SysLogininforMapper.java
│   │   │       │               │   ├── SysMenuMapper.java
│   │   │       │               │   ├── SysNoticeMapper.java
│   │   │       │               │   ├── SysNoticeReadMapper.java
│   │   │       │               │   ├── SysOperLogMapper.java
│   │   │       │               │   ├── SysPostMapper.java
│   │   │       │               │   ├── SysRoleDeptMapper.java
│   │   │       │               │   ├── SysRoleMapper.java
│   │   │       │               │   ├── SysRoleMenuMapper.java
│   │   │       │               │   ├── SysUserMapper.java
│   │   │       │               │   ├── SysUserPostMapper.java
│   │   │       │               │   └── SysUserRoleMapper.java
│   │   │       │               ├── service/
│   │   │       │               │   ├── impl/
│   │   │       │               │   │   ├── SysConfigServiceImpl.java
│   │   │       │               │   │   ├── SysDeptServiceImpl.java
│   │   │       │               │   │   ├── SysDictDataServiceImpl.java
│   │   │       │               │   │   ├── SysDictTypeServiceImpl.java
│   │   │       │               │   │   ├── SysLogininforServiceImpl.java
│   │   │       │               │   │   ├── SysMenuServiceImpl.java
│   │   │       │               │   │   ├── SysNoticeReadServiceImpl.java
│   │   │       │               │   │   ├── SysNoticeServiceImpl.java
│   │   │       │               │   │   ├── SysOperLogServiceImpl.java
│   │   │       │               │   │   ├── SysPermissionServiceImpl.java
│   │   │       │               │   │   ├── SysPostServiceImpl.java
│   │   │       │               │   │   ├── SysRoleServiceImpl.java
│   │   │       │               │   │   ├── SysUserOnlineServiceImpl.java
│   │   │       │               │   │   └── SysUserServiceImpl.java
│   │   │       │               │   ├── ISysConfigService.java
│   │   │       │               │   ├── ISysDeptService.java
│   │   │       │               │   ├── ISysDictDataService.java
│   │   │       │               │   ├── ISysDictTypeService.java
│   │   │       │               │   ├── ISysLogininforService.java
│   │   │       │               │   ├── ISysMenuService.java
│   │   │       │               │   ├── ISysNoticeReadService.java
│   │   │       │               │   ├── ISysNoticeService.java
│   │   │       │               │   ├── ISysOperLogService.java
│   │   │       │               │   ├── ISysPermissionService.java
│   │   │       │               │   ├── ISysPostService.java
│   │   │       │               │   ├── ISysRoleService.java
│   │   │       │               │   ├── ISysUserOnlineService.java
│   │   │       │               │   └── ISysUserService.java
│   │   │       │               └── RuoYiSystemApplication.java
│   │   │       └── resources/
│   │   │           ├── mapper/
│   │   │           │   └── system/
│   │   │           │       ├── SysConfigMapper.xml
│   │   │           │       ├── SysDeptMapper.xml
│   │   │           │       ├── SysDictDataMapper.xml
│   │   │           │       ├── SysDictTypeMapper.xml
│   │   │           │       ├── SysLogininforMapper.xml
│   │   │           │       ├── SysMenuMapper.xml
│   │   │           │       ├── SysNoticeMapper.xml
│   │   │           │       ├── SysNoticeReadMapper.xml
│   │   │           │       ├── SysOperLogMapper.xml
│   │   │           │       ├── SysPostMapper.xml
│   │   │           │       ├── SysRoleDeptMapper.xml
│   │   │           │       ├── SysRoleMapper.xml
│   │   │           │       ├── SysRoleMenuMapper.xml
│   │   │           │       ├── SysUserMapper.xml
│   │   │           │       ├── SysUserPostMapper.xml
│   │   │           │       └── SysUserRoleMapper.xml
│   │   │           ├── banner.txt
│   │   │           ├── bootstrap.yml
│   │   │           └── logback.xml
│   │   └── pom.xml
│   └── pom.xml
├── ruoyi-ui/
│   ├── public/
│   │   ├── html/
│   │   │   └── ie.html
│   │   ├── styles/
│   │   │   └── theme-chalk/
│   │   │       └── index.css
│   │   ├── favicon.ico
│   │   ├── index.html
│   │   └── robots.txt
│   ├── src/
│   │   ├── api/
│   │   │   ├── monitor/
│   │   │   │   ├── job.js
│   │   │   │   ├── jobLog.js
│   │   │   │   └── online.js
│   │   │   ├── system/
│   │   │   │   ├── dict/
│   │   │   │   │   ├── data.js
│   │   │   │   │   └── type.js
│   │   │   │   ├── config.js
│   │   │   │   ├── dept.js
│   │   │   │   ├── logininfor.js
│   │   │   │   ├── menu.js
│   │   │   │   ├── notice.js
│   │   │   │   ├── operlog.js
│   │   │   │   ├── post.js
│   │   │   │   ├── role.js
│   │   │   │   └── user.js
│   │   │   ├── tool/
│   │   │   │   └── gen.js
│   │   │   ├── login.js
│   │   │   └── menu.js
│   │   ├── assets/
│   │   │   ├── 401_images/
│   │   │   │   └── 401.gif
│   │   │   ├── 404_images/
│   │   │   │   ├── 404.png
│   │   │   │   └── 404_cloud.png
│   │   │   ├── icons/
│   │   │   │   ├── svg/
│   │   │   │   │   ├── 404.svg
│   │   │   │   │   ├── bell.svg
│   │   │   │   │   ├── bug.svg
│   │   │   │   │   ├── build.svg
│   │   │   │   │   ├── button.svg
│   │   │   │   │   ├── cascader.svg
│   │   │   │   │   ├── chart.svg
│   │   │   │   │   ├── checkbox.svg
│   │   │   │   │   ├── client.svg
│   │   │   │   │   ├── clipboard.svg
│   │   │   │   │   ├── code.svg
│   │   │   │   │   ├── color.svg
│   │   │   │   │   ├── component.svg
│   │   │   │   │   ├── dashboard.svg
│   │   │   │   │   ├── date-range.svg
│   │   │   │   │   ├── date.svg
│   │   │   │   │   ├── dict.svg
│   │   │   │   │   ├── documentation.svg
│   │   │   │   │   ├── download.svg
│   │   │   │   │   ├── drag.svg
│   │   │   │   │   ├── druid.svg
│   │   │   │   │   ├── edit.svg
│   │   │   │   │   ├── education.svg
│   │   │   │   │   ├── email.svg
│   │   │   │   │   ├── enter.svg
│   │   │   │   │   ├── example.svg
│   │   │   │   │   ├── excel.svg
│   │   │   │   │   ├── exit-fullscreen.svg
│   │   │   │   │   ├── eye-open.svg
│   │   │   │   │   ├── eye.svg
│   │   │   │   │   ├── form.svg
│   │   │   │   │   ├── fullscreen.svg
│   │   │   │   │   ├── github.svg
│   │   │   │   │   ├── guide.svg
│   │   │   │   │   ├── icon.svg
│   │   │   │   │   ├── input.svg
│   │   │   │   │   ├── international.svg
│   │   │   │   │   ├── job.svg
│   │   │   │   │   ├── language.svg
│   │   │   │   │   ├── link.svg
│   │   │   │   │   ├── list.svg
│   │   │   │   │   ├── lock.svg
│   │   │   │   │   ├── log.svg
│   │   │   │   │   ├── logininfor.svg
│   │   │   │   │   ├── message.svg
│   │   │   │   │   ├── money.svg
│   │   │   │   │   ├── monitor.svg
│   │   │   │   │   ├── more-up.svg
│   │   │   │   │   ├── nacos.svg
│   │   │   │   │   ├── nested.svg
│   │   │   │   │   ├── number.svg
│   │   │   │   │   ├── online.svg
│   │   │   │   │   ├── password.svg
│   │   │   │   │   ├── pdf.svg
│   │   │   │   │   ├── people.svg
│   │   │   │   │   ├── peoples.svg
│   │   │   │   │   ├── phone.svg
│   │   │   │   │   ├── post.svg
│   │   │   │   │   ├── qq.svg
│   │   │   │   │   ├── question.svg
│   │   │   │   │   ├── radio.svg
│   │   │   │   │   ├── rate.svg
│   │   │   │   │   ├── row.svg
│   │   │   │   │   ├── search.svg
│   │   │   │   │   ├── select.svg
│   │   │   │   │   ├── sentinel.svg
│   │   │   │   │   ├── server.svg
│   │   │   │   │   ├── shopping.svg
│   │   │   │   │   ├── size.svg
│   │   │   │   │   ├── skill.svg
│   │   │   │   │   ├── slider.svg
│   │   │   │   │   ├── star.svg
│   │   │   │   │   ├── swagger.svg
│   │   │   │   │   ├── switch.svg
│   │   │   │   │   ├── system.svg
│   │   │   │   │   ├── tab.svg
│   │   │   │   │   ├── table.svg
│   │   │   │   │   ├── textarea.svg
│   │   │   │   │   ├── theme.svg
│   │   │   │   │   ├── time-range.svg
│   │   │   │   │   ├── time.svg
│   │   │   │   │   ├── tool.svg
│   │   │   │   │   ├── tree-table.svg
│   │   │   │   │   ├── tree.svg
│   │   │   │   │   ├── upload.svg
│   │   │   │   │   ├── user.svg
│   │   │   │   │   ├── validCode.svg
│   │   │   │   │   ├── wechat.svg
│   │   │   │   │   └── zip.svg
│   │   │   │   ├── index.js
│   │   │   │   └── svgo.yml
│   │   │   ├── images/
│   │   │   │   ├── dark.svg
│   │   │   │   ├── light.svg
│   │   │   │   ├── login-background.jpg
│   │   │   │   ├── pay.png
│   │   │   │   └── profile.jpg
│   │   │   ├── logo/
│   │   │   │   └── logo.png
│   │   │   └── styles/
│   │   │       ├── btn.scss
│   │   │       ├── element-ui.scss
│   │   │       ├── element-variables.scss
│   │   │       ├── index.scss
│   │   │       ├── mixin.scss
│   │   │       ├── ruoyi.scss
│   │   │       ├── sidebar.scss
│   │   │       ├── transition.scss
│   │   │       └── variables.scss
│   │   ├── components/
│   │   │   ├── Breadcrumb/
│   │   │   │   └── index.vue
│   │   │   ├── Crontab/
│   │   │   │   ├── day.vue
│   │   │   │   ├── hour.vue
│   │   │   │   ├── index.vue
│   │   │   │   ├── min.vue
│   │   │   │   ├── month.vue
│   │   │   │   ├── result.vue
│   │   │   │   ├── second.vue
│   │   │   │   ├── week.vue
│   │   │   │   └── year.vue
│   │   │   ├── DictData/
│   │   │   │   └── index.js
│   │   │   ├── DictTag/
│   │   │   │   └── index.vue
│   │   │   ├── Editor/
│   │   │   │   └── index.vue
│   │   │   ├── ExcelImportDialog/
│   │   │   │   └── index.vue
│   │   │   ├── FileUpload/
│   │   │   │   └── index.vue
│   │   │   ├── Hamburger/
│   │   │   │   └── index.vue
│   │   │   ├── HeaderSearch/
│   │   │   │   └── index.vue
│   │   │   ├── IconSelect/
│   │   │   │   ├── index.vue
│   │   │   │   └── requireIcons.js
│   │   │   ├── ImagePreview/
│   │   │   │   └── index.vue
│   │   │   ├── ImageUpload/
│   │   │   │   └── index.vue
│   │   │   ├── Pagination/
│   │   │   │   └── index.vue
│   │   │   ├── PanThumb/
│   │   │   │   └── index.vue
│   │   │   ├── ParentView/
│   │   │   │   └── index.vue
│   │   │   ├── RightToolbar/
│   │   │   │   └── index.vue
│   │   │   ├── RuoYi/
│   │   │   │   ├── Doc/
│   │   │   │   │   └── index.vue
│   │   │   │   └── Git/
│   │   │   │       └── index.vue
│   │   │   ├── Screenfull/
│   │   │   │   └── index.vue
│   │   │   ├── SizeSelect/
│   │   │   │   └── index.vue
│   │   │   ├── SvgIcon/
│   │   │   │   └── index.vue
│   │   │   ├── ThemePicker/
│   │   │   │   └── index.vue
│   │   │   ├── TreePanel/
│   │   │   │   └── index.vue
│   │   │   └── iFrame/
│   │   │       └── index.vue
│   │   ├── directive/
│   │   │   ├── dialog/
│   │   │   │   ├── drag.js
│   │   │   │   ├── dragHeight.js
│   │   │   │   └── dragWidth.js
│   │   │   ├── module/
│   │   │   │   └── clipboard.js
│   │   │   ├── permission/
│   │   │   │   ├── hasPermi.js
│   │   │   │   └── hasRole.js
│   │   │   └── index.js
│   │   ├── layout/
│   │   │   ├── components/
│   │   │   │   ├── Copyright/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── HeaderNotice/
│   │   │   │   │   ├── DetailView.vue
│   │   │   │   │   └── index.vue
│   │   │   │   ├── IframeToggle/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── InnerLink/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── Settings/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── Sidebar/
│   │   │   │   │   ├── FixiOSBug.js
│   │   │   │   │   ├── Item.vue
│   │   │   │   │   ├── Link.vue
│   │   │   │   │   ├── Logo.vue
│   │   │   │   │   ├── SidebarItem.vue
│   │   │   │   │   └── index.vue
│   │   │   │   ├── TagsView/
│   │   │   │   │   ├── ScrollPane.vue
│   │   │   │   │   └── index.vue
│   │   │   │   ├── TopBar/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── TopNav/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── AppMain.vue
│   │   │   │   ├── Navbar.vue
│   │   │   │   └── index.js
│   │   │   ├── mixin/
│   │   │   │   └── ResizeHandler.js
│   │   │   └── index.vue
│   │   ├── plugins/
│   │   │   ├── auth.js
│   │   │   ├── cache.js
│   │   │   ├── download.js
│   │   │   ├── index.js
│   │   │   ├── modal.js
│   │   │   └── tab.js
│   │   ├── router/
│   │   │   └── index.js
│   │   ├── store/
│   │   │   ├── modules/
│   │   │   │   ├── app.js
│   │   │   │   ├── dict.js
│   │   │   │   ├── lock.js
│   │   │   │   ├── permission.js
│   │   │   │   ├── settings.js
│   │   │   │   ├── tagsView.js
│   │   │   │   └── user.js
│   │   │   ├── getters.js
│   │   │   └── index.js
│   │   ├── utils/
│   │   │   ├── dict/
│   │   │   │   ├── Dict.js
│   │   │   │   ├── DictConverter.js
│   │   │   │   ├── DictData.js
│   │   │   │   ├── DictMeta.js
│   │   │   │   ├── DictOptions.js
│   │   │   │   └── index.js
│   │   │   ├── generator/
│   │   │   │   ├── config.js
│   │   │   │   ├── css.js
│   │   │   │   ├── drawingDefault.js
│   │   │   │   ├── html.js
│   │   │   │   ├── icon.json
│   │   │   │   ├── js.js
│   │   │   │   └── render.js
│   │   │   ├── auth.js
│   │   │   ├── dynamicTitle.js
│   │   │   ├── errorCode.js
│   │   │   ├── index.js
│   │   │   ├── jsencrypt.js
│   │   │   ├── passwordRule.js
│   │   │   ├── permission.js
│   │   │   ├── request.js
│   │   │   ├── ruoyi.js
│   │   │   ├── scroll-to.js
│   │   │   └── validate.js
│   │   ├── views/
│   │   │   ├── dashboard/
│   │   │   │   ├── mixins/
│   │   │   │   │   └── resize.js
│   │   │   │   ├── BarChart.vue
│   │   │   │   ├── LineChart.vue
│   │   │   │   ├── PanelGroup.vue
│   │   │   │   ├── PieChart.vue
│   │   │   │   └── RaddarChart.vue
│   │   │   ├── error/
│   │   │   │   ├── 401.vue
│   │   │   │   └── 404.vue
│   │   │   ├── monitor/
│   │   │   │   ├── job/
│   │   │   │   │   ├── detail.vue
│   │   │   │   │   ├── index.vue
│   │   │   │   │   └── log.vue
│   │   │   │   └── online/
│   │   │   │       └── index.vue
│   │   │   ├── system/
│   │   │   │   ├── config/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── dept/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── dict/
│   │   │   │   │   ├── data.vue
│   │   │   │   │   ├── detail.vue
│   │   │   │   │   └── index.vue
│   │   │   │   ├── logininfor/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── menu/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── notice/
│   │   │   │   │   ├── ReadUsers.vue
│   │   │   │   │   └── index.vue
│   │   │   │   ├── operlog/
│   │   │   │   │   ├── detail.vue
│   │   │   │   │   └── index.vue
│   │   │   │   ├── post/
│   │   │   │   │   └── index.vue
│   │   │   │   ├── role/
│   │   │   │   │   ├── authUser.vue
│   │   │   │   │   ├── index.vue
│   │   │   │   │   └── selectUser.vue
│   │   │   │   └── user/
│   │   │   │       ├── profile/
│   │   │   │       │   ├── index.vue
│   │   │   │       │   ├── resetPwd.vue
│   │   │   │       │   ├── userAvatar.vue
│   │   │   │       │   └── userInfo.vue
│   │   │   │       ├── authRole.vue
│   │   │   │       ├── index.vue
│   │   │   │       └── view.vue
│   │   │   ├── tool/
│   │   │   │   └── gen/
│   │   │   │       ├── basicInfoForm.vue
│   │   │   │       ├── editTable.vue
│   │   │   │       ├── genInfoForm.vue
│   │   │   │       ├── importTable.vue
│   │   │   │       └── index.vue
│   │   │   ├── index.vue
│   │   │   ├── index_v1.vue
│   │   │   ├── lock.vue
│   │   │   ├── login.vue
│   │   │   ├── redirect.vue
│   │   │   └── register.vue
│   │   ├── App.vue
│   │   ├── main.js
│   │   ├── permission.js
│   │   └── settings.js
│   ├── .editorconfig
│   ├── .env.development
│   ├── .env.production
│   ├── .env.staging
│   ├── .gitignore
│   ├── README.md
│   ├── babel.config.js
│   ├── package.json
│   └── vue.config.js
├── ruoyi-visual/
│   ├── ruoyi-monitor/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── java/
│   │   │       │   └── com/
│   │   │       │       └── ruoyi/
│   │   │       │           └── modules/
│   │   │       │               └── monitor/
│   │   │       │                   ├── config/
│   │   │       │                   │   └── WebSecurityConfigurer.java
│   │   │       │                   └── RuoYiMonitorApplication.java
│   │   │       └── resources/
│   │   │           ├── banner.txt
│   │   │           ├── bootstrap.yml
│   │   │           └── logback.xml
│   │   └── pom.xml
│   └── pom.xml
├── sql/
│   ├── quartz.sql
│   ├── ry_20260417.sql
│   ├── ry_config_20260611.sql
│   └── ry_seata_20210128.sql
├── .gitignore
├── LICENSE
├── README.md
└── pom.xml
```


## RuoYi-Cloud-Vue3

```text
RuoYi-Cloud-Vue3/
├── .github/
│   └── FUNDING.yml
├── html/
│   └── ie.html
├── public/
│   └── favicon.ico
├── src/
│   ├── api/
│   │   ├── monitor/
│   │   │   ├── job.js
│   │   │   ├── jobLog.js
│   │   │   └── online.js
│   │   ├── system/
│   │   │   ├── dict/
│   │   │   │   ├── data.js
│   │   │   │   └── type.js
│   │   │   ├── config.js
│   │   │   ├── dept.js
│   │   │   ├── logininfor.js
│   │   │   ├── menu.js
│   │   │   ├── notice.js
│   │   │   ├── operlog.js
│   │   │   ├── post.js
│   │   │   ├── role.js
│   │   │   └── user.js
│   │   ├── tool/
│   │   │   └── gen.js
│   │   ├── login.js
│   │   └── menu.js
│   ├── assets/
│   │   ├── 401_images/
│   │   │   └── 401.gif
│   │   ├── 404_images/
│   │   │   ├── 404.png
│   │   │   └── 404_cloud.png
│   │   ├── icons/
│   │   │   └── svg/
│   │   │       ├── 404.svg
│   │   │       ├── bell.svg
│   │   │       ├── bug.svg
│   │   │       ├── build.svg
│   │   │       ├── button.svg
│   │   │       ├── cascader.svg
│   │   │       ├── chart.svg
│   │   │       ├── checkbox.svg
│   │   │       ├── client.svg
│   │   │       ├── clipboard.svg
│   │   │       ├── code.svg
│   │   │       ├── color.svg
│   │   │       ├── component.svg
│   │   │       ├── dashboard.svg
│   │   │       ├── date-range.svg
│   │   │       ├── date.svg
│   │   │       ├── dict.svg
│   │   │       ├── documentation.svg
│   │   │       ├── download.svg
│   │   │       ├── drag.svg
│   │   │       ├── druid.svg
│   │   │       ├── edit.svg
│   │   │       ├── education.svg
│   │   │       ├── email.svg
│   │   │       ├── enter.svg
│   │   │       ├── example.svg
│   │   │       ├── excel.svg
│   │   │       ├── exit-fullscreen.svg
│   │   │       ├── eye-open.svg
│   │   │       ├── eye.svg
│   │   │       ├── form.svg
│   │   │       ├── fullscreen.svg
│   │   │       ├── github.svg
│   │   │       ├── guide.svg
│   │   │       ├── icon.svg
│   │   │       ├── input.svg
│   │   │       ├── international.svg
│   │   │       ├── job.svg
│   │   │       ├── language.svg
│   │   │       ├── link.svg
│   │   │       ├── list.svg
│   │   │       ├── lock.svg
│   │   │       ├── log.svg
│   │   │       ├── logininfor.svg
│   │   │       ├── message.svg
│   │   │       ├── money.svg
│   │   │       ├── monitor.svg
│   │   │       ├── moon.svg
│   │   │       ├── more-up.svg
│   │   │       ├── nacos.svg
│   │   │       ├── nested.svg
│   │   │       ├── number.svg
│   │   │       ├── online.svg
│   │   │       ├── password.svg
│   │   │       ├── pdf.svg
│   │   │       ├── people.svg
│   │   │       ├── peoples.svg
│   │   │       ├── phone.svg
│   │   │       ├── post.svg
│   │   │       ├── qq.svg
│   │   │       ├── question.svg
│   │   │       ├── radio.svg
│   │   │       ├── rate.svg
│   │   │       ├── redis.svg
│   │   │       ├── row.svg
│   │   │       ├── search.svg
│   │   │       ├── select.svg
│   │   │       ├── sentinel.svg
│   │   │       ├── server.svg
│   │   │       ├── shopping.svg
│   │   │       ├── size.svg
│   │   │       ├── skill.svg
│   │   │       ├── slider.svg
│   │   │       ├── star.svg
│   │   │       ├── sunny.svg
│   │   │       ├── swagger.svg
│   │   │       ├── switch.svg
│   │   │       ├── system.svg
│   │   │       ├── tab.svg
│   │   │       ├── table.svg
│   │   │       ├── textarea.svg
│   │   │       ├── theme.svg
│   │   │       ├── time-range.svg
│   │   │       ├── time.svg
│   │   │       ├── tool.svg
│   │   │       ├── tree-table.svg
│   │   │       ├── tree.svg
│   │   │       ├── upload.svg
│   │   │       ├── user.svg
│   │   │       ├── validCode.svg
│   │   │       ├── wechat.svg
│   │   │       └── zip.svg
│   │   ├── images/
│   │   │   ├── dark.svg
│   │   │   ├── light.svg
│   │   │   ├── login-background.jpg
│   │   │   ├── pay.png
│   │   │   └── profile.jpg
│   │   ├── logo/
│   │   │   └── logo.png
│   │   └── styles/
│   │       ├── btn.scss
│   │       ├── element-ui.scss
│   │       ├── index.scss
│   │       ├── mixin.scss
│   │       ├── ruoyi.scss
│   │       ├── sidebar.scss
│   │       ├── transition.scss
│   │       └── variables.module.scss
│   ├── components/
│   │   ├── Breadcrumb/
│   │   │   └── index.vue
│   │   ├── Crontab/
│   │   │   ├── day.vue
│   │   │   ├── hour.vue
│   │   │   ├── index.vue
│   │   │   ├── min.vue
│   │   │   ├── month.vue
│   │   │   ├── result.vue
│   │   │   ├── second.vue
│   │   │   ├── week.vue
│   │   │   └── year.vue
│   │   ├── DictTag/
│   │   │   └── index.vue
│   │   ├── Editor/
│   │   │   └── index.vue
│   │   ├── ExcelImportDialog/
│   │   │   └── index.vue
│   │   ├── FileUpload/
│   │   │   └── index.vue
│   │   ├── Hamburger/
│   │   │   └── index.vue
│   │   ├── HeaderSearch/
│   │   │   └── index.vue
│   │   ├── IconSelect/
│   │   │   ├── index.vue
│   │   │   └── requireIcons.js
│   │   ├── ImagePreview/
│   │   │   └── index.vue
│   │   ├── ImageUpload/
│   │   │   └── index.vue
│   │   ├── Pagination/
│   │   │   └── index.vue
│   │   ├── ParentView/
│   │   │   └── index.vue
│   │   ├── RightToolbar/
│   │   │   └── index.vue
│   │   ├── RuoYi/
│   │   │   ├── Doc/
│   │   │   │   └── index.vue
│   │   │   └── Git/
│   │   │       └── index.vue
│   │   ├── Screenfull/
│   │   │   └── index.vue
│   │   ├── SizeSelect/
│   │   │   └── index.vue
│   │   ├── SvgIcon/
│   │   │   ├── index.vue
│   │   │   └── svgicon.js
│   │   ├── TreePanel/
│   │   │   └── index.vue
│   │   └── iFrame/
│   │       └── index.vue
│   ├── directive/
│   │   ├── common/
│   │   │   └── copyText.js
│   │   ├── permission/
│   │   │   ├── hasPermi.js
│   │   │   └── hasRole.js
│   │   └── index.js
│   ├── layout/
│   │   ├── components/
│   │   │   ├── Copyright/
│   │   │   │   └── index.vue
│   │   │   ├── HeaderNotice/
│   │   │   │   ├── DetailView.vue
│   │   │   │   └── index.vue
│   │   │   ├── IframeToggle/
│   │   │   │   └── index.vue
│   │   │   ├── InnerLink/
│   │   │   │   └── index.vue
│   │   │   ├── Settings/
│   │   │   │   └── index.vue
│   │   │   ├── Sidebar/
│   │   │   │   ├── Link.vue
│   │   │   │   ├── Logo.vue
│   │   │   │   ├── SidebarItem.vue
│   │   │   │   └── index.vue
│   │   │   ├── TagsView/
│   │   │   │   ├── ScrollPane.vue
│   │   │   │   └── index.vue
│   │   │   ├── TopBar/
│   │   │   │   └── index.vue
│   │   │   ├── TopNav/
│   │   │   │   └── index.vue
│   │   │   ├── AppMain.vue
│   │   │   ├── Navbar.vue
│   │   │   └── index.js
│   │   └── index.vue
│   ├── plugins/
│   │   ├── auth.js
│   │   ├── cache.js
│   │   ├── download.js
│   │   ├── index.js
│   │   ├── modal.js
│   │   └── tab.js
│   ├── router/
│   │   └── index.js
│   ├── store/
│   │   ├── modules/
│   │   │   ├── app.js
│   │   │   ├── dict.js
│   │   │   ├── lock.js
│   │   │   ├── permission.js
│   │   │   ├── settings.js
│   │   │   ├── tagsView.js
│   │   │   └── user.js
│   │   └── index.js
│   ├── utils/
│   │   ├── generator/
│   │   │   ├── config.js
│   │   │   ├── css.js
│   │   │   ├── drawingDefault.js
│   │   │   ├── html.js
│   │   │   ├── icon.json
│   │   │   ├── js.js
│   │   │   └── render.js
│   │   ├── auth.js
│   │   ├── dict.js
│   │   ├── dynamicTitle.js
│   │   ├── errorCode.js
│   │   ├── index.js
│   │   ├── jsencrypt.js
│   │   ├── passwordRule.js
│   │   ├── permission.js
│   │   ├── request.js
│   │   ├── ruoyi.js
│   │   ├── scroll-to.js
│   │   ├── theme.js
│   │   └── validate.js
│   ├── views/
│   │   ├── error/
│   │   │   ├── 401.vue
│   │   │   └── 404.vue
│   │   ├── monitor/
│   │   │   ├── job/
│   │   │   │   ├── detail.vue
│   │   │   │   ├── index.vue
│   │   │   │   └── log.vue
│   │   │   └── online/
│   │   │       └── index.vue
│   │   ├── redirect/
│   │   │   └── index.vue
│   │   ├── system/
│   │   │   ├── config/
│   │   │   │   └── index.vue
│   │   │   ├── dept/
│   │   │   │   └── index.vue
│   │   │   ├── dict/
│   │   │   │   ├── data.vue
│   │   │   │   ├── detail.vue
│   │   │   │   └── index.vue
│   │   │   ├── logininfor/
│   │   │   │   └── index.vue
│   │   │   ├── menu/
│   │   │   │   └── index.vue
│   │   │   ├── notice/
│   │   │   │   ├── ReadUsers.vue
│   │   │   │   └── index.vue
│   │   │   ├── operlog/
│   │   │   │   ├── detail.vue
│   │   │   │   └── index.vue
│   │   │   ├── post/
│   │   │   │   └── index.vue
│   │   │   ├── role/
│   │   │   │   ├── authUser.vue
│   │   │   │   ├── index.vue
│   │   │   │   └── selectUser.vue
│   │   │   └── user/
│   │   │       ├── profile/
│   │   │       │   ├── index.vue
│   │   │       │   ├── resetPwd.vue
│   │   │       │   ├── userAvatar.vue
│   │   │       │   └── userInfo.vue
│   │   │       ├── authRole.vue
│   │   │       ├── index.vue
│   │   │       └── view.vue
│   │   ├── tool/
│   │   │   └── gen/
│   │   │       ├── basicInfoForm.vue
│   │   │       ├── editTable.vue
│   │   │       ├── genInfoForm.vue
│   │   │       ├── importTable.vue
│   │   │       └── index.vue
│   │   ├── index.vue
│   │   ├── lock.vue
│   │   ├── login.vue
│   │   └── register.vue
│   ├── App.vue
│   ├── main.js
│   ├── permission.js
│   └── settings.js
├── vite/
│   └── plugins/
│       ├── auto-import.js
│       ├── compression.js
│       ├── index.js
│       ├── setup-extend.js
│       └── svg-icon.js
├── .env.development
├── .env.production
├── .env.staging
├── .gitignore
├── LICENSE
├── README.md
├── index.html
├── package.json
└── vite.config.js
```
