import sys
from cx_Freeze import setup, Executable
import platform

# Dependencies are automatically detected, but it might need fine tuning.
opts = {
        'compressed' : True,
        'create_shared_zip' : False,
        'packages' : ['wx.lib.pubsub']
        }


# GUI applications require a different base on Windows (the default is for a
# console application).
if platform.system() == 'Windows':
    base = 'Win32GUI'
else:
    base = None

setup(
        name = "LSPaint",
        version = "1.0",
        description = "A pixelated paint tool for the LameStation.",
        options = {"build_exe": opts},
        executables = [
            Executable("LSPaint.py", base=base),
            Executable("img2dat.py", base=base)
            ]
        )
