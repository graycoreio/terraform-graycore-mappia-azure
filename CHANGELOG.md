# Changelog

## 0.1.0 (2023-01-20)


### ⚠ BREAKING CHANGES

* if you have an existing cluster, a migration process on media and var is necessary
* this change will break state paths
* this change will break state paths

### Features

* add buffer annotation to ingresses ([d3d0b06](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/d3d0b06648734ec078fefb68507423e07a1ae135))
* add OMS and cluster zones as user inputs ([209d59a](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/209d59a216a2c161c5cf7a714547e72981b50648))
* add user inputs for helm ingress chart ([b3e82ac](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/b3e82ac57bcdc6ebd95953ba1a3cd8722c6ec4f8))
* add variables input for public-ip ([f9fdf35](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/f9fdf3556d88f7ab012e3e283694bb74cf793706))
* allow user input mappia values.yaml ([0585aef](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/0585aef76da952edaa312ea63d62dd28aa5bdba8))
* allow user to provide akvaks values ([e21541d](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/e21541dbf713f363f6ffc8d3e74d6a889fac7922))
* basic terraform setup for azure ([#317](https://github.com/graycoreio/terraform-graycore-mappia-azure/issues/317)) ([93d936a](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/93d936ae5e3b4186d965a959012ba96c5c932593))
* explicit helm resource dependency on aks ([86170cc](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/86170cce23173e811306c13943a7b718bb5307d0))
* give user more input options ([c582ed4](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/c582ed424f67ad9cb3c0148e078d70dc56e5a272))
* increase min default node qty to 4 ([e506077](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/e506077d930732b64c604bf0e24219946de6295a))
* make default config optional ([c0415b0](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/c0415b05cc826b09002a7f0685cb33214d75ba74))
* make version definable by the user ([5da73bf](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/5da73bfa5d645c555013a0f8f3ad4264095ad8de))
* randomize aks name if not provided by user ([5b743ec](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/5b743ec34b72b3f23e2ab4ff2d06db273565e24c))


### Bug Fixes

* add akvaks version ([dde8538](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/dde853841acb3ad8cf6efa14c7e47d34717f60b7))
* fix aks access policy id ([00c691c](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/00c691c068674f389523b107f752d4aafe55892f))
* **keyvault:** remove random when user input ([44ff5c3](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/44ff5c303f9b363e332eed689da229b0eea281a0))
* make pub/media and var writable ([dec184b](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/dec184b09e2e866a0d74ab73539c9b6c5fd022ad))
* unnecessary use of data resource ([a8bc38b](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/a8bc38b076beeafefc3782b3822f798384809a0c))
* use akvaks from mappia's repo ([bd67700](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/bd6770006b5b009effaa9aa7f72968ee3fd09e48))
* use mappia from terraform module registry ([aa8f284](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/aa8f28459d92916255cdf92a7a364d634ab668f4))
* use right variable to create linux_os_config ([e1f3739](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/e1f3739b571cc0b8d5f60b15390c536ebe1bce38))


### Code Refactoring

* remove aks submodule ([79f5f94](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/79f5f941d034b92cc2481f1d75c48bf7f8b1019b))
* remove keyvault submodule ([fecd77c](https://github.com/graycoreio/terraform-graycore-mappia-azure/commit/fecd77c12612ee732271022a8852558471f719e1))
