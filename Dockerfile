# This file creates a container that runs a jupyter notebook server on Raspberry Pi

FROM resin/rpi-raspbian:latest
MAINTAINER Alex Bogomolov <mail@abogomolov.com>

USER root
ENV DEBIAN_FRONTEND noninteractive

# Install packages 
RUN apt-get update && apt-get upgrade && apt-get install -y \
        locales \
        ca-certificates \
        wget \
        bzip2 \
        fonts-liberation \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen 

# Install Tini from binary. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION 0.14.0
RUN wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-armhf && \
	echo "4d06a370b9f912334e7edd7a000099474fd3c7f3d73d80353bd66ba7dc413a86 *tini-armhf" | sha256sum -c - && \
	mv tini-armhf /usr/local/bin/tini && \
	chmod +x /usr/local/bin/tini
#you can build tini yourself if you want to:
#ENV TINI_VERSION 0.14.0
#ENV CFLAGS="-DPR_SET_CHILD_SUBREAPER=36 -DPR_GET_CHILD_SUBREAPER=37"
#ADD https://github.com/krallin/tini/archive/v${TINI_VERSION}.tar.gz v${TINI_VERSION}.tar.gz
#RUN apt-get install -y cmake
#RUN tar zxvf v${TINI_VERSION}.tar.gz \
#        && cd tini-${TINI_VERSION} \
#        && cmake . \
#        && make \
#        && cp tini /usr/bin/. \
#        && cd .. \
#        && rm -rf "./tini-${TINI_VERSION}" \
#        && rm "./v${TINI_VERSION}.tar.gz"
#ENTRYPOINT ["/usr/bin/tini", "--"]

ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=jovyan \
    NB_UID=1000 \
    NB_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group

ENV PYTHON_VERSION=3.6.3

USER $NB_UID

# Setup jovyan home directory
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

#Install BerryConda
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://github.com/jjhelmus/berryconda/releases/download/v2.0.0/Berryconda3-2.0.0-Linux-armv7l.sh && \
    echo "44d29f2e8f5cc0e5a360edb8b49eda52aa23acf41ed064314ae70876a4f130bf *Berryconda3-2.0.0-Linux-armv7l.sh" | sha256sum -c - && \
    /bin/bash Berryconda3-2.0.0-Linux-armv7l.sh -f -b -p $CONDA_DIR && \
    rm Berryconda3-2.0.0-Linux-armv7l.sh && \
    $CONDA_DIR/bin/conda config --system --add channels rpi && \
    conda install --yes python=$PYTHON_VERSION \
    && conda clean -tipsy

RUN chown -R $NB_USER /home/$NB_USER

RUN pip install -U pip setuptools --ignore-installed 
RUN conda install --yes \
    'notebook=5.2.*' \
    'jupyterlab=0.31.*' 

# Configure jupyter
RUN jupyter notebook --generate-config
RUN sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /home/$NB_USER/.jupyter/jupyter_notebook_config.py  
RUN sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /home/$NB_USER/.jupyter/jupyter_notebook_config.py

#VOLUME /home/$NB_USER/work
USER root

EXPOSE 8888
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser"]

USER $NB_UID

