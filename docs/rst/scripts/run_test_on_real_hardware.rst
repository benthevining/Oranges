run_test_on_real_hardware
-------------------------------

The script ``run_test_on_real_hardware.sh`` is meant to be used in a cross-compiling scenario; this script copies a built executable onto a target device using ``ssh``, executes it on the device, and returns the result.

You can easily integrate this script into your CMake project by setting the variable :external:variable:`CMAKE_CROSSCOMPILING_EMULATOR` to the path of this script (you can also do this at the target level by setting the target's :external:prop_tgt:`CROSSCOMPILING_EMULATOR` property).

Environment variables
^^^^^^^^^^^^^^^^^^^^^^

.. cmake:envvar:: CROSSCOMPILING_TARGET_IP

Defines the IP address that will be used to ``ssh`` into the target device. Defaults to ``root@172.22.22.22``.
Note that this variable needs to be set at the time the test is *executed*; its value at configure or build time has no effect.
