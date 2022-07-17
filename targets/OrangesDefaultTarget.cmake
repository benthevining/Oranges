# ======================================================================================
#    ____  _____            _   _  _____ ______  _____
#   / __ \|  __ \     /\   | \ | |/ ____|  ____|/ ____|
#  | |  | | |__) |   /  \  |  \| | |  __| |__  | (___
#  | |  | |  _  /   / /\ \ | . ` | | |_ |  __|  \___ \
#  | |__| | | \ \  / ____ \| |\  | |__| | |____ ____) |
#   \____/|_|  \_\/_/    \_\_| \_|\_____|______|_____/
#
#  This file is part of the Oranges open source CMake library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

#[=======================================================================[.rst:

OrangesDefaultTarget
-------------------------

Provides a helper "default target" with some sensible defaults configured.


Targets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``Oranges::OrangesDefaultTarget``

A default target with some basic boilerplate settings configured, that links against :doc:`OrangesOptimizationFlags`, :doc:`OrangesDefaultWarnings`, and :doc:`OrangesDebugTarget` (the latter, in debug configurations only).


``Oranges::OrangesDefaultCXXTarget``

Links to ``OrangesDefaultTarget``, but also has some default C++ compile features added.
The C++ standard used by this target is C++20, and it has exceptions and RTTI enabled by default.
This target also has default symbol visibility control settings enabled; for building libraries, I recommend you link against this target and then create an export header with :command:`oranges_generate_export_header`.


Target properties
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``ORANGES_USING_INSTALLED_PACKAGE``

For any target that links against ``OrangesDefaultTarget``, this property will be defined to ``TRUE`` if it was linked to from an installed package, and ``FALSE`` if it is being built from source.
This property will (probably) be undefined for any target that does not link against ``OrangesDefaultTarget``.


.. seealso ::

    Target :doc:`OrangesDebugTarget`
        A helper target that just enables debugging flags. ``OrangesDefaultTarget`` links to this by default in all debug configurations.

    Target :doc:`OrangesOptimizationFlags`
        A helper target that enables various configuration-aware optimization flags. ``OrangesDefaultTarget`` links to this by default.

    Target :doc:`OrangesDefaultWarnings`
        A helper target that defines some default warning flags. ``OrangesDefaultTarget`` links to this by default.

#]=======================================================================]

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

include (FeatureSummary)
include (OrangesGeneratePlatformHeader)
include (OrangesDebugTarget)
include (OrangesOptimizationFlags)
include (OrangesDefaultWarnings)

#

if (PLAT_LINUX)
    set (CMAKE_AR "${CMAKE_CXX_COMPILER_AR}")
    set (CMAKE_RANLIB "${CMAKE_CXX_COMPILER_RANLIB}")

    include (LinuxLSBInfo)
endif ()

#

define_property (
    TARGET INHERITED
    PROPERTY ORANGES_USING_INSTALLED_PACKAGE
    BRIEF_DOCS
        "TRUE if this target has been linked to from outside the original build tree; otherwise FALSE"
    FULL_DOCS
        "Boolean indicator of whether this target is being consumed downstream as an installed version"
    )

#

add_library (OrangesDefaultTarget INTERFACE)

set_target_properties (
    OrangesDefaultTarget
    PROPERTIES C_EXTENSIONS OFF
               CXX_EXTENSIONS OFF
               EXPORT_COMPILE_COMMANDS ON
               OPTIMIZE_DEPENDENCIES ON
               PCH_WARN_INVALID ON
               PCH_INSTANTIATE_TEMPLATES ON
               VISIBILITY_INLINES_HIDDEN ON
               DEBUG_POSTFIX -d
               MINSIZEREL_POSTFIX -rm
               RELEASE_POSTFIX -r
               RELWITHDEBINFO_POSTFIX -rd
               $<BUILD_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE FALSE>
               $<INSTALL_INTERFACE:ORANGES_USING_INSTALLED_PACKAGE TRUE>)

set_property (TARGET OrangesDefaultTarget APPEND PROPERTY EXPORT_PROPERTIES
                                                          ORANGES_USING_INSTALLED_PACKAGE)

get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

if (NOT debug_configs)
    set (debug_configs Debug)
endif ()

set (config_is_debug "$<IN_LIST:$<CONFIG>,${debug_configs}>")

unset (debug_configs)

set (config_is_release "$<NOT:${config_is_debug}>")

target_link_libraries (
    OrangesDefaultTarget
    INTERFACE "$<BUILD_INTERFACE:$<${config_is_debug}:Oranges::OrangesDebugTarget>>"
              Oranges::OrangesOptimizationFlags Oranges::OrangesDefaultWarnings)

#

set (windowsDefs # cmake-format: sortable
                 _CRT_SECURE_NO_WARNINGS NOMINMAX STRICT UNICODE)

