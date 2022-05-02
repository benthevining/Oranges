#!/bin/sh

# @formatter:off
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
# @formatter:on

# inputs:
# GH_REPO_TOKEN

set -euo

readonly GH_REPO_REF="github.com/benthevining/Oranges.git"

script_dir="$(cd "$(dirname "$0")" && pwd)"
readonly script_dir

readonly temp_dir="$script_dir/docs"

if [ -d "$temp_dir" ]; then
	rm -rf "$temp_dir"
fi

mkdir "$temp_dir"
cd "$temp_dir"

git clone -b docs --recurse-submodules "https://git@$GH_REPO_REF"

readonly docs_git_tree="$temp_dir/Oranges"

readonly oranges_root="$script_dir/.."

cd "$oranges_root"

python3 -m pip install -r requirements.txt

cmake --preset default

cmake --build --preset docs

# need to create an empty .nojekyll file
touch .nojekyll

cd "$docs_git_tree"

# remove everything currently in the docs branch
rm -rf -- *

# copy generated docs to cloned copy of docs git tree
mv "$oranges_root"/doc/html/* "$docs_git_tree"

git config push.default simple
git config user.name "Github Actions"
git config user.email "actions@github.com"

git add --all

git commit -am "Updating docs" --allow-empty

git push --force "https://${GH_REPO_TOKEN}@${GH_REPO_REF}" --no-verify

exit 0
