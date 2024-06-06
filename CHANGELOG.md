# Changelog

All notable changes to this project will be documented in this file.

## [2.4.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.3.1...v2.4.0) (2024-06-06)


### Features

* Added otel azure monitor support ([#66](https://github.com/wandb/terraform-azurerm-wandb/issues/66)) ([7eaa8bf](https://github.com/wandb/terraform-azurerm-wandb/commit/7eaa8bf67a46466bf0f7fdbbcd6d03e7a3b73eb2))

### [2.3.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.3.0...v2.3.1) (2024-06-06)


### Bug Fixes

* Set the Azure sku_tier to standard for AKS clusters ([#69](https://github.com/wandb/terraform-azurerm-wandb/issues/69)) ([36963a5](https://github.com/wandb/terraform-azurerm-wandb/commit/36963a587709cd514600acd1f294629bfc3f7e1c))

## [2.3.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.2.0...v2.3.0) (2024-05-14)


### Features

* Team-level byob ([#63](https://github.com/wandb/terraform-azurerm-wandb/issues/63)) ([45015da](https://github.com/wandb/terraform-azurerm-wandb/commit/45015dafba7c1586e0b2742a7659217c846445a0))

## [2.2.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.8...v2.2.0) (2024-05-10)


### Features

* Allowlist Ips in Azure  ([#51](https://github.com/wandb/terraform-azurerm-wandb/issues/51)) ([18259c0](https://github.com/wandb/terraform-azurerm-wandb/commit/18259c060d73fcf1dbb32248f2e7045617379d43))

### [2.1.8](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.7...v2.1.8) (2024-04-30)


### Bug Fixes

* Bump operator chart version ([#54](https://github.com/wandb/terraform-azurerm-wandb/issues/54)) ([37f87fd](https://github.com/wandb/terraform-azurerm-wandb/commit/37f87fdc4162a50c94cbed08b9f12ab967f86364))

### [2.1.7](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.6...v2.1.7) (2024-03-26)


### Bug Fixes

* increase max pods to 100 ([#56](https://github.com/wandb/terraform-azurerm-wandb/issues/56)) ([0f6ca50](https://github.com/wandb/terraform-azurerm-wandb/commit/0f6ca50b3c2ee740c3636e1d16433222f617f74a))

### [2.1.6](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.5...v2.1.6) (2024-03-22)


### Bug Fixes

* **dev:** Add passthrough for env vars ([#55](https://github.com/wandb/terraform-azurerm-wandb/issues/55)) ([d18f6d0](https://github.com/wandb/terraform-azurerm-wandb/commit/d18f6d051ce4dd91ebec67ae3e217f3109df7b87))

### [2.1.5](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.4...v2.1.5) (2024-02-06)


### Bug Fixes

* Revert errant commits ([#47](https://github.com/wandb/terraform-azurerm-wandb/issues/47)) ([10c5ca9](https://github.com/wandb/terraform-azurerm-wandb/commit/10c5ca970c4b59d802b0ea14c6966bfd71e1e297))

### [2.1.4](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.3...v2.1.4) (2024-02-06)


### Bug Fixes

* Fix deletion protection for Azure storage ([1bdbdf6](https://github.com/wandb/terraform-azurerm-wandb/commit/1bdbdf64706b843fb0f6d2d7e718df0a1c451e36))

### [2.1.3](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.2...v2.1.3) (2024-02-06)


### Bug Fixes

* Pass DB sku ([#42](https://github.com/wandb/terraform-azurerm-wandb/issues/42)) ([2cba3b4](https://github.com/wandb/terraform-azurerm-wandb/commit/2cba3b4e3d24df892f11c515874346739f9500c4))

### [2.1.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.1...v2.1.2) (2024-02-05)


### Reverts

* Revert "alphabetize variables" ([25522dc](https://github.com/wandb/terraform-azurerm-wandb/commit/25522dc6bbf86bef341a12f010d1fa393b72aa38))
* Revert "pass etcd keystore key id to module" ([007ecb5](https://github.com/wandb/terraform-azurerm-wandb/commit/007ecb5aba0fa94d539783ad421d796512a4ebd7))
* Revert "a little bit of cleanup" ([b3578ac](https://github.com/wandb/terraform-azurerm-wandb/commit/b3578ac7ab7713cfe43f58adb772d62550bc4830))

### [2.1.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.1.0...v2.1.1) (2023-12-19)


### Bug Fixes

* Actually use node_pool_vm_count ([#39](https://github.com/wandb/terraform-azurerm-wandb/issues/39)) ([00274f1](https://github.com/wandb/terraform-azurerm-wandb/commit/00274f135f8fbf3d27146f8a45f4f522aa3ee25d))

## [2.1.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.0.1...v2.1.0) (2023-12-13)


### Features

* Add resource tags ([#38](https://github.com/wandb/terraform-azurerm-wandb/issues/38)) ([8ece24e](https://github.com/wandb/terraform-azurerm-wandb/commit/8ece24ea4df687473ce073e9afa937e132f01caf))

### [2.0.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.0.0...v2.0.1) (2023-12-12)


### Bug Fixes

* Source extraEnv from other_wandb_env variable ([#36](https://github.com/wandb/terraform-azurerm-wandb/issues/36)) ([17cbde7](https://github.com/wandb/terraform-azurerm-wandb/commit/17cbde7351a9747d2a004d14c6bba10e05035caf))

## [2.0.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.7.1...v2.0.0) (2023-10-18)


### ⚠ BREAKING CHANGES

* Implement operator (#23)

### Features

* Implement operator ([#23](https://github.com/wandb/terraform-azurerm-wandb/issues/23)) ([26a4392](https://github.com/wandb/terraform-azurerm-wandb/commit/26a439278fed1f8a884142b3ce3feafb4e28ed8e))

### [1.7.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.7.0...v1.7.1) (2023-10-12)


### Bug Fixes

* Long vault names ([#34](https://github.com/wandb/terraform-azurerm-wandb/issues/34)) ([8cdeafc](https://github.com/wandb/terraform-azurerm-wandb/commit/8cdeafc8637041bc8f4eb32cf641ab91655b7335))

## [1.7.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.6.0...v1.7.0) (2023-10-12)


### Features

* Enable azure secret store webhooks ([#33](https://github.com/wandb/terraform-azurerm-wandb/issues/33)) ([4739959](https://github.com/wandb/terraform-azurerm-wandb/commit/47399593843b6725c4eca5470ea471a0f3747033))

## [1.6.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.5.0...v1.6.0) (2023-10-09)


### Features

* Update resource reqs and limits ([#27](https://github.com/wandb/terraform-azurerm-wandb/issues/27)) ([bd2355e](https://github.com/wandb/terraform-azurerm-wandb/commit/bd2355edc497fd00934890e8d0203c3222ebe7fd))

## [1.5.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.4.2...v1.5.0) (2023-10-06)


### Features

* Enable redis ([#31](https://github.com/wandb/terraform-azurerm-wandb/issues/31)) ([ad587d4](https://github.com/wandb/terraform-azurerm-wandb/commit/ad587d46cc2b2a326dd99f51ce389cb6976ad166))

### [1.4.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.4.1...v1.4.2) (2023-10-04)


### Bug Fixes

* Add perms for ingress to update the public subnet as well ([#29](https://github.com/wandb/terraform-azurerm-wandb/issues/29)) ([0af4bf3](https://github.com/wandb/terraform-azurerm-wandb/commit/0af4bf3310979e972cd04e19ee6d06cfec313742))

### [1.4.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.4.0...v1.4.1) (2023-10-04)


### Bug Fixes

* Add perms for ingress to update the public subnet as well ([#28](https://github.com/wandb/terraform-azurerm-wandb/issues/28)) ([959c50f](https://github.com/wandb/terraform-azurerm-wandb/commit/959c50fe3a7379dd37350443d1b14787d9587ba2))

## [1.4.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.3.1...v1.4.0) (2023-09-13)


### Features

* Update to terraform-kubernetes-wandb v1.12.0 ([#26](https://github.com/wandb/terraform-azurerm-wandb/issues/26)) ([edd006e](https://github.com/wandb/terraform-azurerm-wandb/commit/edd006e94c4cba4c4504def73ec2b45f3435f551))

### [1.3.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.3.0...v1.3.1) (2023-08-15)


### Bug Fixes

* Create LICENSE ([#19](https://github.com/wandb/terraform-azurerm-wandb/issues/19)) ([0dcb3e5](https://github.com/wandb/terraform-azurerm-wandb/commit/0dcb3e59573b06c1a0e295ac667b5d90771b2ee6))
* Remove db version validation ([#20](https://github.com/wandb/terraform-azurerm-wandb/issues/20)) ([0a787ba](https://github.com/wandb/terraform-azurerm-wandb/commit/0a787ba69b27a6b12442e1e4936017dd5c6665cc))

## [1.3.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.2.1...v1.3.0) (2023-04-03)


### Features

* Enable non azure bucket ([#15](https://github.com/wandb/terraform-azurerm-wandb/issues/15)) ([2939eed](https://github.com/wandb/terraform-azurerm-wandb/commit/2939eedf4a101116c7301f6bad0af3883a07e7c4))


### Bug Fixes

* Enable non azure bucket ([7f1b9ba](https://github.com/wandb/terraform-azurerm-wandb/commit/7f1b9ba558d783d3db65f313f1f729834ca502f5))

### [1.2.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.2.0...v1.2.1) (2022-11-07)


### Bug Fixes

* Fix byob logic for queue ([94a27ad](https://github.com/wandb/terraform-azurerm-wandb/commit/94a27add94e1f7b0f1b06a04750849cdc26ca4fe))

## [1.2.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.1.0...v1.2.0) (2022-11-02)


### Features

* BYOB ([375d83b](https://github.com/wandb/terraform-azurerm-wandb/commit/375d83bc9a43e051844b02864be346d8e298106a))
* BYOB ([9e4fecc](https://github.com/wandb/terraform-azurerm-wandb/commit/9e4fecc240ce8f50992490bf5550bb8adff6d586))

## [1.1.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.0.1...v1.1.0) (2022-10-21)


### Features

* Add storage account creds ([2d543be](https://github.com/wandb/terraform-azurerm-wandb/commit/2d543bea5562e28591da6e49fa57e98d83d2fa92))

### [1.0.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v1.0.0...v1.0.1) (2022-09-02)


### Bug Fixes

* Add oidc secret variable ([42939f2](https://github.com/wandb/terraform-azurerm-wandb/commit/42939f2fcdf8c4012330afcdefa13819d6f87b1e))
* Post release patchs ([d46cf52](https://github.com/wandb/terraform-azurerm-wandb/commit/d46cf52599d3364ec37b155f2f65e516838589ce))

## 1.0.0 (2022-09-01)


### Features

* Inital release ([65e545c](https://github.com/wandb/terraform-azurerm-wandb/commit/65e545cad260bf7b8b0940d77628b64304895fcf))
* Inital release of terraform module ([3bef1c6](https://github.com/wandb/terraform-azurerm-wandb/commit/3bef1c6d6654c405350385fe1bd517fdc77808ea))
