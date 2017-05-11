# rpi-jupyter
Jupyter Notebook Server on Raspberry Pi

To have your own Jupyter Notebook Server running 24/7 on Raspberry Pi. If connected to your router, with port forwarding and DDNS set up, you can carry out your Data Science tasks on the move.

Despite the fact that we adore Raspberry Pi and it is becoming more and more powerful, it is not intended to run large cpu intensive tasks. It will be slow and the best model only offers 1G of RAM. For larger datasets, you either need to use incremental machine learning algorithms or build a cluster and run Spark on it. 

----------
This is a dockerfile for building jupyter notebook on your Raspberry Pi. It is a minimal notebook server with Python 3.4.3 and [resin/rpi-raspbian:jessie](https://hub.docker.com/r/resin/rpi-raspbian/) as base image. This packages are installed:

    build-essential libncursesw5-dev libncurses5-dev libgdbm-dev libc6-dev zlib1g-dev libsqlite3-dev tk-dev libssl-dev openssl libbz2-dev ca-certificates wget bzip2 vim

### Installing

    docker pull movalex/rpi-jupyter-conda

### Running in detached mode

    docker run -d -p 8888:8888 movalex/rpi-jupyter-conda 

Now you can access your notebook at `http://<docker host IP address>:8888`

### Configuration
The image already has following configuration:

* `c.NotebookApp.open_browser = False`
* `c.NotebookApp.ip = '*'`

If you would like to change some config, create your own `jupyter_notebook_config.py` (or use sample file from this repository) on the docker host and run the following:

    docker run -it -p <host port>:<dest port> -v <path to your config file>:/home/jovyan/.jupyter/jupyter_notebook_config.py movalex/rpi-jupyter-conda

This maps a local config file to the container. The notebook will run under unpriviledged user `jovyan` (uid=1000) with ownership of `/home/jovyan` and `opt/conda`. If you want to mount your default working directory on the host to preserve work even when notebook is not running or destroyed, use additional `-v` option:

    docker run -it docker run -it -p <host port>:<dest port> -v <path to your config file>:/home/jovyan/.jupyter/jupyter_notebook_config.py -v /some/host/folder/for/work:/home/jovyan/work  movalex/rpi-jupyter-conda

To login a bash session use:

    docker exec -it <container id> /bin/bash

If you want to start bash session with root accesss so you could do more, just use this command:

    docker exec -it -u 0 <container id> /bin/bash

### For Data Scientists
You can pull `movalex/rpi-jupyter-conda-datascience` so that you have most of the data science packages installed. This image has preinstalled following additional packages: 

    cython flask h5py numexpr pandas pillow pycrypto pytables scikit-learn 
    scipy sqlalchemy sympy beautifulsoup4 bokeh cloudpickle dill matplotlib
    scikit-image seaborn statsmodels vincent xlrd nltk

You can install additional packages manually via `conda install` or `pip install`. This will work with unpriviledged user, since all pachakes are installed in `opt/conda`, owned by this user.

Here's a list of all packages available for Raspberry Pi via Conda:
    
    anaconda-client, argcomplete, astropy, bitarray, blist, boto, bsdiff4,
    cheetah (Python 2 only), conda, conda-build, configobj, cython, cytoolz,
    docutils, enum34 (Python 2 only), ephem, flask, grin (Python 2 only),
    h5py, ipython, jinja2, lxml, mercurial (Python 2 only), netcdf4, networkx,
    nltk, nose, numexpr, numpy, openpyxl, pandas, pillow, pip, ply, psutil,
    pycosat, pycparser, pycrypto, pycurl, pyflakes, pytables, pytest, python,
    python-dateutil, pytz, pyyaml, pyzmq (armv7l only), requests,
    scikit-learn (armv7l only), scipy (armv7l only), setuptools, six,
    sqlalchemy, sphinx, sympy, toolz, tornado, twisted, werkzeug, wheel

For further information see [conda support for raspberry pi 2 and power8 le](https://www.continuum.io/content/conda-support-raspberry-pi-2-and-power8-le)