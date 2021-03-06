# Oranges changelog

## [4.4.0](https://github.com/benthevining/Oranges/compare/v4.3.0...v4.4.0) (2022-07-21)


### Features

* added a clang-format module ([05f2f9d](https://github.com/benthevining/Oranges/commit/05f2f9da7c1667bb59cc2e2dbd56f830056af6fb))

## [4.3.0](https://github.com/benthevining/Oranges/compare/v4.2.0...v4.3.0) (2022-07-21)


### Features

* added code signing modules ([3ca48b9](https://github.com/benthevining/Oranges/commit/3ca48b96eb0bae5d483cffd51db61b64726544a4))

## [4.2.0](https://github.com/benthevining/Oranges/compare/v4.1.0...v4.2.0) (2022-07-20)


### Features

* added more find modules ([41ae6d1](https://github.com/benthevining/Oranges/commit/41ae6d1259e213b068c45879f1d9fc4bd11c0b91))

## [4.1.0](https://github.com/benthevining/Oranges/compare/v4.0.0...v4.1.0) (2022-07-18)


### Features

* added a find module for Catch2 ([56bc491](https://github.com/benthevining/Oranges/commit/56bc491cb5385d519566eac1045bf457634e0190))

## [4.0.0](https://github.com/benthevining/Oranges/compare/v3.3.0...v4.0.0) (2022-07-17)


### ⚠ BREAKING CHANGES

* static analysis tools are no longer represented using targets

Precommit-Verified: 4c1cb29fefde724c2cd09a35dd0bc6ac4cf5f6281186df905e164d47c3e4070d

* using functions instead of targets for static analysis ([4257e29](https://github.com/benthevining/Oranges/commit/4257e293d8db321039c1d98d676f77e664c9bec7))

## [3.3.0](https://github.com/benthevining/Oranges/compare/v3.2.0...v3.3.0) (2022-07-14)


### Features

* added a find module for pffft ([031fa48](https://github.com/benthevining/Oranges/commit/031fa48e59493ec85f113ec9266a8b4a6c6df715))

## [3.2.0](https://github.com/benthevining/Oranges/compare/v3.1.1...v3.2.0) (2022-07-10)


### Features

* added a find module for NE10 ([09b4957](https://github.com/benthevining/Oranges/commit/09b4957a49fc2668b87b166e58d55384b80c8d27))

## [3.1.1](https://github.com/benthevining/Oranges/compare/v3.1.0...v3.1.1) (2022-07-07)


### Bug Fixes

* fixing fetch of libsamplerate from GitHub ([70a2d95](https://github.com/benthevining/Oranges/commit/70a2d9572a41f3773455d3eebff460031dd162f2))
* fixing fetch of libsamplerate from GitHub ([6ef687f](https://github.com/benthevining/Oranges/commit/6ef687f73b5a8fe30cf56deea043fe2a72a3b299))

## [3.1.0](https://github.com/benthevining/Oranges/compare/v3.0.1...v3.1.0) (2022-07-07)


### Features

* added a find module for libsamplerate ([4bf269f](https://github.com/benthevining/Oranges/commit/4bf269f397a156c9502761e33955f4df39d9d7ad))

## [3.0.1](https://github.com/benthevining/Oranges/compare/v3.0.0...v3.0.1) (2022-07-03)


### Bug Fixes

* Fixing RTTI bug on Windows/Clang ([f29989c](https://github.com/benthevining/Oranges/commit/f29989cf7859854cde6c63b343b0d2625fb6f643))

## [3.0.0](https://github.com/benthevining/Oranges/compare/v2.24.0...v3.0.0) (2022-06-21)


### ⚠ BREAKING CHANGES

* static analysis module and target names have changed.

Precommit-Verified: 1db1d1fcc681d0d961e183c43b40f8c13571ca74ca67ee43c828a2036cb3405b

### Features

* added a script to generate a standard find module for a package ([81e8982](https://github.com/benthevining/Oranges/commit/81e89829a98480eb5ddf6f4337b496d8146b9806))
* added a script to update cmake format config with external commands ([d344200](https://github.com/benthevining/Oranges/commit/d344200721d7541d56860622a7e8e89973279376))
* added a UseProtobuf module ([c0ada35](https://github.com/benthevining/Oranges/commit/c0ada3571b79afb776adcc99e8a6fb671a870905))
* added Python script to update all instances of find_package for a certain package ([4e389d7](https://github.com/benthevining/Oranges/commit/4e389d7fd0fe597cf501eb7ca2032e47d5a9f3c4))


### Bug Fixes

* **deps:** update dependency semantic-release to v19.0.3 ([c0c0d53](https://github.com/benthevining/Oranges/commit/c0c0d53064e9b3449055d189308a4da65d2ad781))
* fixing logic in find modules ([322396f](https://github.com/benthevining/Oranges/commit/322396f41e2aa92ac45aa5ca8ed5019f68208047))
* fixing recursive dependencies in docs custom commands ([e0df366](https://github.com/benthevining/Oranges/commit/e0df366b869948b45a710181089c1f2a69931272))
* fixing RTTI on MSVC and WindowsClang ([1af2be3](https://github.com/benthevining/Oranges/commit/1af2be3f42049cbd4424e0e881186d69d58974fb))
* fixing some warning flags not recognized on all platforms ([ebcf0a8](https://github.com/benthevining/Oranges/commit/ebcf0a846e541426985629761d454935d5d95ce4))
* getting rid of deprecated internal macros ([55519fa](https://github.com/benthevining/Oranges/commit/55519fa6914e03eebf5e5ee1586feb0e6736ddde))
* properly encoding all cached bools as 1 or 0 in platform header ([7e8e4ea](https://github.com/benthevining/Oranges/commit/7e8e4ea8bacc5cafaf2d2f2ef539b2bc8c8840bd))
* removing deprecated internal macros ([410abdd](https://github.com/benthevining/Oranges/commit/410abdd1ad6b19e8c4b4a2d5c9327ef7d50f7d61))
* RTTI fix in MSVC ([d84c6eb](https://github.com/benthevining/Oranges/commit/d84c6eb4e0b9866682cb37d2d6cd884cb4c28364))
* updaing OrangesGraphviz filename ([cb964ab](https://github.com/benthevining/Oranges/commit/cb964ab7967306ae69ef897efe54292a8a8eb1be))


* renaming static analysis modules, separating ccache from their aggregate target ([08ed1aa](https://github.com/benthevining/Oranges/commit/08ed1aa41ee3e2199de5135cf7b244126db135bc))

## [2.24.0](http://github.com/benthevining/Oranges/compare/v2.23.4...v2.24.0) (2022-05-03)


### Features

* added a new IPO module ([b75d346](http://github.com/benthevining/Oranges/commit/b75d346ed87117c208fd3c86390a51e19684e81f))

### [2.23.4](http://github.com/benthevining/Oranges/compare/v2.23.3...v2.23.4) (2022-05-03)


### Bug Fixes

* not messing with IPO in default target ([861a477](http://github.com/benthevining/Oranges/commit/861a477183e2d4fbc1d62836eeb8723dd169f73a))

### [2.23.3](http://github.com/benthevining/Oranges/compare/v2.23.2...v2.23.3) (2022-05-02)


### Bug Fixes

* setting up graphviz in readme action ([ca27bfc](http://github.com/benthevining/Oranges/commit/ca27bfc060ea09cfc56465e9e4d5c9bf3023c300))

### [2.23.2](http://github.com/benthevining/Oranges/compare/v2.23.1...v2.23.2) (2022-05-02)


### Bug Fixes

* updating python version in readme workflow ([671030d](http://github.com/benthevining/Oranges/commit/671030d7a3680e128f4423698bebfa20b935c355))

### [2.23.1](http://github.com/benthevining/Oranges/compare/v2.23.0...v2.23.1) (2022-05-01)


### Bug Fixes

* generator expression escaping bug ([2138b66](http://github.com/benthevining/Oranges/commit/2138b666c030ef958f95749f5e58e208ceeea3b8))

## [2.23.0](http://github.com/benthevining/Oranges/compare/v2.22.0...v2.23.0) (2022-04-29)


### Features

* added properties to CLI help tool ([194b1c4](http://github.com/benthevining/Oranges/commit/194b1c46e820dffa1e08c47d6becd244d2786edd))


### Bug Fixes

* fixing bumpversion config ([8f37a29](http://github.com/benthevining/Oranges/commit/8f37a298f90fd248366ee42ec2aa38e84850a178))

## [2.22.0](http://github.com/benthevining/Oranges/compare/v2.21.1...v2.22.0) (2022-04-26)


### Features

* added an interface target for CXX concepts ([858fb62](http://github.com/benthevining/Oranges/commit/858fb626ffe32432849cf54e3d5a2d887c3f32b7))

### [2.21.1](http://github.com/benthevining/Oranges/compare/v2.21.0...v2.21.1) (2022-04-26)


### Bug Fixes

* missing include in AllIntegrations module ([3a4f0b4](http://github.com/benthevining/Oranges/commit/3a4f0b4b1e00882865d0ea9540664b1e30f360b5))

## [2.21.0](http://github.com/benthevining/Oranges/compare/v2.20.3...v2.21.0) (2022-04-26)


### Features

* added a new helper module for adding source files to targets ([8ceb7cf](http://github.com/benthevining/Oranges/commit/8ceb7cfcdd26222f753b2da5a0265308aa1adad3))

### [2.20.3](http://github.com/benthevining/Oranges/compare/v2.20.2...v2.20.3) (2022-04-25)


### Bug Fixes

* tar step paths ([ee74b79](http://github.com/benthevining/Oranges/commit/ee74b79878f9c24ca225c7728a6c3785ad7b8f55))
* tar step paths ([7d6199f](http://github.com/benthevining/Oranges/commit/7d6199f553b12bc32cf0e0d902df6a0ddafd7c84))
* using zip format ([0ba2f0f](http://github.com/benthevining/Oranges/commit/0ba2f0f86825e2bb3aac7995fcc04927a6302deb))
* zip format ([4b2806b](http://github.com/benthevining/Oranges/commit/4b2806b646f55b7c351acf3f0592fdf72987aab1))

### [2.20.2](http://github.com/benthevining/Oranges/compare/v2.20.1...v2.20.2) (2022-04-25)


### Bug Fixes

* fixing CMake tar step ([66b0886](http://github.com/benthevining/Oranges/commit/66b0886eb42194c0c4ba2d4621eb39f8c99a7fca))
* install tree isn't zipped into a subfolder ([8a093c6](http://github.com/benthevining/Oranges/commit/8a093c61f0b4717c9c9faf0d9eb7ff01cd3d5ccc))

### [2.20.1](http://github.com/benthevining/Oranges/compare/v2.20.0...v2.20.1) (2022-04-25)


### Bug Fixes

* zipping install tree into one tarball before uploading as GitHub asset ([f4df48a](http://github.com/benthevining/Oranges/commit/f4df48a31fa1cc4bafa03723660de853f0baa463))

## [2.20.0](http://github.com/benthevining/Oranges/compare/v2.19.0...v2.20.0) (2022-04-25)


### Features

* test release ([d472fca](http://github.com/benthevining/Oranges/commit/d472fca8482c2a1d58d9227f104b68982b646faa))

## [2.19.0](http://github.com/benthevining/Oranges/compare/v2.18.0...v2.19.0) (2022-04-25)


### Features

* test release ([74b946f](http://github.com/benthevining/Oranges/commit/74b946f1ebfc3ad7aef1552ac3f9523a05f898b8))

## [2.18.0](http://github.com/benthevining/Oranges/compare/v2.17.5...v2.18.0) (2022-04-25)


### Features

* test release ([05fa19f](http://github.com/benthevining/Oranges/commit/05fa19fa395f124ceff4b6f59417d8b2ce2ef13a))

### [2.17.5](http://github.com/benthevining/Oranges/compare/v2.17.4...v2.17.5) (2022-04-25)


### Bug Fixes

* IPO defaults to OFF ([7a6f8af](http://github.com/benthevining/Oranges/commit/7a6f8af5967664b32e67b8dbde818836211b4a84))

### [2.17.4](http://github.com/benthevining/Oranges/compare/v2.17.3...v2.17.4) (2022-04-19)


### Bug Fixes

* removed internal setting of CMAKE_OSX_DEPLOYMENT_TARGET ([f6acfb4](http://github.com/benthevining/Oranges/commit/f6acfb45c8f6b777a40db0ac58062e5f2980c333))

### [2.17.3](http://github.com/benthevining/Oranges/compare/v2.17.2...v2.17.3) (2022-04-19)


### Bug Fixes

* updating minimum iOS version to 13 ([26738cc](http://github.com/benthevining/Oranges/commit/26738cc0bfadbb17df9a3205680e4ae449683bb8))

### [2.17.2](http://github.com/benthevining/Oranges/compare/v2.17.1...v2.17.2) (2022-04-19)


### Bug Fixes

* fixing bumpversion config ([9796d90](http://github.com/benthevining/Oranges/commit/9796d9028f7140ca8556b714346be55f3f5ba5c0))
* fixing citation file syntax ([bba42e6](http://github.com/benthevining/Oranges/commit/bba42e653068394d05c6fcc417084cded819ed16))
* fixing citation file syntax ([369149e](http://github.com/benthevining/Oranges/commit/369149e3a2c9a62d4d65fa992e9570b964a591da))

### [2.17.1](http://github.com/benthevining/Oranges/compare/v2.17.0...v2.17.1) (2022-04-18)


### Bug Fixes

* fixing citation file syntax ([59328e3](http://github.com/benthevining/Oranges/commit/59328e3ee65486b2ae6edf0d656ce49f537405a9))

## [2.17.0](http://github.com/benthevining/Oranges/compare/v2.16.1...v2.17.0) (2022-04-16)


### Features

* including install tree in release ([4248b9f](http://github.com/benthevining/Oranges/commit/4248b9f3c086d8775db47362f9cddfac0fb8f086))

### [2.16.1](http://github.com/benthevining/Oranges/compare/v2.16.0...v2.16.1) (2022-04-15)


### Bug Fixes

* added flags to fix a bug compiling vDSP with GCC ([e055a23](http://github.com/benthevining/Oranges/commit/e055a237d31177d5e04ab5d7591995dda316a112))
* updating bumpversion config ([31e4e6a](http://github.com/benthevining/Oranges/commit/31e4e6a2acd6590bc39b1e97cc29d46880067c72))

## [2.16.0](http://github.com/benthevining/Oranges/compare/v2.15.0...v2.16.0) (2022-04-13)


### Features

* added a find module for Accelerate ([fe1e3f3](http://github.com/benthevining/Oranges/commit/fe1e3f36393a13cb7dc8d2e6a90bc99779cf0e09))

## [2.15.0](http://github.com/benthevining/Oranges/compare/v2.14.2...v2.15.0) (2022-04-12)


### Features

* making platform header generation more robust ([78b3906](http://github.com/benthevining/Oranges/commit/78b39069135255c0787468714c61d9ceb0771506))

### [2.14.2](http://github.com/benthevining/Oranges/compare/v2.14.1...v2.14.2) (2022-04-12)


### Bug Fixes

* making sure intel & arm options are always defined for platform header ([a3255f9](http://github.com/benthevining/Oranges/commit/a3255f973d494c9689bdf472abdaf5fe68e29f5e))

### [2.14.1](http://github.com/benthevining/Oranges/compare/v2.14.0...v2.14.1) (2022-04-11)


### Bug Fixes

* putting placeholder values in all platform header fields ([61deca3](http://github.com/benthevining/Oranges/commit/61deca384e061ba78c527f43b6b850a7d4cd81fb))

## [2.14.0](http://github.com/benthevining/Oranges/compare/v2.13.0...v2.14.0) (2022-04-09)


### Features

* added targets to help script ([e6ad0a7](http://github.com/benthevining/Oranges/commit/e6ad0a79bc54739668730543c388643661eaaed1))


### Bug Fixes

* fixing bumpversion integration with help script ([4ddb646](http://github.com/benthevining/Oranges/commit/4ddb6467d90da84f69a8ff022b430ec1010be829))

## [2.13.0](http://github.com/benthevining/Oranges/compare/v2.12.0...v2.13.0) (2022-04-09)


### Features

* added commands to help script ([9396b66](http://github.com/benthevining/Oranges/commit/9396b66bf20b5aae0df0c027e793ea9e6c87eac3))

## [2.12.0](http://github.com/benthevining/Oranges/compare/v2.11.0...v2.12.0) (2022-04-08)


### Features

* added improvements to the command-line help script ([88339b2](http://github.com/benthevining/Oranges/commit/88339b23ad1356a3a906f71c127a5d42d90cdaae))

## [2.11.0](http://github.com/benthevining/Oranges/compare/v2.10.0...v2.11.0) (2022-04-08)


### Features

* initial commit of help script ([f146a80](http://github.com/benthevining/Oranges/commit/f146a806be4145d72d757a1499988671d26c95f6))

## [2.10.0](http://github.com/benthevining/Oranges/compare/v2.9.0...v2.10.0) (2022-04-08)


### Features

* added modules to generate a build type header, and an aggregate standard header ([2078a07](http://github.com/benthevining/Oranges/commit/2078a071643bca740230c7070a57674d3c77c742))

## [2.9.0](http://github.com/benthevining/Oranges/compare/v2.8.0...v2.9.0) (2022-04-07)


### Features

* added FFTW installation script ([c8d713f](http://github.com/benthevining/Oranges/commit/c8d713f04ef8ee16c63aebab7ffe11dcf1cd4f45))

## [2.8.0](http://github.com/benthevining/Oranges/compare/v2.7.1...v2.8.0) (2022-04-06)


### Features

* added some more utility functions ([1797b95](http://github.com/benthevining/Oranges/commit/1797b954821d4a0a7b0022ad45375425d960e905))

### [2.7.1](http://github.com/benthevining/Oranges/compare/v2.7.0...v2.7.1) (2022-04-06)


### Bug Fixes

* CMake typo ([15a7217](http://github.com/benthevining/Oranges/commit/15a72174574e0d1bd6b7069dcace0a91d76a8188))
* CMake typo ([a616c30](http://github.com/benthevining/Oranges/commit/a616c3072914317ca67c1d6e6f45f116d028347f))

## [2.7.0](http://github.com/benthevining/Oranges/compare/v2.6.0...v2.7.0) (2022-04-05)


### Features

* added install types ([f846e37](http://github.com/benthevining/Oranges/commit/f846e3797905629ffae38507566ff29b454142d4))

## [2.6.0](http://github.com/benthevining/Oranges/compare/v2.5.1...v2.6.0) (2022-04-03)


### Features

* added options to oranges_fetch_repository to ignore git submodules and not pull submodules recursively ([c48a6c3](http://github.com/benthevining/Oranges/commit/c48a6c30938b4671f73f36c505ef7814622ca3b2))

### [2.5.1](http://github.com/benthevining/Oranges/compare/v2.5.0...v2.5.1) (2022-04-03)


### Bug Fixes

* not erroring if sphynx not found ([73d498e](http://github.com/benthevining/Oranges/commit/73d498ef6b4ecb05d0f93d7ad0ed5d83eff9a03a))

## [2.5.0](http://github.com/benthevining/Oranges/compare/v2.4.1...v2.5.0) (2022-04-02)


### Features

* added single and double precision components to FFTW find module ([fc85734](http://github.com/benthevining/Oranges/commit/fc857346a862b023a866f39604da3debc0f5c464))

### [2.4.1](http://github.com/benthevining/Oranges/compare/v2.4.0...v2.4.1) (2022-04-02)


### Bug Fixes

* updating iOS toolchain files to use correct archs ([7f56226](http://github.com/benthevining/Oranges/commit/7f56226eaa1a8568e9e60082de1773d793d32033))

## [2.4.0](http://github.com/benthevining/Oranges/compare/v2.3.0...v2.4.0) (2022-04-01)


### Features

* added a module to wrap integration of any autotools project ([adf0dcd](http://github.com/benthevining/Oranges/commit/adf0dcd9121a6f9da21ec2c8e86d6c52fe17f607))

## [2.3.0](http://github.com/benthevining/Oranges/compare/v2.2.0...v2.3.0) (2022-03-30)


### Features

* added a find module for ableton link ([f37f876](http://github.com/benthevining/Oranges/commit/f37f876fbbb4fe82d4f8753e421d4fea7c4ce7d8))

## [2.2.0](http://github.com/benthevining/Oranges/compare/v2.1.1...v2.2.0) (2022-03-30)


### Features

* added a find module for FFTW ([2d0dde1](http://github.com/benthevining/Oranges/commit/2d0dde1379fa8bedc54685623c8ae8b2524cd0d3))

### [2.1.1](http://github.com/benthevining/Oranges/compare/v2.1.0...v2.1.1) (2022-03-30)


### Bug Fixes

* **deps:** pin dependencies ([2e35d18](http://github.com/benthevining/Oranges/commit/2e35d188dff62300b6f7baaeab2456262fa11f07))

## [2.1.0](http://github.com/benthevining/Oranges/compare/v2.0.0...v2.1.0) (2022-03-27)


### Features

* added CLAP plugin format integration ([e51a70f](http://github.com/benthevining/Oranges/commit/e51a70fbea5eff39274f04ff5be4cff943e4a810))

## [2.0.0](http://github.com/benthevining/Oranges/compare/v1.28.3...v2.0.0) (2022-03-27)


### ⚠ BREAKING CHANGES

* all modules have been renamed with Oranges prefix, for consistency

Precommit-Verified: 3339c30f14b92f30409ce83a43cc890165b54daf43819ad99c490924fd73ffde

* renaming all modules with Oranges prefix ([c0336dc](http://github.com/benthevining/Oranges/commit/c0336dc5770b28132948d8fed4b3a92263efd2c5))

### [1.28.3](http://github.com/benthevining/Oranges/compare/v1.28.2...v1.28.3) (2022-03-26)


### Bug Fixes

* fixing bumpversion config ([a435422](http://github.com/benthevining/Oranges/commit/a435422c4e3127944f132610b0edd39947b34e70))

### [1.28.2](http://github.com/benthevining/Oranges/compare/v1.28.1...v1.28.2) (2022-03-26)


### Bug Fixes

* fixed GenerateExportHeader issue ([b57f649](http://github.com/benthevining/Oranges/commit/b57f649c42c83490c80ecf9f2fc0e234c94e63e7))
* fixing bumpversion regex ([35dfd30](http://github.com/benthevining/Oranges/commit/35dfd306c5d3860a763af90aa5244d3ebd94e027))

### [1.28.1](http://github.com/benthevining/Oranges/compare/v1.28.0...v1.28.1) (2022-03-26)


### Bug Fixes

* fixed bug in makefile template ([092f039](http://github.com/benthevining/Oranges/commit/092f039e45ff1ba91f70ead7c77fbf4a63e01a55))
* fixing makefile script ([65cfd96](http://github.com/benthevining/Oranges/commit/65cfd96254f701e62cf9ba5adb83dbdab14eb442))

## [1.28.0](http://github.com/benthevining/Oranges/compare/v1.27.0...v1.28.0) (2022-03-21)


### Features

* added option to find modules to try pkgconfig first ([2528bd8](http://github.com/benthevining/Oranges/commit/2528bd837aff6124f184e49cbd98f23fb51fc8ef))

## [1.27.0](http://github.com/benthevining/Oranges/compare/v1.26.1...v1.27.0) (2022-03-21)


### Features

* added a module to generate a header with platform macros ([a2d13bd](http://github.com/benthevining/Oranges/commit/a2d13bdc2d5d03ae3ab2696746968f1fdfbd6546))

### [1.26.1](http://github.com/benthevining/Oranges/compare/v1.26.0...v1.26.1) (2022-03-21)


### Bug Fixes

* fixed bug with include modules ([e11a273](http://github.com/benthevining/Oranges/commit/e11a27370ed25dd3b881f80074e4d56eaaaffb6b))

## [1.26.0](http://github.com/benthevining/Oranges/compare/v1.25.0...v1.26.0) (2022-03-21)


### Features

* added a module to update & install ruby gems ([4931d0a](http://github.com/benthevining/Oranges/commit/4931d0aa857087c4f03c5943eeac577f67af91e7))

## [1.25.0](http://github.com/benthevining/Oranges/compare/v1.24.0...v1.25.0) (2022-03-19)


### Features

* added a find module for asdf tool manager ([553e449](http://github.com/benthevining/Oranges/commit/553e44924e06bc46b8c63c980e056ff1e03415fa))

## [1.24.0](http://github.com/benthevining/Oranges/compare/v1.23.0...v1.24.0) (2022-03-19)


### Features

* added a list transform function ([5b93c0c](http://github.com/benthevining/Oranges/commit/5b93c0cb64b774040f9422e1dc94ee7231f43cc0))

## [1.23.0](http://github.com/benthevining/Oranges/compare/v1.22.0...v1.23.0) (2022-03-19)


### Features

* added modules to abstract finding various UNIX or Windows shells ([fe0d7ea](http://github.com/benthevining/Oranges/commit/fe0d7ea24233c89d27f8159b9f420d7d2a644caa))

## [1.22.0](http://github.com/benthevining/Oranges/compare/v1.21.0...v1.22.0) (2022-03-19)


### Features

* initial commit of package manager scripts ([996cd9d](http://github.com/benthevining/Oranges/commit/996cd9df242235313ff5897b670e4ae5c4bb771c))

## [1.21.0](http://github.com/benthevining/Oranges/compare/v1.20.0...v1.21.0) (2022-03-19)


### Features

* added scripts for installing dependencies ([ea944db](http://github.com/benthevining/Oranges/commit/ea944db738d57290c9b3f7930c9894a0c9055fda))

## [1.20.0](http://github.com/benthevining/Oranges/compare/v1.19.0...v1.20.0) (2022-03-19)


### Features

* added a module with find module helpers ([87ae127](http://github.com/benthevining/Oranges/commit/87ae127a79695494e8848ffd54bf6d92eed876f3))

## [1.19.0](http://github.com/benthevining/Oranges/compare/v1.18.0...v1.19.0) (2022-03-19)


### Features

* added a module to download and cache single files ([9e71f73](http://github.com/benthevining/Oranges/commit/9e71f73e627904b6f6ac3e91d3fa39aa133afb19))

## [1.18.0](http://github.com/benthevining/Oranges/compare/v1.17.0...v1.18.0) (2022-03-18)


### Features

* added a find module for auval ([f3a32f0](http://github.com/benthevining/Oranges/commit/f3a32f0b5fcc2f23254d56d17f27c398c03b08f1))

## [1.17.0](http://github.com/benthevining/Oranges/compare/v1.16.0...v1.17.0) (2022-03-15)


### Features

* bumping version in CMakeLists.txt with semantic release ([273e5b7](http://github.com/benthevining/Oranges/commit/273e5b72a29f6404342aaa69f17ce5549cf850a7))


### Bug Fixes

* installing extra deps for semantic release ([8023be6](http://github.com/benthevining/Oranges/commit/8023be652eeddde971373f9c1ba083fd3c903509))

## [1.16.0](http://github.com/benthevining/Oranges/compare/v1.15.1...v1.16.0) (2022-03-15)


### Features

* added find modules for system package managers ([bbde11c](http://github.com/benthevining/Oranges/commit/bbde11c754e48d0ae389d816d525e8f3c8537620))

### [1.15.1](http://github.com/benthevining/Oranges/compare/v1.15.0...v1.15.1) (2022-03-09)


### Bug Fixes

* errors with exporting dependency targets from find modules ([2a27e69](http://github.com/benthevining/Oranges/commit/2a27e691d732cf245925f692985cc81ccef43c53))

## [1.15.0](http://github.com/benthevining/Oranges/compare/v1.14.0...v1.15.0) (2022-03-09)


### Features

* added a new helper macro for adding header files with install rules to a target ([e2655c5](http://github.com/benthevining/Oranges/commit/e2655c50f6e719e1cacbabb32520c7b54106e73f))

## [1.14.0](http://github.com/benthevining/Oranges/compare/v1.13.1...v1.14.0) (2022-03-09)


### Features

* added a FindPluginval module ([4a85247](http://github.com/benthevining/Oranges/commit/4a85247efd62d6dc599f92c5a08a2cdd32b874b3))

### [1.13.1](http://github.com/benthevining/Oranges/compare/v1.13.0...v1.13.1) (2022-03-09)


### Bug Fixes

* fixed bug with variable propagation in oranges_fetch_repository ([bb44cef](http://github.com/benthevining/Oranges/commit/bb44cefa63e2cff9a4e797084657acf9d88f81c4))

## [1.13.0](http://github.com/benthevining/Oranges/compare/v1.12.0...v1.13.0) (2022-03-08)


### Features

* added a FetchContent wrapper module ([3091b7a](http://github.com/benthevining/Oranges/commit/3091b7abc13465de92c2629967e705212e6df652))

## [1.12.0](http://github.com/benthevining/Oranges/compare/v1.11.3...v1.12.0) (2022-03-08)


### Features

* added a module to automatically generate pkgconfig manifest files ([5e94a82](http://github.com/benthevining/Oranges/commit/5e94a822b006cc0dc5b12aac84556599fe2e5672))

### [1.11.3](http://github.com/benthevining/Oranges/compare/v1.11.2...v1.11.3) (2022-03-07)


### Bug Fixes

* more generator expression errors ([12e6c8e](http://github.com/benthevining/Oranges/commit/12e6c8e4c29b3d9108e221c43f955fe7543c5e95))

### [1.11.2](http://github.com/benthevining/Oranges/compare/v1.11.1...v1.11.2) (2022-03-07)


### Bug Fixes

* fixing bugs in generator expressions ([60093dd](http://github.com/benthevining/Oranges/commit/60093dd81ff0a659aa129809c0cf563b1dc7f04b))

### [1.11.1](http://github.com/benthevining/Oranges/compare/v1.11.0...v1.11.1) (2022-03-07)


### Bug Fixes

* bug fixes with incorporating docs modules into containing project ([fb1588d](http://github.com/benthevining/Oranges/commit/fb1588dadcb7b824be6d66c0b1a7d94b8d58e77b))

## [1.11.0](http://github.com/benthevining/Oranges/compare/v1.10.0...v1.11.0) (2022-03-07)


### Features

* added a script to automatically query the cmake file API ([3624342](http://github.com/benthevining/Oranges/commit/3624342887fa7705d511a09796ae40032099311e))

## [1.10.0](http://github.com/benthevining/Oranges/compare/v1.9.0...v1.10.0) (2022-03-07)


### Features

* added toolchains for tvOS and watchOS ([050830d](http://github.com/benthevining/Oranges/commit/050830d91f225e1c67da907b5081066037f9bd34))

## [1.9.0](http://github.com/benthevining/Oranges/compare/v1.8.0...v1.9.0) (2022-03-07)


### Features

* added Doxygen layout file and step to copy deps graph image to source tree ([e39904c](http://github.com/benthevining/Oranges/commit/e39904ca8de646f64bf70c26c37a7d03869b9c4b))


### Bug Fixes

* don't fail with error if Doxygen can't be found ([33c1a4c](http://github.com/benthevining/Oranges/commit/33c1a4c3c38e04a1886ce8efeb42e36bdcebcd29))

## [1.8.0](http://github.com/benthevining/Oranges/compare/v1.7.0...v1.8.0) (2022-03-06)


### Features

* added graphviz dependency graph integration ([d38efd2](http://github.com/benthevining/Oranges/commit/d38efd289b71a7414e70844826d9b53be69e5dea))

## [1.7.0](http://github.com/benthevining/Oranges/compare/v1.6.0...v1.7.0) (2022-03-06)


### Features

* added a cmake module to create a default docs target ([75ba1fc](http://github.com/benthevining/Oranges/commit/75ba1fcb9413787834a8fc63fabf22a793c8afce))
* cpack settings module now creates a default CPackConfig file as well ([8801eec](http://github.com/benthevining/Oranges/commit/8801eec5935528140da3044737ec40b318753417))
* set up documentation build targets ([c106e1e](http://github.com/benthevining/Oranges/commit/c106e1e06332000f30c6e1e853c5c6f7983f1e3e))


### Bug Fixes

* not failing with an error if Doxygen cannot be found ([c6d6e07](http://github.com/benthevining/Oranges/commit/c6d6e07be4d390e19b603a9c0e94104dccd3dec1))

## [1.6.0](http://github.com/benthevining/Oranges/compare/v1.5.0...v1.6.0) (2022-03-06)


### Features

* added a module for library ABI control features ([976aa97](http://github.com/benthevining/Oranges/commit/976aa97a10c3a9805a072eab1fd527235db55bde))

## [1.5.0](http://github.com/benthevining/Oranges/compare/v1.4.1...v1.5.0) (2022-03-06)


### Features

* added more toolchain files ([a59dd78](http://github.com/benthevining/Oranges/commit/a59dd78ee45d6d1cc6099d22a4e870c5620b088f))

### [1.4.1](http://github.com/benthevining/Oranges/compare/v1.4.0...v1.4.1) (2022-03-06)


### Bug Fixes

* makefile bug on Windows ([9b54419](http://github.com/benthevining/Oranges/commit/9b544197e408f3b7af931a366159c3fbe45f1b34))

## [1.4.0](http://github.com/benthevining/Oranges/compare/v1.3.5...v1.4.0) (2022-03-06)


### Features

* added an uninstall target module ([ba8c739](http://github.com/benthevining/Oranges/commit/ba8c739d7e11c24c91a70669462e33a4f04bec6c))


### Bug Fixes

* fixing filename casing for Linux ([ab67042](http://github.com/benthevining/Oranges/commit/ab67042c47bd4fffe51085f8caac1fc273381831))

### [1.3.5](http://github.com/benthevining/Oranges/compare/v1.3.4...v1.3.5) (2022-03-06)


### Bug Fixes

* checking for existence of imported targets before creating aliases ([c212793](http://github.com/benthevining/Oranges/commit/c21279366b69b5d3920f97af4b85bbfb80c3954e))

### [1.3.4](http://github.com/benthevining/Oranges/compare/v1.3.3...v1.3.4) (2022-03-06)


### Bug Fixes

* fixed inclusion of target export file from OrangesConfig.cmake ([c30c00a](http://github.com/benthevining/Oranges/commit/c30c00a17309515e0e7f609d7a6aab8fbf75e551))

### [1.3.3](http://github.com/benthevining/Oranges/compare/v1.3.2...v1.3.3) (2022-03-05)


### Bug Fixes

* fixing another install bug ([61e4b2e](http://github.com/benthevining/Oranges/commit/61e4b2eee89a43f5d9b6e8dbf682ed26e3269bc7))

### [1.3.2](http://github.com/benthevining/Oranges/compare/v1.3.1...v1.3.2) (2022-03-05)


### Bug Fixes

* fixed cmake install ([4317cdc](http://github.com/benthevining/Oranges/commit/4317cdc0468528b29d3ebe8c31969ed65fceee6d))

### [1.3.1](http://github.com/benthevining/Oranges/compare/v1.3.0...v1.3.1) (2022-03-05)


### Bug Fixes

* fixed bug with cmake install configuration ([4732200](http://github.com/benthevining/Oranges/commit/47322001bae442a1482ad1414c91584980f6e582))

## [1.3.0](http://github.com/benthevining/Oranges/compare/v1.2.0...v1.3.0) (2022-03-04)


### Features

* added iOS toolchains ([e06dbf5](http://github.com/benthevining/Oranges/commit/e06dbf5390601abce23ddb07a20cf33989da082e))

## [1.2.0](http://github.com/benthevining/Oranges/compare/v1.1.0...v1.2.0) (2022-03-04)


### Features

* added find modules for MTS-ESP, MIPP, and JUCE ([91fff70](http://github.com/benthevining/Oranges/commit/91fff70f7a321e400de3f9905c34870a3cb77e09))

## [1.1.0](http://github.com/benthevining/Oranges/compare/v1.0.2...v1.1.0) (2022-03-04)


### Features

* added a find module for Intel IPP ([91ae13a](http://github.com/benthevining/Oranges/commit/91ae13a9bdb8846b4f61a3d2a9de7e11519f570d))

### [1.0.2](http://github.com/benthevining/Oranges/compare/v1.0.1...v1.0.2) (2022-02-27)


### Bug Fixes

* not automatically enabling ccache ([f5a9112](http://github.com/benthevining/Oranges/commit/f5a9112e0853a0957afd853e743f2ecf4cb06f17))

### [1.0.1](http://github.com/benthevining/Oranges/compare/v1.0.0...v1.0.1) (2022-02-27)


### Bug Fixes

* fixing bug with ccache ([891a5f5](http://github.com/benthevining/Oranges/commit/891a5f598ad0b4612ba7572888bfd3d848ced811))

## 1.0.0 (2022-02-25)


### Features

* initial commit ([1fd120e](http://github.com/benthevining/Oranges/commit/1fd120e3fb701a7fe27bada339cf5afb90e8c777))
