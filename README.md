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
![Lines of code](https://img.shields.io/tokei/lines/github/benthevining/Oranges)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/benthevining/Oranges)
![GitHub Release Date](https://img.shields.io/github/release-date/benthevining/Oranges)
![GitHub release](https://img.shields.io/github/v/release/benthevining/Oranges)
![GitHub Sponsors](https://img.shields.io/github/sponsors/benthevining?style=social)
![GitHub Repo stars](https://img.shields.io/github/stars/benthevining/Oranges?style=social)
![GitHub followers](https://img.shields.io/github/followers/benthevining?style=social)

A library of CMake modules.

For quick CLI reference, run the `help.py` script in the `help/` directory.

## What's here

### Oranges provides the following CMake modules:

Code generation
  * OrangesGenerateBuildTypeHeader
  * OrangesGenerateExportHeader
  * OrangesGeneratePlatformHeader
  * OrangesGenerateStandardHeaders

Dependencies
  * OrangesDownloadFile
  * OrangesFetchRepository
  * OrangesWipeCacheTarget
  * OrangesWrapAutotoolsProject

Documentation
  * OrangesDocsBuildConfig
  * OrangesDoxygenConfig
  * OrangesGeneratePropertiesJSON
  * OrangesGraphVizConfig

General
  * LinuxLSBInfo
  * OrangesSourceFileUtils

Helper targets
  * CXXConcepts
  * OrangesAllIntegrations
  * OrangesCoverageFlags
  * OrangesDefaultTarget
  * OrangesDefaultWarnings
  * OrangesUnityBuild

Installing
  * OrangesDefaultCPackSettings
  * OrangesGeneratePkgConfig
  * OrangesInstallSystemLibs
  * OrangesSetDefaultCpackGenerator
  * OrangesUninstallTarget

Juce
  * OrangesAppUtilities
  * OrangesAssetsHelpers
  * OrangesJuceModuleUtilities
  * OrangesJuceUtilities

Plugins
  * CallForEachPluginFormat
  * OrangesAAXUtils
  * OrangesAddPrivateSDKs
  * OrangesClapFormat
  * OrangesCreateAAXSDKTarget
  * OrangesPluginUtilities

### Oranges provides the following find modules:

Code signing
  * Findcodesign
  * Findwraptool

Fftw
  * FindFFTW
  * Findfftw3
  * Findfftw3f

Libs
  * FindAbletonLink
  * FindAccelerate
  * FindIPP
  * FindJUCE
  * FindMIPP
  * FindMTS-ESP

Programs
  * Findccache
  * Finddot
  * Findfaust
  * Findxcodebuild

Static analysis
  * Findclang-tidy
  * Findcppcheck
  * Findcpplint
  * Findinclude-what-you-use

Testing
  * Findauval
  * Findpluginval

## Using Oranges

Even though Oranges is a library of CMake modules, it is fully usable as an installable package.
You can run `cmake --install`, and then call `find_package (Oranges)` from any consuming CMake project.

If your project depends on Oranges, I recommend copying the `FindOranges` script from the `scripts/` directory into your project's source tree (and adding its location to the `CMAKE_MODULE_PATH` before calling `find_package (Oranges)`), so that if your project is built on a system where Oranges hasn't been installed, it can still be fetched at configure-time.
See the `FindOranges` file for more documentation on what it does.

## CMake install components
  * oranges_modules
  * oranges_docs
  * oranges - installs all Oranges components

## Dependency graph

<p align="center">
  <img src="https://github.com/benthevining/Oranges/blob/main/util/deps_graph.png" alt="Oranges dependency graph"/>
</p>
