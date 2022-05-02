<!-- markdownlint-disable -->
<!-- editorconfig-checker-disable -->
```
   ____  _____            _   _  _____ ______  _____
  / __ \|  __ \     /\   | \ | |/ ____|  ____|/ ____|
 | |  | | |__) |   /  \  |  \| | |  __| |__  | (___
 | |  | |  _  /   / /\ \ | . ` | | |_ |  __|  \___ \
 | |__| | | \ \  / ____ \| |\  | |__| | |____ ____) |
  \____/|_|  \_\/_/    \_\_| \_|\_____|______|_____/
```

![GitHub top language](https://img.shields.io/github/languages/top/benthevining/Oranges)
[![Create release](https://github.com/benthevining/Oranges/actions/workflows/release.yml/badge.svg)](https://github.com/benthevining/Oranges/actions/workflows/release.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/benthevining/Oranges/main.svg)](https://results.pre-commit.ci/latest/github/benthevining/Oranges/main)
[![semantic-release: conventionalcommits](https://img.shields.io/badge/semantic--release-conventionalcommits-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)
![License](https://img.shields.io/github/license/benthevining/Oranges)
![GitHub repo size](https://img.shields.io/github/repo-size/benthevining/Oranges)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/benthevining/Oranges)
![GitHub Release Date](https://img.shields.io/github/release-date/benthevining/Oranges)
![GitHub release](https://img.shields.io/github/v/release/benthevining/Oranges)
![GitHub Sponsors](https://img.shields.io/github/sponsors/benthevining?style=social)
![GitHub Repo stars](https://img.shields.io/github/stars/benthevining/Oranges?style=social)
![GitHub followers](https://img.shields.io/github/followers/benthevining?style=social)

A library of CMake modules.

## What's here

### Oranges provides the following CMake modules:

  * CXXConcepts
  * CallForEachPluginFormat
  * LinuxLSBInfo
  * OrangesAAXUtils
  * OrangesAddPrivateSDKs
  * OrangesAllIntegrations
  * OrangesAppUtilities
  * OrangesAssetsHelpers
  * OrangesClapFormat
  * OrangesCoverageFlags
  * OrangesCreateAAXSDKTarget
  * OrangesDefaultCPackSettings
  * OrangesDefaultTarget
  * OrangesDefaultWarnings
  * OrangesDocsBuildConfig
  * OrangesDownloadFile
  * OrangesDoxygenConfig
  * OrangesFetchRepository
  * OrangesFindPackageHelpers
  * OrangesGenerateBuildTypeHeader
  * OrangesGenerateExportHeader
  * OrangesGeneratePkgConfig
  * OrangesGeneratePlatformHeader
  * OrangesGeneratePropertiesJSON
  * OrangesGenerateStandardHeaders
  * OrangesGraphVizConfig
  * OrangesInstallSystemLibs
  * OrangesJuceModuleUtilities
  * OrangesJuceUtilities
  * OrangesPluginUtilities
  * OrangesSetDefaultCpackGenerator
  * OrangesSourceFileUtils
  * OrangesUninstallTarget
  * OrangesUnityBuild
  * OrangesWipeCacheTarget
  * OrangesWrapAutotoolsProject
  * UseFaust
  * Usecodesign
  * Usewraptool
  * Usexcodebuild

### Oranges provides the following find modules:

  * FindAbletonLink
  * FindAccelerate
  * FindFFTW
  * FindIPP
  * FindJUCE
  * FindMIPP
  * FindMTS-ESP
  * Findauval
  * Findccache
  * Findclang-tidy
  * Findcodesign
  * Findcppcheck
  * Findcpplint
  * Finddot
  * Findfaust
  * Findfftw3
  * Findfftw3f
  * Findinclude-what-you-use
  * Findpluginval
  * Findwraptool
  * Findxcodebuild

## Using Oranges

Even though Oranges is a library of CMake modules, it is fully usable as an installable package.
You can run `cmake --install`, and then call `find_package (Oranges)` from any consuming CMake project.

If your project depends on Oranges, I recommend copying the `FindOranges` script from the `scripts/` directory into your project's source tree (and adding its location to the `CMAKE_MODULE_PATH` before calling `find_package (Oranges)`), so that if your project is built on a system where Oranges hasn't been installed, it can still be fetched at configure-time.
See the `FindOranges` file for more documentation on what it does.

### CMake options

* ORANGES_BUILD_DOCS

Builds the Oranges documentation. Defaults to OFF if the Oranges project is not the top-level directory CMake was invoked in.

## CMake install components
  * oranges_modules
  * oranges_doc_html
  * oranges_doc_singlehtml
  * oranges_docs - installs all Oranges documentation
  * oranges - installs all Oranges components

## Dependency graph

<p align="center">
  <img src="https://github.com/benthevining/Oranges/blob/main/util/deps_graph.png" alt="Oranges dependency graph"/>
</p>
