# Oranges changelog

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
