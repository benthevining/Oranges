install_fftw
-------------------------------

The script ``install_fftw.cmake`` is meant to be invoked on the command line using ``cmake -P``.
This script builds and installs both the double- and single-precision versions of FFTW onto your system.

Command-line usage
^^^^^^^^^^^^^^^^^^^^^^

``cmake -P install_fftw.cmake [-D SOURCE_DIR=<fftw_source>]|[-D CACHE_DIR=<cache_dir>] [-D QUIET=ON|OFF]``

Input variables:

* ``SOURCE_DIR``: Can be set to the path of a copy of the FFTW source tree. If not defined, FFTW sources will be downloaded.
* ``CACHE_DIR``: Directory to use to cache downloaded sources. If not defined, then if the environment variable :envvar:`CMAKE_CACHE` is defined, this variable is initialized to its value. Otherwise, defaults to ``<scriptDir>/temp``.
* ``QUIET``: If set to ``ON``, suppresses most progress messages. Defaults to ``OFF``.
