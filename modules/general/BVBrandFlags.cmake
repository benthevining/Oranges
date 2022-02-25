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

#[[
For internal usage by my own projects.

## Output variables:
- BV_DEFAULT_BRAND_FLAGS

]]

set (
	BV_DEFAULT_BRAND_FLAGS
	BUNDLE_ID
	com.BenViningMusicSoftware.${PROJECT_NAME}
	COMPANY_NAME
	Ben
	Vining
	Music
	Software
	COMPANY_WEBSITE
	www.benvining.com
	COMPANY_EMAIL
	ben.the.vining@gmail.com
	COMPANY_COPYRIGHT
	"Copyright 2021 Ben Vining"
	PLUGIN_MANUFACTURER_CODE
	Benv
	CACHE INTERNAL "Ben Vining Music Software brand flags")
