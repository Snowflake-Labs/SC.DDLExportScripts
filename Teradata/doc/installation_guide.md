# Installation Guide

## Quick Start

The easier way to install `sc-tera-export` is thru [pip](https://pypi.org/project/pip/).  If you know pip, you can install `sc-tera-export` using command

```shell
$ pip install snowconvert-tera-export --upgrade
```

This command may need to run as sudo if you are installing to the system site packages. snowconvert-tera-export can be 
installed using the --user option, which does not require sudo.

```shell
$ pip install --upgrade --user snowconvert-tera-export
```

You can also install directly from source code. 

```
curl -L https://git.io/JcziL | bash
```

Or follow these steps:

* Browse to: [https://pypi.org/project/snowconvert-export-tera/#files](https://pypi.org/project/snowconvert-export-tera/#files)

    * In the download table you will an option with a file type of `Source` and extension `.tar.gz`. Download that file and copy that file into the server.

* Open a terminal and run:

```bash
tar -xvf filename.tar.gz
```

* A folder called `filename` will be created. Switch to that folder and run:
```bash
python setup.py
```

## Usage
After installation please follow the [usage guide](./usage_guide.md)