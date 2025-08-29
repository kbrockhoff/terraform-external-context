# Changelog

## [0.2.0](https://github.com/kbrockhoff/terraform-external-context/compare/v0.1.0...v0.2.0) (2025-08-29)


### Features

* add AI metadata and improve documentation ([a71e63d](https://github.com/kbrockhoff/terraform-external-context/commit/a71e63dad056bb21684d14ebde354e738dd05a54))
* add not_applicable_enabled variable for conditional tag generation ([de6c539](https://github.com/kbrockhoff/terraform-external-context/commit/de6c5399734574001254fbe354e00de88c9caeb7))
* enhance tagging system with flexible PM/ITSM integration ([ac45787](https://github.com/kbrockhoff/terraform-external-context/commit/ac45787f55908b7b0a534be6fee0f1c2e72fb5d4))

## 0.1.0 (2025-08-09)


### ⚠ BREAKING CHANGES

* **validation:** Renamed 'confidentiality' variable to 'sensitivity' with new enumeration values.

### Features

* add configurable tag prefix, ITSM tracking, and source repo tagging ([eca82e7](https://github.com/kbrockhoff/terraform-external-context/commit/eca82e7b24a4cbbc2a8da501fdfdcfc0bc3356e6))
* add data_tags equivalent transformations and missing tags_as_kvp_list output ([2d85ffb](https://github.com/kbrockhoff/terraform-external-context/commit/2d85ffb7026acb34b371c49d1074cfefeafc41a6))
* **examples:** add subcontext example demonstrating context inheritance ([0438327](https://github.com/kbrockhoff/terraform-external-context/commit/0438327bd136b5338cf01995bc9f5f04a5798c55))
* implement comprehensive context module with standardized tagging ([70f7fd3](https://github.com/kbrockhoff/terraform-external-context/commit/70f7fd314e38544fb9747d00e0fe99f14222a97b))
* **validation:** rename confidentiality to sensitivity and expand validation ([0eef66d](https://github.com/kbrockhoff/terraform-external-context/commit/0eef66d800851afe4f7edd766503fd544423ef7e))


### Bug Fixes

* **formatting:** add trailing newlines to all files and fix test suite ([a2292bb](https://github.com/kbrockhoff/terraform-external-context/commit/a2292bb4cd117179374a10ba3959c1284fd518fe))
* improve error handling ([be5c4da](https://github.com/kbrockhoff/terraform-external-context/commit/be5c4da41f681c22d70fb36c9f9689f1927d3580))
* improve security ([714ce3b](https://github.com/kbrockhoff/terraform-external-context/commit/714ce3b98f0eb0570b8d96f6a56c8afdaef2e4fa))
* **locals:** correct syntax error in name prefix calculation ([852534d](https://github.com/kbrockhoff/terraform-external-context/commit/852534d90daeafb2e7fb981be5470043c7329daf))
* remove magic number ([5000a18](https://github.com/kbrockhoff/terraform-external-context/commit/5000a184d214363b9b955cffde8fb3ce504dde1c))
* remove unused ([484ecdc](https://github.com/kbrockhoff/terraform-external-context/commit/484ecdc610cc8e227e2db691359c4ac0b29568e7))
* remove unused value ([49c04b4](https://github.com/kbrockhoff/terraform-external-context/commit/49c04b4bd0dfbc99c87e00fc2ad5057d9f20d914))
* sp ([8027df0](https://github.com/kbrockhoff/terraform-external-context/commit/8027df0fe7ee3f395507ca07b96df30e8cf4f6d7))
* update module source references to use Terraform Registry format ([25aa88a](https://github.com/kbrockhoff/terraform-external-context/commit/25aa88a8e6b1236953d6407d09adb28fd5f69c91))

## Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
