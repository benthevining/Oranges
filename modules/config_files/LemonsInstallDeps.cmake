# ======================================================================================
#
#  ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗███████╗
#  ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██╔════╝
#  ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████╗
#  ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║╚════██║
#  ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║███████║
#  ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
#
#  This file is part of the Lemons open source library and is licensed under the terms of the GNU Public License.
#
# ======================================================================================

include_guard (GLOBAL)

cmake_minimum_required (VERSION 3.21 FATAL_ERROR)

include (LemonsJsonUtils)
include (LemonsFileUtils)

set (lemons_install_scripts_dir "${CMAKE_CURRENT_LIST_DIR}/scripts" CACHE INTERNAL "")

if(APPLE)
	include (${lemons_install_scripts_dir}/install_mac.cmake)
elseif(WIN32)
	include (${lemons_install_scripts_dir}/install_win.cmake)
else()
	include (${lemons_install_scripts_dir}/install_linux.cmake)
endif()

option (LEMONS_DEPS_UPDATE_ALL_FIRST
		"Whether to update all installed system packages before installing additional dependencies"
		OFF)

if(LEMONS_DEPS_UPDATE_ALL_FIRST)
	_lemons_deps_os_update_func ()
endif()

#

function(lemons_get_list_of_deps_to_install)

	function(_lemons_deps_get_category_with_name rootJsonObj catName outVar)

		string (JSON numCategories LENGTH ${rootJsonObj} "Dependencies")

		math (EXPR numCategories "${numCategories} - 1" OUTPUT_FORMAT DECIMAL)

		foreach(idx RANGE ${numCategories})
			string (
				JSON
				cat_name
				GET
				${rootJsonObj}
				"Dependencies"
				${idx}
				"name")

			if("${cat_name}" STREQUAL "${catName}")
				string (JSON cat_obj GET ${rootJsonObj} "Dependencies" ${idx})
				set (${outVar} "${cat_obj}" PARENT_SCOPE)
				return ()
			endif()
		endforeach()

	endfunction()

	#

	function(_lemons_deps_add_from_category rootJsonObj catJsonObj sysOutVar pyOutVar)

		lemons_json_array_to_list (TEXT "${catJsonObj}" ARRAY "packages" OUT sysPackages)

		# check for dependencies on other categories

		lemons_json_array_to_list (TEXT "${catJsonObj}" ARRAY "categories" OUT subCats)

		if(subCats)
			foreach(subcategory ${subCats})

				_lemons_deps_get_category_with_name ("${rootJsonObj}" ${subcategory} subcatObj)

				if(subcatObj)
					_lemons_deps_add_from_category ("${rootJsonObj}" "${subcatObj}" sys py)

					list (APPEND sysPackages ${sys})
					list (APPEND pyPackages ${py})
				else()
					message (AUTHOR_WARNING "Category dependency ${subcategory} not found!")
				endif()
			endforeach()
		endif()

		# check for OS-specific packages

		if(APPLE)
			set (osCatName "MacPackages")
		elseif(WIN32)
			set (osCatName "WindowsPackages")
		else()
			set (osCatName "LinuxPackages")
		endif()

		lemons_json_array_to_list (TEXT "${catJsonObj}" ARRAY ${osCatName} OUT osPackages)

		list (APPEND sysPackages ${osPackages})

		# check for Python packages

		lemons_json_array_to_list (TEXT "${catJsonObj}" ARRAY PythonPackages OUT pythonPackages)

		list (APPEND pyPackages ${pythonPackages})

		list (REMOVE_DUPLICATES sysPackages)
		list (REMOVE_DUPLICATES pyPackages)

		set (${sysOutVar} "${sysPackages}" PARENT_SCOPE)
		set (${pyOutVar} "${pyPackages}" PARENT_SCOPE)

	endfunction()

	#

	set (oneValueArgs FILE SYSTEM_OUTPUT PYTHON_OUTPUT)

	cmake_parse_arguments (LEMONS_DEPS "OMIT_DEFAULT" "${oneValueArgs}" "CATEGORIES" ${ARGN})

	if(NOT LEMONS_DEPS_FILE)
		# from global config func...
		if(${PROJECT_NAME}_CONFIG_FILE)
			set (LEMONS_DEPS_FILE ${${PROJECT_NAME}_CONFIG_FILE})
		else()
			message (
				AUTHOR_WARNING
					"FILE not specified in call to ${CMAKE_CURRENT_FUNCTION}, either provide it in this call or call lemons_parse_project_configuration_file in this project first."
				)
		endif()
	endif()

	lemons_require_function_arguments (LEMONS_DEPS SYSTEM_OUTPUT PYTHON_OUTPUT)
	lemons_check_for_unparsed_args (LEMONS_DEPS)

	lemons_make_path_absolute (VAR LEMONS_DEPS_FILE BASE_DIR ${CMAKE_CURRENT_LIST_DIR})

	file (READ ${LEMONS_DEPS_FILE} fileContents)

	string (STRIP "${fileContents}" fileContents)

	string (JSON depsJsonObj GET ${fileContents} "Dependencies")

	if(NOT LEMONS_DEPS_OMIT_DEFAULT)
		_lemons_deps_get_category_with_name ("${fileContents}" Default defaultCatObj)

		if(defaultCatObj)
			_lemons_deps_add_from_category ("${fileContents}" "${defaultCatObj}" sys py)

			list (APPEND sysList ${sys})
			list (APPEND pyList ${py})
		endif()
	endif()

	foreach(category ${LEMONS_DEPS_CATEGORIES})

		_lemons_deps_get_category_with_name ("${fileContents}" ${category} categoryObj)

		if(NOT categoryObj)
			message (AUTHOR_WARNING "Requested category ${category} not found in JSON file!")
			continue ()
		endif()

		_lemons_deps_add_from_category ("${fileContents}" "${categoryObj}" sys py)

		list (APPEND sysList ${sys})
		list (APPEND pyList ${py})
	endforeach()

	list (REMOVE_DUPLICATES sysList)
	list (REMOVE_DUPLICATES pyList)

	set (${LEMONS_DEPS_SYSTEM_OUTPUT} "${sysList}" PARENT_SCOPE)
	set (${LEMONS_DEPS_PYTHON_OUTPUT} "${pyList}" PARENT_SCOPE)

endfunction()

#

function(lemons_install_deps)

	lemons_get_list_of_deps_to_install (SYSTEM_OUTPUT system_deps PYTHON_OUTPUT python_deps ${ARGN})

	if(system_deps)
		_lemons_deps_os_install_func ("${system_deps}")
	else()
		message (STATUS "No dependencies found to install.")
	endif()

	if(python_deps)
		include (${lemons_install_scripts_dir}/install_pips.cmake)

		lemons_install_python_pips (${python_deps})
	else()
		message (STATUS "No Python packages found to install.")
	endif()

endfunction()
