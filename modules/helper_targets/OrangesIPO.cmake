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

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.22 FATAL_ERROR)

if (TARGET Oranges::OrangesIPO)
    return ()
endif ()

add_library (OrangesIPO INTERFACE)

set_target_properties (OrangesIPO PROPERTIES INTERPROCEDURAL_OPTIMIZATION OFF)

# if (NOT DEFINED CMAKE_INTERPROCEDURAL_OPTIMIZATION) include (CheckIPOSupported)

# check_ipo_supported (RESULT CMAKE_INTERPROCEDURAL_OPTIMIZATION) endif ()

# if (CMAKE_INTERPROCEDURAL_OPTIMIZATION)

# set (clangAndLinux "$<AND:$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Linux>>")

# # cmake-format: off set_target_properties ( OrangesIPO PROPERTIES
# $<BUILD_INTERFACE:$<$<NOT:${clangAndLinux}>:INTERPROCEDURAL_OPTIMIZATION ON>>
# $<BUILD_INTERFACE:$<${clangAndLinux}:INTERPROCEDURAL_OPTIMIZATION OFF>>) else ()
# set_target_properties (OrangesIPO PROPERTIES $<BUILD_INTERFACE:INTERPROCEDURAL_OPTIMIZATION OFF>)
# # cmake-format: on endif ()

# get_property (debug_configs GLOBAL PROPERTY DEBUG_CONFIGURATIONS)

# if (NOT debug_configs) set (debug_configs Debug) endif ()

# foreach (config IN LISTS debug_configs) string (TOUPPER "${config}" config)

# set_target_properties (OrangesIPO PROPERTIES
# $<BUILD_INTERFACE:INTERPROCEDURAL_OPTIMIZATION_${config} OFF>) endforeach ()

install (TARGETS OrangesIPO EXPORT OrangesTargets)

add_library (Oranges::OrangesIPO ALIAS OrangesIPO)
