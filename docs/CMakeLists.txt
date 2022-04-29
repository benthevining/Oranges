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

project (
	OrangesDocs
	VERSION "${Oranges_VERSION}"
	DESCRIPTION "Oranges documentation"
	HOMEPAGE_URL "${Oranges_HOMEPAGE_URL}"
	LANGUAGES NONE)

#

find_program (SPHINX_EXECUTABLE NAMES sphinx-build
			  DOC "Sphinx Documentation Builder (sphinx-doc.org)")

set (SPHINX_FLAGS "" CACHE STRING "Flags to pass to sphinx-build")

separate_arguments (sphinx_flags UNIX_COMMAND "${SPHINX_FLAGS}")

if (NOT SPHINX_EXECUTABLE)
	if (Oranges_IS_TOP_LEVEL)
		message (WARNING "SPHINX_EXECUTABLE (sphinx-build) is not found!")
	endif ()

	return ()
endif ()

find_package (Python3 3.9 COMPONENTS Interpreter)

if (NOT TARGET Python3::Interpreter OR NOT Python3_FOUND)
	if (Oranges_IS_TOP_LEVEL)
		message (WARNING "Python cannot be found, docs cannot be built!")
	endif ()

	return ()
endif ()

#

set (ORANGES_DOCS_BUILD_TREE "${Oranges_BINARY_DIR}/OrangesDocs")

file (MAKE_DIRECTORY "${ORANGES_DOCS_BUILD_TREE}")

# Generate .rst files for each module, and an index.rst

set (ORANGES_MODULES_ROOT "${Oranges_SOURCE_DIR}/modules")
set (RST_OUTPUT_DIR "${ORANGES_DOCS_BUILD_TREE}/modules")
set (INPUT_INDEX_FILE "${CMAKE_CURRENT_LIST_DIR}/index.rst")

set (configured_script "${CMAKE_CURRENT_BINARY_DIR}/generate_rsts.py")

configure_file (generate_rsts.py "${configured_script}" @ONLY
				NEWLINE_STYLE UNIX)

execute_process (COMMAND python3 "${configured_script}")

unset (ORANGES_MODULES_ROOT)
unset (RST_OUTPUT_DIR)
unset (INPUT_INDEX_FILE)

#

set (conf_path "${CMAKE_CURRENT_SOURCE_DIR}")
set (
	conf_version
	"${Oranges_VERSION_MAJOR}.${Oranges_VERSION_MINOR}.${Oranges_VERSION_PATCH}"
	)

configure_file (conf.py conf.py @ONLY NEWLINE_STYLE UNIX)

unset (conf_path)
unset (conf_version)

# we provide the path to the produced html output in the console for tools that
# support URI protocol schemes
set (
	html_extra_commands
	COMMAND "${CMAKE_COMMAND}" -E echo
	"sphinx-build html: HTML documentation generated in file://${CMAKE_CURRENT_BINARY_DIR}/html/index.html"
	)

find_program (MAKEINFO_EXECUTABLE NAMES makeinfo DOC "makeinfo tool")

if (MAKEINFO_EXECUTABLE)
	list (APPEND doc_formats texinfo)

	# Sphinx texinfo builder supports .info, .txt, .html and .pdf output
	set (
		texinfo_extra_commands
		COMMAND "${MAKEINFO_EXECUTABLE}" --no-split -o
		"${CMAKE_CURRENT_BINARY_DIR}/texinfo/oranges.info"
		"${CMAKE_CURRENT_BINARY_DIR}/texinfo/oranges.texi")

	set (texinfo_flag texinfo)
else ()
	message (WARNING "MAKEINFO_EXECUTABLE (makeinfo) not found!")
endif ()

set (doc_format_outputs "")
set (doc_format_last "")

foreach (format IN ITEMS html singlehtml man latexpdf ${texinfo_flag})
	set (doc_format_output "doc_format_${format}")

	if ("${format}" STREQUAL latexpdf)
		# This format does not use builder (-b) but make_mode (-M) which expects
		# arguments in peculiar order
		add_custom_command (
			OUTPUT "${doc_format_output}"
			COMMAND
				"${SPHINX_EXECUTABLE}" -M "${format}"
				"${ORANGES_DOCS_BUILD_TREE}"
				"${CMAKE_CURRENT_BINARY_DIR}/${format}" -c
				"${CMAKE_CURRENT_BINARY_DIR}" -d
				"${CMAKE_CURRENT_BINARY_DIR}/doctrees" ${sphinx_flags}
				${${format}_extra_commands}
			DEPENDS ${doc_format_last}
			COMMENT "sphinx-build ${format}..."
			VERBATIM USES_TERMINAL)
	else ()
		# other formats use standard builder (-b) mode
		add_custom_command (
			OUTPUT "${doc_format_output}"
			COMMAND
				"${SPHINX_EXECUTABLE}" -c "${CMAKE_CURRENT_BINARY_DIR}" -d
				"${CMAKE_CURRENT_BINARY_DIR}/doctrees" -b "${format}"
				${sphinx_flags} "${ORANGES_DOCS_BUILD_TREE}"
				"${CMAKE_CURRENT_BINARY_DIR}/${format}"
				${${format}_extra_commands}
			DEPENDS ${doc_format_last}
			COMMENT "sphinx-build ${format}..."
			VERBATIM USES_TERMINAL)
	endif ()

	set_property (SOURCE "${doc_format_output}" PROPERTY SYMBOLIC 1)
	list (APPEND doc_format_outputs "${doc_format_output}")
	set (doc_format_last "${doc_format_output}")
endforeach ()

#

add_custom_target (OrangesDocs DEPENDS "${doc_format_outputs}"
				   COMMENT "Building Oranges documentation...")

#

include (GNUInstallDirs)

if (texinfo_flag)
	install (FILES "${CMAKE_CURRENT_BINARY_DIR}/texinfo/oranges.info"
			 DESTINATION "${CMAKE_INSTALL_INFODIR}" COMPONENT oranges_docs)
endif ()

# TODO: install man pages

install (DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/html" COMPONENT oranges_docs
		 DESTINATION "${CMAKE_INSTALL_DOCDIR}" PATTERN .buildinfo EXCLUDE)

install (DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/singlehtml"
		 COMPONENT oranges_docs DESTINATION "${CMAKE_INSTALL_DOCDIR}"
		 PATTERN .buildinfo EXCLUDE)

install (FILES "${CMAKE_CURRENT_BINARY_DIR}/latexpdf/latex/Oranges.pdf"
		 DESTINATION "${CMAKE_INSTALL_DOCDIR}" COMPONENT oranges_docs OPTIONAL)

include (CPackComponent)

cpack_add_component (
	oranges_docs DISPLAY_NAME "Oranges documentation"
	DESCRIPTION "Installs all Oranges documentation" GROUP Oranges)
