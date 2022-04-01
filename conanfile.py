# -*- coding: utf-8 -*-
from conans import CMake, ConanFile


class OrangesConan(ConanFile):
	name = "Oranges"
	version = "2.4.0"
	license = "GPL3"
	url = "https://github.com/benthevining/Oranges"
	description = "CMake modules, scripts, and utilities"
	settings = "os", "compiler", "build_type", "arch"
	generators = "cmake", "cmake_find_package", "json", "pkg_config"
	exports_sources = "*"

	def configure_cmake(self):
		cmake = CMake(self)
		cmake.configure()
		return cmake

	def build(self):
		cmake = self.configure_cmake()
		cmake.build()

	def package(self):
		cmake = self.configure_cmake()
		cmake.install()

	def package_info(self):
		self.cpp_info.libs = ["hello"]
