require "fileutils"
#require "etc"

#
# git clean -ffxd && git submodule foreach "git clean -ffxd

oranges_root = __dir__()

cache = File.join(oranges_root, "Cache")

builds = File.join(oranges_root, "Builds")

doc = File.join(oranges_root, "doc")

config = "Release"

#

def set_env_if_unset(envvar, value)
	if not ENV.has_key?(envvar) then
		ENV[envvar] = value
	end
end

set_env_if_unset("FETCHCONTENT_BASE_DIR", cache)
set_env_if_unset("CMAKE_BUILD_TYPE", config)
set_env_if_unset("CMAKE_CONFIG_TYPE", config)
set_env_if_unset("CMAKE_EXPORT_COMPILE_COMMANDS", "1")
set_env_if_unset("VERBOSE", "1")
#set_env_if_unset("CMAKE_BUILD_PARALLEL_LEVEL", etc.nprocessors)

module OS
	def OS.windows?
		(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
	end

	def OS.mac?
		(/darwin/ =~ RUBY_PLATFORM) != nil
	end
end

if OS.windows? then
	set_env_if_unset("CMAKE_GENERATOR", "Visual Studio 17 2022")
elsif OS.mac? then
	set_env_if_unset("CMAKE_GENERATOR", "Xcode")
else
	set_env_if_unset("CMAKE_GENERATOR", "Ninja Multi-Config")
end

if OS.windows? then
	sudo = ""
else
	sudo = "sudo"
end

#

task default: [:help]

desc "Show this message"
task :help do
	exec "cd %s && rake --tasks" % [oranges_root]
end

desc "Initialize the workspace"
task :init do
	python_reqs = File.join(oranges_root, "requirements.txt")

	exec "python3 -m pip install -r %s && cd %s && pre-commit install --install-hooks --overwrite && pre-commit install --install-hooks --overwrite --hook-type commit-msg" % [python_reqs, oranges_root]
end

desc "Run CMake configuration"
task :config do
	system "cd %s && cmake --preset maintainer" % [oranges_root]
end

desc "Open the IDE project"
task :open => :config do
	exec "cmake --open %s" % [builds]
end

#

desc "Run the build"
task :build => :config do
	system "cd %s && cmake --build --preset maintainer --config %s" % [oranges_root, config]
end

#

desc "Run CMake install"
task :install => :build do
	exec "%s cmake --install %s --config %s" % [sudo, builds, config]
end

desc "Run the uninstall script"
task :uninstall do
	script = File.join(builds, "uninstall.cmake")

	if File.exist?(script) then
		exec "cmake -P %s" % [script]
	end
end

#

desc "Generate the dependency graph image"
task :deps_graph => :config do
	exec "cmake --build %s --target OrangesDependencyGraph" % [builds]
end

desc "Build the docs"
task :docs => :config do
	exec "cmake --build %s --target OrangesDocs" % [builds]
end

#

def safe_dir_delete(dir)
	if File.directory?(dir) then
		FileUtils.remove_dir(dir)
	end
end

desc "Clean the builds directory"
task :clean do
	safe_dir_delete(builds)
	safe_dir_delete(doc)

	system "pre-commit gc"
end

desc "Wipe the cache of downloaded dependencies"
task :wipe => :clean do
	safe_dir_delete(cache)

	if ENV.has_key?("FETCHCONTENT_BASE_DIR") then
		safe_dir_delete(ENV["FETCHCONTENT_BASE_DIR"])
	end
end

#

desc "Run pre-commit over all files"
task :pc do
	exec "cd %s && git add . && pre-commit run --all-files" % [oranges_root]
end
