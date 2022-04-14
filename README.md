<!-- markdownlint-disable first-line-h1 -->
<!-- editorconfig-checker-disable -->
<!-- markdownlint-disable fenced-code-language -->
```
   ____  _____            _   _  _____ ______  _____
  / __ \|  __ \     /\   | \ | |/ ____|  ____|/ ____|
 | |  | | |__) |   /  \  |  \| | |  __| |__  | (___
 | |  | |  _  /   / /\ \ | . ` | | |_ |  __|  \___ \
 | |__| | | \ \  / ____ \| |\  | |__| | |____ ____) |
  \____/|_|  \_\/_/    \_\_| \_|\_____|______|_____/
```
<!-- markdownlint-enable fenced-code-language -->
<!-- editorconfig-checker-enable -->

[![Create release](https://github.com/benthevining/Oranges/actions/workflows/release.yml/badge.svg)](https://github.com/benthevining/Oranges/actions/workflows/release.yml)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/benthevining/Oranges/main.svg)](https://results.pre-commit.ci/latest/github/benthevining/Oranges/main)
[![semantic-release: conventionalcommits](https://img.shields.io/badge/semantic--release-conventionalcommits-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)

A library of CMake modules, scripts, and toolchains.

For quick CLI reference, run the `help.py` script in the `help/` directory.

## What's here

### Oranges provides the following CMake modules

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
* OrangesGraphVizConfig

General

* LinuxLSBInfo
* OrangesDefaultProjectSettings
* OrangesFileUtils
* OrangesListUtils

Helper targets

* OrangesAllIntegrations
* OrangesCoverageFlags
* OrangesDefaultTarget
* OrangesDefaultWarnings
* OrangesUnityBuild

Installing

* OrangesDefaultCPackSettings
* OrangesDefaultInstallSettings
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

### Oranges provides the following find modules

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
* Findxcodebuild

Static analysis

* Findclang-tidy
* Findcppcheck
* Findcpplint
* Findinclude-what-you-use

Testing

* Findauval
* Findpluginval

## Dependency graph

<!-- editorconfig-checker-disable -->
<p align="center">
  <img src="https://github.com/benthevining/Oranges/blob/main/util/deps_graph.png" alt="Oranges dependency graph"/>
</p>
<!-- editorconfig-checker-enable -->
