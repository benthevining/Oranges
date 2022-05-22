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

  * [CallForEachPluginFormat](modules/juce/plugins/CallForEachPluginFormat.cmake)
  * [LinuxLSBInfo](modules/general/LinuxLSBInfo.cmake)
  * [OrangesAAXUtils](modules/juce/plugins/OrangesAAXUtils.cmake)
  * [OrangesAddPrivateSDKs](modules/juce/plugins/OrangesAddPrivateSDKs.cmake)
  * [OrangesAppUtilities](modules/juce/OrangesAppUtilities.cmake)
  * [OrangesAssetsHelpers](modules/juce/OrangesAssetsHelpers.cmake)
  * [OrangesBuildTypeMacros](modules/general/OrangesBuildTypeMacros.cmake)
  * [OrangesCcache](modules/helper_targets/OrangesCcache.cmake)
  * [OrangesClangTidy](modules/helper_targets/static_analysis/OrangesClangTidy.cmake)
  * [OrangesClapFormat](modules/juce/plugins/OrangesClapFormat.cmake)
  * [OrangesCppcheck](modules/helper_targets/static_analysis/OrangesCppcheck.cmake)
  * [OrangesCpplint](modules/helper_targets/static_analysis/OrangesCpplint.cmake)
  * [OrangesCreateAAXSDKTarget](modules/juce/plugins/OrangesCreateAAXSDKTarget.cmake)
  * [OrangesDebugTarget](modules/helper_targets/OrangesDebugTarget.cmake)
  * [OrangesDefaultCPackSettings](modules/installing/OrangesDefaultCPackSettings.cmake)
  * [OrangesDefaultTarget](modules/helper_targets/OrangesDefaultTarget.cmake)
  * [OrangesDefaultWarnings](modules/helper_targets/OrangesDefaultWarnings.cmake)
  * [OrangesDoxygenConfig](modules/documentation/OrangesDoxygenConfig.cmake)
  * [OrangesFetchRepository](modules/dependencies/OrangesFetchRepository.cmake)
  * [OrangesGenerateExportHeader](modules/code_generation/OrangesGenerateExportHeader.cmake)
  * [OrangesGeneratePkgConfig](modules/installing/OrangesGeneratePkgConfig.cmake)
  * [OrangesGeneratePlatformHeader](modules/code_generation/OrangesGeneratePlatformHeader.cmake)
  * [OrangesGenerateStandardHeaders](modules/code_generation/OrangesGenerateStandardHeaders.cmake)
  * [OrangesGraphviz](modules/documentation/OrangesGraphviz.cmake)
  * [OrangesIPO](modules/helper_targets/OrangesIPO.cmake)
  * [OrangesIWYU](modules/helper_targets/static_analysis/OrangesIWYU.cmake)
  * [OrangesInstallSystemLibs](modules/installing/OrangesInstallSystemLibs.cmake)
  * [OrangesJuceUtilities](modules/juce/OrangesJuceUtilities.cmake)
  * [OrangesOptimizationFlags](modules/helper_targets/OrangesOptimizationFlags.cmake)
  * [OrangesPluginUtilities](modules/juce/plugins/OrangesPluginUtilities.cmake)
  * [OrangesSWIG](modules/code_generation/OrangesSWIG.cmake)
  * [OrangesSetDefaultCpackGenerator](modules/installing/OrangesSetDefaultCpackGenerator.cmake)
  * [OrangesSourceFileUtils](modules/general/OrangesSourceFileUtils.cmake)
  * [OrangesSphinx](modules/documentation/OrangesSphinx.cmake)
  * [OrangesStaticAnalysis](modules/helper_targets/static_analysis/OrangesStaticAnalysis.cmake)
  * [OrangesUninstallTarget](modules/installing/OrangesUninstallTarget.cmake)
  * [OrangesUnityBuild](modules/helper_targets/OrangesUnityBuild.cmake)
  * [OrangesWipeCacheTarget](modules/dependencies/OrangesWipeCacheTarget.cmake)
  * [OrangesWrapAutotoolsProject](modules/dependencies/OrangesWrapAutotoolsProject.cmake)
  * [UseFaust](modules/code_generation/UseFaust.cmake)
  * [Usecodesign](modules/code_signing/Usecodesign.cmake)
  * [Usewraptool](modules/code_signing/Usewraptool.cmake)
  * [Usexcodebuild](modules/general/Usexcodebuild.cmake)

### Oranges provides the following find modules:

  * [FindAbletonLink](modules/finders/libs/FindAbletonLink.cmake)
  * [FindAccelerate](modules/finders/libs/FindAccelerate.cmake)
  * [FindFFTW](modules/finders/libs/FFTW/FindFFTW.cmake)
  * [FindIPP](modules/finders/libs/FindIPP.cmake)
  * [FindJUCE](modules/finders/libs/FindJUCE.cmake)
  * [FindMIPP](modules/finders/libs/FindMIPP.cmake)
  * [FindMTS-ESP](modules/finders/libs/FindMTS-ESP.cmake)
  * [Findfftw3](modules/finders/libs/FFTW/Findfftw3.cmake)
  * [Findfftw3f](modules/finders/libs/FFTW/Findfftw3f.cmake)
  * [Findpluginval](modules/finders/testing/Findpluginval.cmake)

## Using Oranges

When you bring Oranges into your build (either through ``add_subdirectory()`` or ``find_package()``), it does not include every module Oranges ships. You should manually ``include()`` each module you want to use.

Even though Oranges is a library of CMake modules, it is fully usable as an installable package.
You can run ``cmake --install``, and then call ``find_package (Oranges)`` from any consuming CMake project.

If your project depends on Oranges, I recommend copying the ``FindOranges`` script from the ``scripts/`` directory into your project's source tree (and adding its location to the ``CMAKE_MODULE_PATH`` before calling ``find_package (Oranges)``), so that if your project is built on a system where Oranges hasn't been installed, it can still be fetched at configure-time.
See the [``FindOranges``](scripts/FindOranges.cmake) file for more documentation on what it does.

### CMake options

Oranges modules define options of their own, which are only relevant if you include those modules. See each module for details on its options and cache variables.

These options are defined by the top-level Oranges project itself:

* ``ORANGES_BUILD_DOCS``

Builds the Oranges documentation. Defaults to OFF if the Oranges project is not the top-level directory CMake was invoked in. Building the docs requires Python 3.9 and Sphinx.

* ``ORANGES_SPHINX_FLAGS``

When building the documentation, this can contain a space-separated list of flags that will be passed to the Sphinx executable while building each documentation format.
Empty by default.

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
