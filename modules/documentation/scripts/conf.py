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

project = '@ORANGES_ARG_PROJECT_NAME@'
version = '@ORANGES_ARG_VERSION@'  # feature version
release = '@ORANGES_ARG_VERSION@'  # full version string

language = 'en'

needs_sphinx = '4.1'

nitpicky = True
smartquotes = True
numfig = False

#
# man pages

man_show_urls = False
man_make_section_directory = False

#
# HTML

# html_baseurl
html_show_sourcelink = False
html_theme = '@ORANGES_ARG_HTML_THEME@'
html_split_index = True
html_copy_source = False

# editorconfig-checker-disable
html_sidebars = {
    '**':
    ['localtoc.html', 'relations.html', 'globaltoc.html', 'searchbox.html']
}
# editorconfig-checker-enable

html_last_updated_fmt = '%b %d, %Y'

html_permalinks = True

html_title = f'@ORANGES_ARG_PROJECT_NAME@ {release} Documentation'
html_short_title = f'@ORANGES_ARG_PROJECT_NAME@ {release} Documentation'

#
# Latex

latex_show_pagerefs = True
latex_show_urls = 'footnote'
