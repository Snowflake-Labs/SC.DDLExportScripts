# Installation Guide

## Quick Start

`sc-tera-export` is installed via pip.  If you know pip, you can install `sc-tera-export` using command

```shell
$ pip install snowconvert-tera-export
```

This command may need to run as sudo if you are installing to the system site packages. snowconvert-tera-export can be 
installed using the --user option, which does not require sudo.

```shell
$ pip install --user snowconvert-tera-export
```

## Troubleshooting

On systems with limited internet access or legacy OS version you might not be able to do `pip install`. In those situations we recommend to do the following:

Browse to: [https://pypi.org/project/snowconvert-export-tera/#files](https://pypi.org/project/snowconvert-export-tera/#files)

In the download table you will an option with a file type of `Source` and extension `.tar.gz`. Download that file and copy that file into the server.

Open a terminal and run:

```bash
tar -xvf filename.tar.gz
```

A folder called `filename` will be created. Switch to that folder and run:
```bash
python setup.py
```

That should install the package. You can then follow the [usage guide](./usage_guide.md)