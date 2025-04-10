# Changelog

All notable changes to this project will be documented in this file.

### [7.3.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.3.1...v7.3.2) (2025-04-10)


### Bug Fixes

* Use vars in secure_storage_connector examples ([#136](https://github.com/wandb/terraform-azurerm-wandb/issues/136)) ([686ecd1](https://github.com/wandb/terraform-azurerm-wandb/commit/686ecd148534d848bfda8048eac156a9a71e4a05))

### [7.3.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.3.0...v7.3.1) (2025-04-10)


### Bug Fixes

* Workload Identity ([#133](https://github.com/wandb/terraform-azurerm-wandb/issues/133)) ([4599ca6](https://github.com/wandb/terraform-azurerm-wandb/commit/4599ca63838e43ca620d6ec9950728423cf7a753))

## [7.3.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.2.2...v7.3.0) (2025-04-09)


### Features

* Output spec ([#135](https://github.com/wandb/terraform-azurerm-wandb/issues/135)) ([5fdea4f](https://github.com/wandb/terraform-azurerm-wandb/commit/5fdea4fbe649b009a0d7868428d08c6df4a96192))

### [7.2.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.2.1...v7.2.2) (2025-03-28)


### Bug Fixes

* Patch deploy ([#132](https://github.com/wandb/terraform-azurerm-wandb/issues/132)) ([29ec3b6](https://github.com/wandb/terraform-azurerm-wandb/commit/29ec3b6f0ced89c27c9a3872118ca62c86c8c538))

### [7.2.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.2.0...v7.2.1) (2025-03-20)


### Bug Fixes

* Tag cache_size on cloud managed K8s ([#129](https://github.com/wandb/terraform-azurerm-wandb/issues/129)) ([3b6b86f](https://github.com/wandb/terraform-azurerm-wandb/commit/3b6b86f1ed65db6c0431ef4a4dfb153bda8eff85))

## [7.2.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.1.0...v7.2.0) (2025-03-19)


### Features

* **deploy:** Support ctrlplane redis ([#128](https://github.com/wandb/terraform-azurerm-wandb/issues/128)) ([0b65265](https://github.com/wandb/terraform-azurerm-wandb/commit/0b65265698b24c83bef515f4313122159621bbe1))

## [7.1.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.0.1...v7.1.0) (2025-03-11)


### Features

* Add helm chart toggles ([#127](https://github.com/wandb/terraform-azurerm-wandb/issues/127)) ([11d40ca](https://github.com/wandb/terraform-azurerm-wandb/commit/11d40ca747bb08ab21a2fb189e6bd87b822ac43f))

### [7.0.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v7.0.0...v7.0.1) (2025-03-06)


### Bug Fixes

* Revert Provision Azure storage container for SaaS BYOB ([#118](https://github.com/wandb/terraform-azurerm-wandb/issues/118)) ([#126](https://github.com/wandb/terraform-azurerm-wandb/issues/126)) ([fddeb5d](https://github.com/wandb/terraform-azurerm-wandb/commit/fddeb5d269c43a2330efbc9d30a4e6f0c18e3b70))

## [7.0.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v6.0.0...v7.0.0) (2025-02-25)


### ⚠ BREAKING CHANGES

* Expose externalized redis to helm for console metrics (#125)

### Bug Fixes

* Expose externalized redis to helm for console metrics ([#125](https://github.com/wandb/terraform-azurerm-wandb/issues/125)) ([7c07d00](https://github.com/wandb/terraform-azurerm-wandb/commit/7c07d00f9fe46ce3ce5ceccd9af0c6bd672945f5))

## [6.0.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.2.2...v6.0.0) (2025-02-19)


### ⚠ BREAKING CHANGES

* INFRA-478 external-redis toggles (#124)

### Features

* INFRA-478 external-redis toggles ([#124](https://github.com/wandb/terraform-azurerm-wandb/issues/124)) ([4bc1cd1](https://github.com/wandb/terraform-azurerm-wandb/commit/4bc1cd1bd0766f5f30d27bd7c396c56faadfbac1))

### [5.2.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.2.1...v5.2.2) (2025-02-11)


### Bug Fixes

* INFRA-383 finicky terraform fixes ([#121](https://github.com/wandb/terraform-azurerm-wandb/issues/121)) ([f412a04](https://github.com/wandb/terraform-azurerm-wandb/commit/f412a045e81c6701cd5c034681c484c03b0b8f88))

### [5.2.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.2.0...v5.2.1) (2025-02-11)


### Bug Fixes

* INFRA-383 some redis tf var null protection ([#120](https://github.com/wandb/terraform-azurerm-wandb/issues/120)) ([bfd5fe9](https://github.com/wandb/terraform-azurerm-wandb/commit/bfd5fe9eaea07fc25302bb44fd65a8e34608eec0))

## [5.2.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.1.3...v5.2.0) (2025-02-10)


### Features

* INFRA-383 support for "external" redis creation ([#119](https://github.com/wandb/terraform-azurerm-wandb/issues/119)) ([4a94066](https://github.com/wandb/terraform-azurerm-wandb/commit/4a9406642aaf2743872e68bcc4192c825a4cf6cd))

### [5.1.3](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.1.2...v5.1.3) (2025-01-13)


### Bug Fixes

* Proper bucket vs default bucket usage ([#110](https://github.com/wandb/terraform-azurerm-wandb/issues/110)) ([a91ad9e](https://github.com/wandb/terraform-azurerm-wandb/commit/a91ad9e041ea2deb8bb2b76712d3f38b91e37cd9))

### [5.1.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.1.1...v5.1.2) (2025-01-10)


### Bug Fixes

* Helm cursed comma ([#117](https://github.com/wandb/terraform-azurerm-wandb/issues/117)) ([a405ed0](https://github.com/wandb/terraform-azurerm-wandb/commit/a405ed0af7458dced02c54f43d2855087fd596bd))

### [5.1.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.1.0...v5.1.1) (2025-01-09)


### Bug Fixes

* Identity typo ([#116](https://github.com/wandb/terraform-azurerm-wandb/issues/116)) ([5c46eea](https://github.com/wandb/terraform-azurerm-wandb/commit/5c46eeaf99920eb32e97b66d1c7c9e6f1326b33f))

## [5.1.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v5.0.0...v5.1.0) (2025-01-08)


### Features

* Pass console identity info ([#115](https://github.com/wandb/terraform-azurerm-wandb/issues/115)) ([d945e4c](https://github.com/wandb/terraform-azurerm-wandb/commit/d945e4cea3d623382283d23d24d820332b2ba18b))

## [5.0.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v4.1.2...v5.0.0) (2025-01-07)


### ⚠ BREAKING CHANGES

* Bump helm-wandb vers to v2.0.0, requires TF > 1.9 (#114)

### Features

* Bump helm-wandb vers to v2.0.0, requires TF > 1.9 ([#114](https://github.com/wandb/terraform-azurerm-wandb/issues/114)) ([77b7639](https://github.com/wandb/terraform-azurerm-wandb/commit/77b763934f52875af7fb77fbc102c49c21bc7d33))

### [4.1.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v4.1.1...v4.1.2) (2024-12-18)


### Bug Fixes

* Tags were missing on redis ([#113](https://github.com/wandb/terraform-azurerm-wandb/issues/113)) ([48afa7c](https://github.com/wandb/terraform-azurerm-wandb/commit/48afa7ca3fbbcd1a1308fe7dd3f4055bac8fd503))

### [4.1.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v4.1.0...v4.1.1) (2024-12-17)


### Bug Fixes

* Don't put special tags on the DB, added this to the var we pass in ([#112](https://github.com/wandb/terraform-azurerm-wandb/issues/112)) ([7f5c51d](https://github.com/wandb/terraform-azurerm-wandb/commit/7f5c51d6d48d173fd1c1542ac6e28d63395dea94))

## [4.1.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v4.0.0...v4.1.0) (2024-12-04)


### Features

* Add internalJWTMap used for inter service communication authentication ([#109](https://github.com/wandb/terraform-azurerm-wandb/issues/109)) ([5bf0177](https://github.com/wandb/terraform-azurerm-wandb/commit/5bf017752966db335d711cbb147f618664d6f1b7))

## [4.0.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v3.0.3...v4.0.0) (2024-10-29)


### ⚠ BREAKING CHANGES

* Enable autoscaling (#98)

### Features

* Enable autoscaling ([#98](https://github.com/wandb/terraform-azurerm-wandb/issues/98)) ([4ec49cd](https://github.com/wandb/terraform-azurerm-wandb/commit/4ec49cd865697edec72c8b8105e90b2d7cbf346d))

### [3.0.3](https://github.com/wandb/terraform-azurerm-wandb/compare/v3.0.2...v3.0.3) (2024-10-01)


### Bug Fixes

* Handle per subscription AZ restrictions ([#106](https://github.com/wandb/terraform-azurerm-wandb/issues/106)) ([997c48b](https://github.com/wandb/terraform-azurerm-wandb/commit/997c48b1de197ca5c952b5660adf17ec41991241))

### [3.0.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v3.0.1...v3.0.2) (2024-10-01)


### Bug Fixes

* Use variables for operator helm release ([#105](https://github.com/wandb/terraform-azurerm-wandb/issues/105)) ([e418924](https://github.com/wandb/terraform-azurerm-wandb/commit/e4189244002c70ddc2fbfa1362afa9c8e769bb64))

### [3.0.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v3.0.0...v3.0.1) (2024-09-30)


### Bug Fixes

* Add info for users moving from 2.x to 3.x ([#103](https://github.com/wandb/terraform-azurerm-wandb/issues/103)) ([df95c36](https://github.com/wandb/terraform-azurerm-wandb/commit/df95c36a30f024ed1a4f650fc665dc87619577c2))
* Reference the correct value from deployment sizes ([#104](https://github.com/wandb/terraform-azurerm-wandb/issues/104)) ([d910a41](https://github.com/wandb/terraform-azurerm-wandb/commit/d910a411637352673c1df11a7f0ce8e461eb24db))

## [3.0.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.15.1...v3.0.0) (2024-09-27)


### ⚠ BREAKING CHANGES

* Automatically select availability zones based on node type when not specified (#102)

### Features

* Automatically select availability zones based on node type when not specified ([#102](https://github.com/wandb/terraform-azurerm-wandb/issues/102)) ([8a17acc](https://github.com/wandb/terraform-azurerm-wandb/commit/8a17accd070035004e7665cb46a30c0fe41283fb))

### [2.15.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.15.0...v2.15.1) (2024-09-12)


### Bug Fixes

* Bump operator chart and controller image ([#99](https://github.com/wandb/terraform-azurerm-wandb/issues/99)) ([76e2511](https://github.com/wandb/terraform-azurerm-wandb/commit/76e25119c12157c8ee19c013c6544305ddd62b7c))

## [2.15.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.14.0...v2.15.0) (2024-08-26)


### Features

* Add support for Private Link to ClickHouse ([#93](https://github.com/wandb/terraform-azurerm-wandb/issues/93)) ([c9b4d66](https://github.com/wandb/terraform-azurerm-wandb/commit/c9b4d664dfc85c5f603e6a14b694923af8d1259d))

## [2.14.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.13.2...v2.14.0) (2024-08-26)


### Features

* Add optional path var for instance level bucket path  ([#84](https://github.com/wandb/terraform-azurerm-wandb/issues/84)) ([2f430f2](https://github.com/wandb/terraform-azurerm-wandb/commit/2f430f25b98cac894c794edce12215d1847df475))

### [2.13.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.13.1...v2.13.2) (2024-08-05)


### Bug Fixes

* Max Length of Storage Account name ([#90](https://github.com/wandb/terraform-azurerm-wandb/issues/90)) ([38d012f](https://github.com/wandb/terraform-azurerm-wandb/commit/38d012f27a16c9a77d52e90e9bad99ae432bec83))

### [2.13.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.13.0...v2.13.1) (2024-08-05)


### Bug Fixes

* Azure storage and Vault simplified ([#89](https://github.com/wandb/terraform-azurerm-wandb/issues/89)) ([4832d24](https://github.com/wandb/terraform-azurerm-wandb/commit/4832d247cdf8e75fe1ae75e7f4da8b528cde93e4))

## [2.13.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.12.2...v2.13.0) (2024-08-01)


### Features

* Added for encrypting the database and blob storage with WB-managed key ([#49](https://github.com/wandb/terraform-azurerm-wandb/issues/49)) ([519c340](https://github.com/wandb/terraform-azurerm-wandb/commit/519c340fbf855743fe77b3ae075e6bfdb84740c2))

### [2.12.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.12.1...v2.12.2) (2024-08-01)


### Bug Fixes

* Bump operator chart versions ([#87](https://github.com/wandb/terraform-azurerm-wandb/issues/87)) ([51e8736](https://github.com/wandb/terraform-azurerm-wandb/commit/51e873629db3263a27beda2bcf3f40190cc7e0ae))

### [2.12.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.12.0...v2.12.1) (2024-08-01)


### Bug Fixes

* Bump operator chart versions ([#86](https://github.com/wandb/terraform-azurerm-wandb/issues/86)) ([d6a38f2](https://github.com/wandb/terraform-azurerm-wandb/commit/d6a38f22ab11cc131f7d7200f77ea39e6e53c8e3))

## [2.12.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.11.3...v2.12.0) (2024-07-31)


### Features

* Bump operator image and chart versions ([#85](https://github.com/wandb/terraform-azurerm-wandb/issues/85)) ([d582e7c](https://github.com/wandb/terraform-azurerm-wandb/commit/d582e7ccfb8bb12354f0bff1001bf4ed59e1d9d5))

### [2.11.3](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.11.2...v2.11.3) (2024-07-11)


### Bug Fixes

* Pass cloudprovider value to the helm charts ([#83](https://github.com/wandb/terraform-azurerm-wandb/issues/83)) ([0606602](https://github.com/wandb/terraform-azurerm-wandb/commit/06066020ac57d2d93e406e4b103feffb260426e0))

### [2.11.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.11.1...v2.11.2) (2024-06-26)


### Bug Fixes

* Change ingress timeout to string ([#80](https://github.com/wandb/terraform-azurerm-wandb/issues/80)) ([64b96bc](https://github.com/wandb/terraform-azurerm-wandb/commit/64b96bc64ff90c6cf310ae3d3f4646a614712617))

### [2.11.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.11.0...v2.11.1) (2024-06-25)


### Bug Fixes

* Increase ingress timeout ([#78](https://github.com/wandb/terraform-azurerm-wandb/issues/78)) ([4ee0e60](https://github.com/wandb/terraform-azurerm-wandb/commit/4ee0e6041076ea8711523d02ff78aacabf2f2480))

## [2.11.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.10.0...v2.11.0) (2024-06-25)


### Features

* Removed duplicate variables (create_private_link) ([#77](https://github.com/wandb/terraform-azurerm-wandb/issues/77)) ([27dd8aa](https://github.com/wandb/terraform-azurerm-wandb/commit/27dd8aa43e86aae019afea86c3b76da51ac9f103))

## [2.10.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.9.0...v2.10.0) (2024-06-25)


### Features

* Fixed branch (issue-id-43) issue ([#76](https://github.com/wandb/terraform-azurerm-wandb/issues/76)) ([49876fc](https://github.com/wandb/terraform-azurerm-wandb/commit/49876fcf6298c64abdff7639518edd5a7cb46300))

## [2.9.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.8.0...v2.9.0) (2024-06-24)


### Features

* Added storage account private endpoint ([#59](https://github.com/wandb/terraform-azurerm-wandb/issues/59)) ([9c28821](https://github.com/wandb/terraform-azurerm-wandb/commit/9c288219a5c42613a76948096409ad2a6f6de16c))

## [2.8.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.7.0...v2.8.0) (2024-06-21)


### Features

* Added support for Azure Private Link ([#48](https://github.com/wandb/terraform-azurerm-wandb/issues/48)) ([642eda1](https://github.com/wandb/terraform-azurerm-wandb/commit/642eda172295c5fb1751f241eea48ec910d62d3d))

## [2.7.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.6.1...v2.7.0) (2024-06-21)


### Features

* Added t-shirt size feature ([#72](https://github.com/wandb/terraform-azurerm-wandb/issues/72)) ([fe26616](https://github.com/wandb/terraform-azurerm-wandb/commit/fe26616f378eee30fbeeff62e1d22b2f8f36a56d))

### [2.6.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.6.0...v2.6.1) (2024-06-20)


### Bug Fixes

* Make default node pool zone configurable ([#75](https://github.com/wandb/terraform-azurerm-wandb/issues/75)) ([cfa5a89](https://github.com/wandb/terraform-azurerm-wandb/commit/cfa5a89f523b9982a3cb6fa57548558c5a8eec49))

## [2.6.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.5.0...v2.6.0) (2024-06-17)


### Features

* Added otel fix ([#74](https://github.com/wandb/terraform-azurerm-wandb/issues/74)) ([4aeb5c2](https://github.com/wandb/terraform-azurerm-wandb/commit/4aeb5c28ae9c1d31a8aa65b38ea5a3da08adb5c6))

## [2.5.0](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.4.2...v2.5.0) (2024-06-06)


### Features

* Added examples support ([#64](https://github.com/wandb/terraform-azurerm-wandb/issues/64)) ([1eb9693](https://github.com/wandb/terraform-azurerm-wandb/commit/1eb9693db4b3c062adc8e904ff436037db142a0a))

### [2.4.2](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.4.1...v2.4.2) (2024-06-06)


### Bug Fixes

* Make max pods configurabe and return default to 30 for now ([#71](https://github.com/wandb/terraform-azurerm-wandb/issues/71)) ([0b1490e](https://github.com/wandb/terraform-azurerm-wandb/commit/0b1490e4d700b64775445d01a6b5b7294edea2e8))

### [2.4.1](https://github.com/wandb/terraform-azurerm-wandb/compare/v2.4.0...v2.4.1) (2024-06-06)


### Bug Fixes

* Reduce max pods ([#70](https://github.com/wandb/terraform-azurerm-wandb/issues/70)) ([718f25a](https://github.com/wandb/terraform-azurerm-wandb/commit/718f25aa3dd01c6ea5e2b84501d040fa10397e9b))

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