target_compile_definitions (OrangesDefaultTarget
                            INTERFACE "$<$<PLATFORM_ID:Windows>:${windowsDefs}>")

unset (windowsDefs)

set (compiler_intel "$<CXX_COMPILER_ID:Intel,IntelLLVM>")

set (intel_opts "$<IF:$<PLATFORM_ID:Windows>,/Gm,-multiple-processes=4;-static-intel>")

target_compile_options (
    OrangesDefaultTarget
    INTERFACE "$<$<CXX_COMPILER_ID:MSVC>:/MP;/wd4068;/wd4464;/wd4514;/wd4626;/wd4625;/wd5027>"
              "$<$<AND:$<PLATFORM_ID:Windows>,$<CXX_COMPILER_ID:GNU>>:-municode;-mwin32>"
              "$<${compiler_intel}:${intel_opts}>"
              "$<$<AND:$<CXX_COMPILER_ID:GNU,Clang,AppleClang>,$<NOT:$<CONFIG:MINSIZEREL>>>:-g>"
              "$<$<CXX_COMPILER_ID:GNU,Clang,AppleClang>:-fmessage-length=0>"
              "$<$<CXX_COMPILER_ID:GNU>:-march=native>"
              "$<$<AND:$<CXX_COMPILER_ID:GNU>,$<PLATFORM_ID:Android>>:-mandroid>")

unset (intel_opts)

set_target_properties (OrangesDefaultTarget PROPERTIES MSVC_RUNTIME_LIBRARY
                                                       "MultiThreaded$<${config_is_debug}:Debug>")

# add colors to clang output when using Ninja
if (UNIX AND "${CMAKE_GENERATOR}" MATCHES "Ninja")
    target_compile_options (OrangesDefaultTarget
                            INTERFACE "$<$<CXX_COMPILER_ID:Clang>:-fcolor-diagnostics>")
endif ()

#

set (ios_like "$<IN_LIST:$<PLATFORM_ID>,iOS;tvOS;watchOS>")

set (sign_id "\"iPhone Developer\"")

set_target_properties (
    OrangesDefaultTarget
    PROPERTIES $<$<NOT:$<OR:$<PLATFORM_ID:Darwin>,${ios_like}>>:INSTALL_RPATH $ORIGIN>
               XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
               XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}"
               $<${ios_like}:ARCHIVE_OUTPUT_DIRECTORY ./>
               $<${ios_like}:XCODE_ATTRIBUTE_INSTALL_PATH $(LOCAL_APPS_DIR)>
               $<${ios_like}:XCODE_ATTRIBUTE_SKIP_INSTALL NO>
               $<${ios_like}:XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH NO>
               $<${ios_like}:IOS_INSTALL_COMBINED ON>
               $<${ios_like}:XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ${sign_id}>)

unset (sign_id)
unset (ios_like)

#

add_library (Oranges::OrangesDefaultTarget ALIAS OrangesDefaultTarget)

#

add_library (OrangesDefaultCXXTarget INTERFACE)

set_target_properties (
    OrangesDefaultCXXTarget
    PROPERTIES CXX_STANDARD 20
               CXX_STANDARD_REQUIRED ON
               CXX_EXTENSIONS OFF
               CXX_VISIBILITY_PRESET hidden
               VISIBILITY_INLINES_HIDDEN TRUE)

target_link_libraries (OrangesDefaultCXXTarget INTERFACE Oranges::OrangesDefaultTarget)

# all known C++ features, please
target_compile_features (OrangesDefaultCXXTarget INTERFACE ${CMAKE_CXX_COMPILE_FEATURES})

set (intel_opts "$<IF:$<PLATFORM_ID:Windows>,/GR;/EHsc,-fexceptions>")

# cmake-format: off
target_compile_options (
    OrangesDefaultCXXTarget
    INTERFACE "$<$<CXX_COMPILER_ID:MSVC>:/EHsc>"
              "$<$<CXX_COMPILER_ID:GNU>:-fconcepts>"
              "$<$<CXX_COMPILER_ID:Clang,AppleClang>:-fcxx-exceptions>"
              "$<${compiler_intel}:${intel_opts}>"
              $<$<CXX_COMPILER_ID:Cray>:-h exceptions>
              "$<$<CXX_COMPILER_ID:GNU,AppleClang>:-frtti>"
              # for some reason, RTTI is broken on Windows Clang
              "$<$<AND:$<CXX_COMPILER_ID:Clang>,$<NOT:$<PLATFORM_ID:Windows>>>:-frtti>"
              )
# cmake-format: on

unset (intel_opts)
unset (compiler_intel)

unset (config_is_debug)
unset (config_is_release)

add_library (Oranges::OrangesDefaultCXXTarget ALIAS OrangesDefaultCXXTarget)

install (TARGETS OrangesDefaultTarget OrangesDefaultCXXTarget EXPORT OrangesTargets)
