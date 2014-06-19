

# Building The Binary Release

## Linux

### Debian

```
sudo apt-get install python-imaging cx-freeze python-wxgtk2.8
```

Then browse to the `tools/` directory and type `make`.

```
make
```

## Windows

PIL wxWidgets Python PIP cxfreeze

 * [**Python Imaging Library**](http://www.pythonware.com/products/pil/)
 * [**wxPython**](http://www.wxpython.org/download.php)

Then the build is straight-forward 

```
\Python27\Scripts\cxfreeze.py --base-name=Win32GUI img2dat.py
```

This will generate the dist folder, which can then be packaged as a zip file.
