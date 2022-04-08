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

cmake_minimum_required (VERSION 3.13 FATAL_ERROR)

project (OrangesDocs DESCRIPTION "Oranges documentation"
		 HOMEPAGE_URL "www.github.com/benthevining/Oranges" LANGUAGES NONE)

if(PROJECT_IS_TOP_LEVEL)
	enable_language (CXX)

	set (ORANGES_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")

	include ("${ORANGES_ROOT_DIR}/scripts/OrangesMacros.cmake")
endif()

include (GNUInstallDirs)

#

# install the command line docs script

file (READ "${CMAKE_CURRENT_LIST_DIR}/../scripts/help.py" help_script_text)

string (REPLACE "script_dir = os.path.dirname(os.path.realpath(__file__))" "" help_script_text
				"${help_script_text}")

string (REPLACE "ORANGES_MODULES_DIR = os.path.join(os.path.dirname(script_dir), \"modules\")"
				"ORANGES_MODULES_DIR = \"${CMAKE_INSTALL_PREFIX}/${ORANGES_INSTALL_DEST}/modules\""
				help_script_text "${help_script_text}")

file (WRITE "${CMAKE_BINARY_DIR}/help.py" "${help_script_text}")

unset (help_script_text)

install (PROGRAMS "${CMAKE_BINARY_DIR}/help.py" TYPE BIN COMPONENT oranges_docs RENAME "oranges")

#

option (SPHINX_MAN "Build man pages with Sphinx" ON)
option (SPHINX_HTML "Build html help with Sphinx" ON)
option (SPHINX_INFO "Build Info manual with Sphinx" OFF)
option (SPHINX_SINGLEHTML "Build html single page help with Sphinx" OFF)
option (SPHINX_LATEXPDF "Build PDF help with Sphinx using LaTeX" OFF)
option (SPHINX_TEXT "Build text help with Sphinx (not installed)" OFF)

find_program (SPHINX_EXECUTABLE NAMES sphinx-build
			  DOC "Sphinx Documentation Builder (sphinx-doc.org)")

set (SPHINX_FLAGS "" CACHE STRING "Flags to pass to sphinx-build")

separate_arguments (sphinx_flags UNIX_COMMAND "${SPHINX_FLAGS}")

mark_as_advanced (
	FORCE
	SPHINX_INFO
	SPHINX_MAN
	SPHINX_HTML
	SPHINX_SINGLEHTML
	SPHINX_LATEXPDF
	SPHINX_TEXT
	SPHINX_FLAGS)

if(NOT
   (SPHINX_INFO # editorconfig-checker-disable-line
	OR SPHINX_MAN
	OR SPHINX_HTML
	OR SPHINX_SINGLEHTML
	OR SPHINX_QTHELP
	OR SPHINX_TEXT
	OR SPHINX_LATEXPDF))
	return ()
elseif(NOT SPHINX_EXECUTABLE)
	if(PROJECT_IS_TOP_LEVEL)
		message (FATAL_ERROR "SPHINX_EXECUTABLE (sphinx-build) is not found!")
	else()
		message (WARNING "SPHINX_EXECUTABLE (sphinx-build) is not found!")
		return ()
	endif()
endif()

#

set (ORANGES_DOCS_BUILD_TREE "${CMAKE_BINARY_DIR}/OrangesDocs")

file (COPY_FILE "${CMAKE_CURRENT_LIST_DIR}/index.rst" "${ORANGES_DOCS_BUILD_TREE}/index.rst")

# Generate .rst files for each module

include (OrangesFileUtils)

lemons_subdir_list (DIR "${ORANGES_ROOT_DIR}/modules" RESULT module_files RECURSE FILES FULL_PATHS)

set (module_rst_template "${CMAKE_CURRENT_LIST_DIR}/module_rst_template.txt")
set (module_rst_output "${ORANGES_DOCS_BUILD_TREE}/modules")

foreach(MODULE_FULL_PATH IN LISTS module_files)
	cmake_path (GET MODULE_FULL_PATH FILENAME moduleName)

	configure_file ("${module_rst_template}" "${module_rst_output}/${moduleName}.rst" @ONLY)
endforeach()

#

# conf_copyright

# set (conf_docs "${Oranges_SOURCE_DIR}/modules")
set (conf_path "${CMAKE_CURRENT_SOURCE_DIR}")
set (conf_version "${Oranges_VERSION_MAJOR}.${Oranges_VERSION_MINOR}.${Oranges_VERSION_PATCH}")

configure_file (conf.py conf.py @ONLY)

set (doc_formats "")

if(SPHINX_HTML)
	list (APPEND doc_formats html)

	# we provide the path to the produced html output in the console for tools that support URI
	# protocol schemes
	set (
		html_extra_commands
		COMMAND "${CMAKE_COMMAND}" -E echo
		"sphinx-build html: HTML documentation generated in file://${CMAKE_CURRENT_BINARY_DIR}/html/index.html"
		)
endif()

if(SPHINX_MAN)
	list (APPEND doc_formats man)
endif()

if(SPHINX_SINGLEHTML)
	list (APPEND doc_formats singlehtml)
endif()

if(SPHINX_TEXT)
	list (APPEND doc_formats text)
endif()

if(SPHINX_INFO)
	find_program (MAKEINFO_EXECUTABLE NAMES makeinfo DOC "makeinfo tool")

	if(MAKEINFO_EXECUTABLE)
		list (APPEND doc_formats texinfo)

		# Sphinx texinfo builder supports .info, .txt, .html and .pdf output. SPHINX_INFO controls
		# the .info output.
		set (
			texinfo_extra_commands
			COMMAND "${MAKEINFO_EXECUTABLE}" --no-split -o
			"${CMAKE_CURRENT_BINARY_DIR}/texinfo/oranges.info"
			"${CMAKE_CURRENT_BINARY_DIR}/texinfo/oranges.texi")
	else()
		message (WARNING "MAKEINFO_EXECUTABLE (makeinfo) not found!")
	endif()
endif()

if(SPHINX_LATEXPDF)
	list (APPEND doc_formats latexpdf)
endif()

set (doc_format_outputs "")
set (doc_format_last "")

foreach(format ${doc_formats})
	set (doc_format_output "doc_format_${format}")
	set (doc_format_log "${CMAKE_CURRENT_BINARY_DIR}/doctrees/logs/build-${format}.log")

	if(format STREQUAL "latexpdf")
		# This format does not use builder (-b) but make_mode (-M) which expects arguments in
		# peculiar order
		add_custom_command (
			OUTPUT "${doc_format_output}"
			COMMAND
				"${SPHINX_EXECUTABLE}" -M "${format}" "${ORANGES_DOCS_BUILD_TREE}"
				"${CMAKE_CURRENT_BINARY_DIR}/${format}" -c "${CMAKE_CURRENT_BINARY_DIR}" -d
				"${CMAKE_CURRENT_BINARY_DIR}/doctrees" ${sphinx_flags} > "${doc_format_log}"
				${${format}_extra_commands}
			DEPENDS ${doc_format_last}
			COMMENT "sphinx-build ${format}: see ${doc_format_log}"
			VERBATIM)
	else()
		# other formats use standard builder (-b) mode
		add_custom_command (
			OUTPUT "${doc_format_output}"
			COMMAND
				"${SPHINX_EXECUTABLE}" -c "${CMAKE_CURRENT_BINARY_DIR}" -d
				"${CMAKE_CURRENT_BINARY_DIR}/doctrees" -b "${format}" ${sphinx_flags}
				"${ORANGES_DOCS_BUILD_TREE}" "${CMAKE_CURRENT_BINARY_DIR}/${format}" >
				"${doc_format_log}" # log stdout, pass stderr
				${${format}_extra_commands}
			DEPENDS ${doc_format_last}
			COMMENT "sphinx-build ${format}: see ${doc_format_log}"
			VERBATIM)
	endif()

	set_property (SOURCE "${doc_format_output}" PROPERTY SYMBOLIC 1)
	list (APPEND doc_format_outputs "${doc_format_output}")
	set (doc_format_last "${doc_format_output}")
endforeach()

#

if(PROJECT_IS_TOP_LEVEL OR Oranges_IS_TOP_LEVEL)
	set (all_flag ALL)
endif()

add_custom_target (oranges_docs ${all_flag} DEPENDS "${doc_format_outputs}"
				   COMMENT "Building Oranges documentation...")

#

if(SPHINX_INFO)
	install (FILES "${CMAKE_CURRENT_BINARY_DIR}/texinfo/oranges.info"
			 DESTINATION "${CMAKE_INFO_DIR}" COMPONENT oranges_docs)
endif()

# TODO: install man pages

if(SPHINX_HTML)
	install (DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html" DESTINATION "${CMAKE_DOC_DIR}"
			 PATTERN .buildinfo EXCLUDE COMPONENT oranges_docs)
endif()

if(SPHINX_SINGLEHTML)
	install (DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/singlehtml" DESTINATION "${CMAKE_DOC_DIR}"
			 PATTERN .buildinfo EXCLUDE COMPONENT oranges_docs)
endif()

if(SPHINX_LATEXPDF)
	install (FILES "${CMAKE_CURRENT_BINARY_DIR}/latexpdf/latex/Oranges.pdf"
			 DESTINATION "${CMAKE_DOC_DIR}" COMPONENT oranges_docs)
endif()

include (CPackComponent)

cpack_add_component (oranges_docs DISPLAY_NAME "Oranges documentation"
					 DESCRIPTION "Installs all Oranges documentation" GROUP Oranges)
