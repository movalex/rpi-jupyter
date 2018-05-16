# rpi-jupyter-conda

Minimal Jupyter Notebook for Raspberry Pi with Python 3.6.3
----------
To have your own Jupyter Notebook Server running 24/7 on Raspberry Pi. If connected to your router, with port forwarding and DDNS set up, you can carry out your Jupyter tasks on the move.

This is a minimal Jupyter notebook server with Python 3.6.3 installed with [Berryconda3](https://github.com/jjhelmus/berryconda) and [resin/rpi-raspbian:latest](https://hub.docker.com/r/resin/rpi-raspbian/) as base image. JupyterLab is also installed. To use Lab interface just replace `tree` with `lab` in notebook URL. 

* Minimal finction Jupyter notebook 5.2.x installation
* Conda based Python 3.6.3 for Raspberry pi
* Unprivileged user jovyan in group users (gid=100) with ownership over `/home/jovyan` and `/opt/conda`
* [Tini](https://github.com/krallin/tini) 0.14.0 as the container entrypoint

These packages are installed:

    locales ca-certificates wget bzip2 vim fonts_liberation

### Installing

Of course, first you will need to install Docker on your Raspberry Pi:

    curl -sSL https://get.docker.com | sh
   
Then run this:

    docker pull movalex/rpi-jupyter-conda:latest

### Running in detached mode

    docker run -d -p 8888:8888 movalex/rpi-jupyter-conda

Now you can access your notebook at `http://<docker host IP address>:8888`

### Configuration
The image already has following configuration, so 'open browser' option is disabled and your notebook is accessible from any ip:

* `c.NotebookApp.open_browser = False`
* `c.NotebookApp.ip = '*'`

If you would like to change configuration, create your own `jupyter_notebook_config.py` (or use sample file from this repository), place it to `$HOME/.jupyter` folder and link it to docker volume. Run the following to map a local config file to the container:

    docker run -it -p 8888:8888 -v <path to your config file>:/home/jovyan/.jupyter/jupyter_notebook_config.py movalex/rpi-jupyter-conda

To add a password for your notebook, you can alter `c.NotebookApp.password = ''` section in config file. You can add password later after jupyter is installed. Just run 

    from IPython.lib import passwd
    passwd()

in Python Jupyter notebook to generate new password, and add output as a value of `c.NotebookApp.password`.

The notebook will run under unpriviledged user `jovyan` (uid=1000) with ownership of `/home/jovyan` and `opt/conda`. If you want to mount your default working directory on the host to preserve work even when notebook is not running or destroyed, use additional `-v` option:

    docker run -it docker run -it -p <host port>:<dest port> -v <path to your config file>:/home/jovyan/.jupyter/jupyter_notebook_config.py -v /some/host/folder/for/work:/home/jovyan/work  movalex/rpi-jupyter-conda
    
### Login to bash session

To login a bash session use:

    docker exec -it <container id> /bin/bash

If you want to start bash session with root accesss so you could do more, use this command:

    docker exec -it -u 0 <container id> /bin/bash

### For Data Scientists
There's [movalex/rpi-jupyter-julia](https://hub.docker.com/r/movalex/rpi-jupyter-julia/) Docker image (see also [Github repository](https://github.com/movalex/rpi-jupyter-julia)), which has most of the data science packages preinstalled and compiled. This image has following packages: 

    cython flask h5py numexpr pandas pillow pycrypto pytables scikit-learn 
    scipy sqlalchemy sympy beautifulsoup4 bokeh cloudpickle dill matplotlib
    scikit-image seaborn statsmodels vincent xlrd nltk

It also has [iJulia 0.6.2](https://julialang.org/) notebook with all stuff it goes with. `Pyplot`, `Distributions` and `Rdatasets` are preinstalled.

You can install additional packages manually via `conda install` or `pip install`.

Here's a list of [all packages available](https://www.continuum.io/content/conda-support-raspberry-pi-2-and-power8-le) for Raspberry Pi via Conda:
    
    anaconda-client, argcomplete, astropy, bitarray, blist, boto, bsdiff4,
    cheetah (Python 2 only), conda, conda-build, configobj, cython, cytoolz,
    docutils, enum34 (Python 2 only), ephem, flask, grin (Python 2 only),
    h5py, ipython, jinja2, lxml, mercurial (Python 2 only), netcdf4, networkx,
    nltk, nose, numexpr, numpy, openpyxl, pandas, pillow, pip, ply, psutil,
    pycosat, pycparser, pycrypto, pycurl, pyflakes, pytables, pytest, python,
    python-dateutil, pytz, pyyaml, pyzmq (armv7l only), requests,
    scikit-learn (armv7l only), scipy (armv7l only), setuptools, six,
    sqlalchemy, sphinx, sympy, toolz, tornado, twisted, werkzeug, wheel
    
### Using Python 2 kernel

This Docker container has only Python 3 kernel. If you still need Python2, you can add Python2 Conda environment and add it to Jupyter with `ipykernel` module. But since this module requires `gcc` and `libzmq3`, you'll need to install them first in priviledged bash session.

IMHO better solution would be using [this datascience image](https://github.com/movalex/rpi-jupyter-julia) with all necessary libraries (and many others) pre-installed. [Here](https://github.com/movalex/rpi-jupyter-julia/blob/master/README.md#python2-kernel) you can read how to add Python2 kernel to Jupyter Notebook.

[![Anaconda-Server Badge](https://anaconda.org/rpi/python/badges/version.svg)](https://anaconda.org/rpi/python)
[![Anaconda-Server Badge](https://anaconda.org/rpi/python/badges/platforms.svg)](https://anaconda.org/rpi/python)
[![Anaconda-Server Badge](https://anaconda.org/rpi/python/badges/installer/conda.svg)](https://conda.anaconda.org/rpi)
