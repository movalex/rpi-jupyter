# This file creates a container that runs a jupyter notebook server on Raspberry Pi

FROM resin/rpi-raspbian:jessie
MAINTAINER Alex Bogomolov <mail@abogomolov.com>

USER root

# Set the variables
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND noninteractive
ENV NB_USER jovyan
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN useradd -m -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR 

# Install packages necessary for compiling python
RUN apt-get update && apt-get upgrade && apt-get install -y \
        build-essential \
        libncursesw5-dev \
        libncurses5-dev \
        libgdbm-dev \
        libc6-dev \
        zlib1g-dev \
        libsqlite3-dev \
        tk-dev \
        libssl-dev \
        openssl \
        libbz2-dev \
        ca-certificates \
        wget \
        bzip2 \
        vim \
	&& apt-get clean 

# Setup jovyan home directory
USER $NB_USER
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-armv7l.sh && \
    echo "21797d303260e1f0fb89f1157b4ff1b6b58865e8b710aecdddacd8c2658ded2f *Miniconda3-latest-Linux-armv7l.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-latest-Linux-armv7l.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-latest-Linux-armv7l.sh && \
    $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
    conda clean -tipsy

RUN conda install --quiet --yes \
    'pip' \
    && conda clean -tipsy
RUN chown -R $NB_USER /home/$NB_USER
RUN pip install -U pip setuptools --ignore-installed 
RUN pip install jupyter

# Configure jupyter
RUN jupyter notebook --generate-config
RUN sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /home/$NB_USER/.jupyter/jupyter_notebook_config.py  
RUN sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /home/$NB_USER/.jupyter/jupyter_notebook_config.py

VOLUME /home/$NB_USER/work

# Install Tini from binary. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
USER root
ENV TINI_VERSION 0.14.0
RUN wget https://github.com/krallin/tini/releases/download/v0.14.0/tini-armhf && \
	echo "4d06a370b9f912334e7edd7a000099474fd3c7f3d73d80353bd66ba7dc413a86 *tini-armhf" | sha256sum -c - && \
	mv tini-armhf /usr/local/bin/tini && \
	chmod +x /usr/local/bin/tini
ENTRYPOINT ["tini", "--"]

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

EXPOSE 8888
WORKDIR /home/$NB_USER/work

CMD ["jupyter", "notebook"]
USER $NB_USER

