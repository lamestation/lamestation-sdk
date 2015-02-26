from setuptools import setup, find_packages

with open('README.rst') as f:
        long_description = f.read()

setup(
        name = "LameStation Tools",
        version = "0.2.0",
        author = "LameStation",
        author_email = "contact@lamestation.com",
        description = "A collection of pixelated paint tools for the LameStation.",
        long_description = long_description,
        license = "GPLv3",
        url = "https://github.com/lamestation/lamestation-tools",
        keywords = "packaging qt qmake building distribution",
        packages=find_packages(exclude=['test']),
        include_package_data=True,
        scripts=[
            'bin/map2dat',
            'bin/frequencytiming',
            'bin/noise',
            ],
        entry_points={
            'console_scripts': [
                'img2dat = img2dat.img2dat:console',
                ],
            'gui_scripts': [
                'img2dat-gui = img2dat.img2dat:gui',
                'lspaint = lspaint.LSPaint',
                ]
            },
        classifiers=[
            "Development Status :: 3 - Alpha",
            "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
            "Programming Language :: Python :: 2 :: Only",
            "Programming Language :: Python :: 2.7",
            "Topic :: Games/Entertainment",
            "Topic :: Multimedia :: Graphics :: Graphics Conversion",
            "Topic :: Multimedia :: Graphics :: Editors :: Raster-Based",
            "Topic :: Multimedia :: Graphics :: Viewers",
            ]
        )
