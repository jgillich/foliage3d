#!/usr/bin/env python
import os
from glob import glob
from pathlib import Path


# TODO: Do not copy environment after godot-cpp/test is updated <https://github.com/godotengine/godot-cpp/blob/master/test/SConstruct>.
env = SConscript("godot-cpp/SConstruct")

# terrain = SConscript('Terrain3D/SConstruct')
# env.Append(LIBS=[terrain])

# Add source files.
env.Append(CPPPATH=["src/", 'Terrain3D/src'])
sources = Glob("src/*.cpp")

# Get the project name from the gdextension file (e.g. example).
project_name = Path().resolve().stem

scons_cache_path = os.environ.get("SCONS_CACHE")
if scons_cache_path != None:
    CacheDir(scons_cache_path)
    print("Scons cache enabled... (path: '" + scons_cache_path + "')")

# Create the library target (e.g. libexample.linux.debug.x86_64.so).
debug_or_release = "release" if env["target"] == "template_release" else "debug"
if env["platform"] == "macos":
    library = env.SharedLibrary(
        "bin/lib{1}.{2}.{3}.framework/{1}.{2}.{3}".format(
            project_name,
            env["platform"],
            debug_or_release,
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "bin/lib{}.{}.{}.{}{}".format(
            project_name,
            env["platform"],
            debug_or_release,
            env["arch"],
            env["SHLIBSUFFIX"],
        ),
        source=sources,
    )

Default(library)
