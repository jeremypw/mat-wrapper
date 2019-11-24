# Metadata Anonymisation Tool Wrapper
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

A *simple* way to remove metadata that may be a privacy concern from some file types using Pantheon Files.
To work it is necessary to have the mat tool installed (sudo apt install mat). This package provides a suitable contractor
file as well as changing the default action of mat.  When installed you will find that the context menu in
Pantheon Files shows an extra entry when one or more file items has been selected. Clicking on this option results in
a new files being created with the ".stripped" extension that have the same content as the selected files but with
metadata removed. The advantage of this is that both files are then thumbnailed in Files and only one action is
required to remove the stripped file.  The wrapper will not proceed if it detects that a file would be overwritten.

The functionality of this wrapper is limited by `mat` which is the tool in the Ubuntu Bionic repository. Bear in mind
the warnings given in `mat` documentation regarding the extent of anonymisation, which is not 100% perfect.

When elementaryos is rebased on a distibution that contains the later version of the tool `mat2` then this wrapper
will be updated to use that.

![Screenshot](/data/screenshots/Strip.png?raw=true "Strip metadata menu option")

The tool can also be used from the command line:
`com.github.jeremypw.mat-wrapper [FILES]`

The flag "--no-rename" may be used to restore the native renaming of the `mat` tool. That is, after stripping, the
original file is given a ".bak" extension and the stripped file takes the original file name.

For more functionality it is possible to run the `mat` tool directly or with the `mat-gui` app.
Type `mat --help` at the command line for further information.

## Building from source

### Dependencies
These dependencies must be present before building
 - `valac`
 - `meson`
 - `glib-2.0`
 - `gtk+3.0`
 - `granite`

 You can install these on a Ubuntu-based system by executing this command:

 `sudo apt install valac meson libgranite-dev`

### To build

```
meson build --prefix=/usr  --buildtype=release
cd build
ninja

```

### To install

`sudo ninja install`
