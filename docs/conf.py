# -*- coding: utf-8 -*-
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

import sys


sys.path.insert(0, r'@conf_path@')

source_suffix = '.rst'
root_doc = 'index'

project = 'Oranges'
author = 'Ben Vining'
copyright = '@conf_copyright@'  # pylint: disable=redefined-builtin
version = '@conf_version@'  # feature version
release = '@conf_version@'  # full version string
pygments_style = 'colors.CMakeTemplateStyle'

language = 'en'
primary_domain = 'cmake'
highlight_language = 'none'

# needs_sphinx = '1.1'

exclude_patterns = []

extensions = ['cmake']
#templates_path = ['@conf_path@/templates']

nitpicky = True
smartquotes = False
numfig = True

man_show_urls = False
man_make_section_directory = False

html_show_sourcelink = True
#html_static_path = ['@conf_path@/static']
#html_style = 'cmake.css'
html_theme = 'default'
html_theme_options = {
    'footerbgcolor': '#00182d',
    'footertextcolor': '#ffffff',
    'sidebarbgcolor': '#e4ece8',
    'sidebarbtncolor': '#00a94f',
    'sidebartextcolor': '#333333',
    'sidebarlinkcolor': '#00a94f',
    'relbarbgcolor': '#00529b',
    'relbartextcolor': '#ffffff',
    'relbarlinkcolor': '#ffffff',
    'bgcolor': '#ffffff',
    'textcolor': '#444444',
    'headbgcolor': '#f2f2f2',
    'headtextcolor': '#003564',
    'headlinkcolor': '#3d8ff2',
    'linkcolor': '#2b63a8',
    'visitedlinkcolor': '#2b63a8',
    'codebgcolor': '#eeeeee',
    'codetextcolor': '#333333',
}

html_title = f'Oranges {release} Documentation'
html_short_title = f'{release} Documentation'
#html_favicon = '@conf_path@/static/cmake-favicon.ico'

# Not supported yet by sphinx:
# https://bitbucket.org/birkenfeld/sphinx/issue/1448/make-qthelp-more-configurable
# qthelp_namespace = "org.cmake"
# qthelp_qch_name = "CMake.qch"
