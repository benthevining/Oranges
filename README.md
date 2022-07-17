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
[![Documentation](https://readthedocs.org/projects/oranges/badge/?version=latest)](https://oranges.readthedocs.io/en/latest/?badge=latest)
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

  * [LinuxLSBInfo](modules/general/LinuxLSBInfo.cmake)
  * [OrangesBuildTypeMacros](modules/general/OrangesBuildTypeMacros.cmake)
  * [OrangesCcache](modules/general/OrangesCcache.cmake)
  * [OrangesClangTidy](modules/static_analysis/OrangesClangTidy.cmake)
  * [OrangesCppcheck](modules/static_analysis/OrangesCppcheck.cmake)
  * [OrangesCpplint](modules/static_analysis/OrangesCpplint.cmake)
  * [OrangesDefaultCPackSettings](modules/installing/OrangesDefaultCPackSettings.cmake)
  * [OrangesDoxygenConfig](modules/documentation/OrangesDoxygenConfig.cmake)
  * [OrangesGenerateExportHeader](modules/code_generation/OrangesGenerateExportHeader.cmake)
  * [OrangesGeneratePkgConfig](modules/installing/OrangesGeneratePkgConfig.cmake)
  * [OrangesGeneratePlatformHeader](modules/code_generation/OrangesGeneratePlatformHeader.cmake)
  * [OrangesGenerateStandardHeaders](modules/code_generation/OrangesGenerateStandardHeaders.cmake)
  * [OrangesGraphviz](modules/documentation/OrangesGraphviz.cmake)
  * [OrangesIPO](modules/general/OrangesIPO.cmake)
  * [OrangesIWYU](modules/static_analysis/OrangesIWYU.cmake)
  * [OrangesInstallSystemLibs](modules/installing/OrangesInstallSystemLibs.cmake)
  * [OrangesSetDefaultCpackGenerator](modules/installing/OrangesSetDefaultCpackGenerator.cmake)
  * [OrangesSourceFileUtils](modules/general/OrangesSourceFileUtils.cmake)
  * [OrangesSphinx](modules/documentation/OrangesSphinx.cmake)
  * [OrangesStaticAnalysis](modules/static_analysis/OrangesStaticAnalysis.cmake)
  * [OrangesUninstallTarget](modules/installing/OrangesUninstallTarget.cmake)
  * [OrangesUniversalBinary](modules/general/OrangesUniversalBinary.cmake)
  * [Usecodesign](modules/code_signing/Usecodesign.cmake)
  * [Usewraptool](modules/code_signing/Usewraptool.cmake)
  * [Usexcodebuild](modules/general/Usexcodebuild.cmake)

### Oranges provides the following find modules:

  * [FindAccelerate](modules/finders/FindAccelerate.cmake)
  * [FindFFTW](modules/finders/FFTW/FindFFTW.cmake)
  * [FindIPP](modules/finders/FindIPP.cmake)
  * [FindJUCE](modules/finders/FindJUCE.cmake)
  * [FindMIPP](modules/finders/FindMIPP.cmake)
  * [FindMTS-ESP](modules/finders/FindMTS-ESP.cmake)
  * [FindNE10](modules/finders/FindNE10.cmake)
  * [FindSampleRate](modules/finders/FindSampleRate.cmake)
  * [Findfftw3](modules/finders/FFTW/Findfftw3.cmake)
  * [Findfftw3f](modules/finders/FFTW/Findfftw3f.cmake)
  * [Findpffft](modules/finders/Findpffft.cmake)

## Using Oranges

When you bring Oranges into your build (either through ``add_subdirectory()`` or ``find_package()``), it does not include every module Oranges ships. You should manually ``include()`` each module you want to use.

Even though Oranges is a library of CMake modules, it is fully usable as an installable package.
You can run ``cmake --install``, and then call ``find_package (Oranges)`` from any consuming CMake project.

If your project depends on Oranges, I recommend copying the ``FindOranges`` script from the ``scripts/`` directory into your project's source tree (and adding its location to the ``CMAKE_MODULE_PATH`` before calling ``find_package (Oranges)``), so that if your project is built on a system where Oranges hasn't been installed, it can still be fetched at configure-time.
See the [``FindOranges``](scripts/FindOranges.cmake) file for more documentation on what it does.

### CMake options

Oranges modules define options of their own, which are only relevant if you include those modules. See each module for details on its options and cache variables.

These options are defined by the top-level Oranges project itself:

* ``ORANGES_MAINTAINER_BUILD``

When ``ON``, OrangesDefaultTarget will link to OrangesDefaultWarnings and OrangesStaticAnalysis. ``OFF`` by default.

* ``ORANGES_IOS_DEV_TEAM_ID``

10-character Apple developer ID used to set up code signing on iOS. Initialized by the value of the environment variable APPLE_DEV_ID, if set.

* ``ORANGES_MAC_UNIVERSAL_BINARY``

If true, and the Xcode generator is being used, and running on an M1 Mac, configures generation of universal binaries for both arm64 and x86_64 architectures.

* ``ORANGES_BUILD_DOCS``

Builds the Oranges documentation. Defaults to OFF if the Oranges project is not the top-level directory CMake was invoked in. Building the docs requires Python 3.9 and Sphinx.

* ``ORANGES_SPHINX_FLAGS``

When building the documentation, this can contain a space-separated list of flags that will be passed to the Sphinx executable while building each documentation format.
Empty by default.

### Environment variables

* ``APPLE_DEV_ID``

The 10-character Apple developer ID used to configure code signing on iOS. If set, this initializes the value of the variable ORANGES_IOS_DEV_TEAM_ID.

## CMake install components
* oranges_modules
* oranges_doc_html
* oranges_doc_singlehtml
* oranges_doc_man
* oranges_doc_info
* oranges_doc_pdf
* oranges_docs - installs all Oranges documentation
* oranges - installs all Oranges components

## Dependency graph

<p align="center">
	<img src="https://github.com/benthevining/Oranges/blob/main/util/deps_graph.png" alt="Oranges dependency graph"/>
</p>
