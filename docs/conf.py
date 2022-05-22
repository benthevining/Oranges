# -*- coding: utf-8 -*-
# pylint: skip-file
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

from sys import path as sys_path


sys_path.insert(0, r'@scripts_path@')
sys_path.insert(0, r'@conf_path@')

source_suffix = '.rst'
root_doc = 'index'

project = 'Oranges'
author = 'Ben Vining'
copyright = '2022 Ben Vining; released to public ownership under the terms of the GNU Public License'
version = '@conf_version@'  # feature version
release = '@conf_version@'  # full version string
pygments_style = 'colors.OrangesTemplateStyle'

language = 'en'
primary_domain = 'cmake'
highlight_language = 'cmake'

needs_sphinx = '4.1'

intersphinx_mapping = {'cmake': ('https://cmake.org/cmake/help/latest', None)}

nitpicky = True
smartquotes = True
numfig = False

#
# extensions

autosectionlabel_prefix_document = True

autodoc_typehints = 'both'

# editorconfig-checker-disable
extensions = [
    'sphinx.ext.autosectionlabel', 'sphinx.ext.githubpages',
    'sphinx.ext.intersphinx', 'sphinx.ext.autodoc', 'sphinxarg.ext',
    'sphinxcontrib.moderncmakedomain'
]
# editorconfig-checker-enable

#
# man pages

man_show_urls = False
man_make_section_directory = False

#
# HTML

# html_baseurl
html_show_sourcelink = False
html_static_path = ['@conf_path@']
html_style = 'oranges.css'
html_theme = 'default'
html_split_index = True
html_copy_source = False
html_scaled_image_link = True

# editorconfig-checker-disable
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

html_sidebars = {
    '**':
    ['localtoc.html', 'relations.html', 'globaltoc.html', 'searchbox.html']
}
# editorconfig-checker-enable

html_last_updated_fmt = '%b %d, %Y'

html_permalinks = True

html_title = f'Oranges {release} Documentation'
html_short_title = f'Oranges {release} Documentation'
# html_favicon

#
# Latex

latex_show_pagerefs = True
latex_show_urls = 'footnote'

#
# Texinfo

texinfo_show_urls = 'footnote'

#
# Linkcheck

linkcheck_retries = 4
