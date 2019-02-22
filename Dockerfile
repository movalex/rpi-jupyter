# This file creates a container that runs a jupyter notebook server on Raspberry Pi

FROM jsurf/rpi-raspbian-build-essentials 

RUN [ "cross-build-start" ]
USER root
# Install packages 
RUN apt-get update && apt-get upgrade && apt-get install -y \
    locales \
    ca-certificates \
    wget \
    bzip2

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen 

# Install Tini from binary. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION 0.18.0
RUN wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-armhf && \
	echo "01b54b934d5f5deb32aa4eb4b0f71d0e76324f4f0237cc262d59376bf2bdc269 *tini-armhf" | sha256sum -c - && \
	mv tini-armhf /usr/local/bin/tini && \
	chmod +x /usr/local/bin/tini

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

RUN useradd -d /home/$NB_USER -ms /bin/bash -g root -G sudo $NB_USER 

# Setup jovyan home directory
RUN mkdir -p $CONDA_DIR 

ENV PYTHON_VERSION='3.6.6'

RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

#Install BerryConda
RUN cd /tmp && \
    wget --quiet https://github.com/jjhelmus/berryconda/releases/download/v2.0.0/Berryconda3-2.0.0-Linux-armv7l.sh && \
    echo "44d29f2e8f5cc0e5a360edb8b49eda52aa23acf41ed064314ae70876a4f130bf *Berryconda3-2.0.0-Linux-armv7l.sh" | sha256sum -c -
RUN cd /tmp && ./Berryconda3-2.0.0-Linux-armv7l.sh -f -b -p $CONDA_DIR && \
    rm Berryconda3-2.0.0-Linux-armv7l.sh && \
    $CONDA_DIR/bin/conda config --system --add channels rpi && \
    conda install --yes python=$PYTHON_VERSION --channel rpi \
    && conda clean -tipsy

RUN conda install --yes -c rpi notebook jupyterlab 

RUN pip install -U pip setuptools --ignore-installed 

# Configure jupyter
RUN jupyter notebook --generate-config
RUN sed -i "/c.NotebookApp.open_browser/c c.NotebookApp.open_browser = False" /home/$NB_USER/.jupyter/jupyter_notebook_config.py  
RUN sed -i "/c.NotebookApp.ip/c c.NotebookApp.ip = '*'" /home/$NB_USER/.jupyter/jupyter_notebook_config.py

RUN chown -R $NB_USER /home/$NB_USER

RUN usermod -u $NB_UID $NB_USER && \
    usermod -g $NG_GID $NB_USER && \
    chown -R $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group
EXPOSE 8888
WORKDIR /home/$NB_USER/work
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "notebook", "--no-browser"]
RUN [ "cross-build-end" ]
USER $NB_UID
