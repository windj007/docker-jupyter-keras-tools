FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

ARG NB_USER="jovyan"
ARG NB_UID="1001"
ARG NB_GID="100"


# ====== ROOT ======
USER root

# Basic libs
RUN apt clean && apt update

RUN apt install -yqq curl

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libbz2-dev \
                         libssl-dev libreadline-dev \
                         libsqlite3-dev tk-dev libpng-dev libfreetype6-dev git \
                         cmake wget gfortran \
                         libatlas3-base libhdf5-dev libxml2-dev libxslt-dev \
                         zlib1g-dev pkg-config graphviz \
                         locales nodejs libffi-dev liblapacke-dev libblas-dev liblapack-dev liblzma-dev

RUN apt install -y acl

# Nodejs 
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash && apt install -y nodejs

# VPN
RUN apt -y install openvpn

# SSH
RUN apt install -y openssh-server 

# UTF-8 locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create nonroot user
ENV CONDA_DIR=/opt/conda
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
   mkdir -p $CONDA_DIR && \
   chown $NB_USER:$NB_GID $CONDA_DIR && \
   chmod -R 777 $CONDA_DIR

ENV HOME=/home/$NB_USER


# ====== NONROOT ======

USER $NB_UID
WORKDIR /tmp

RUN setfacl -PRdm u::rwx,g::rwx,o::rwx ${CONDA_DIR}
RUN setfacl -PRdm u::rwx,g::rwx,o::rwx ${HOME}

# Install Python
ENV PATH="$CONDA_DIR/bin:${PATH}"
RUN wget -nv https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \ 
             bash miniconda.sh -f -b -p $CONDA_DIR && \
             rm -f miniconda.sh
RUN conda config --add channels conda-forge

# Generaul ML tools
RUN conda install \ 
           numpy scipy pandas gensim scikit-learn scikit-image \
           ujson line_profiler matplotlib \
           xgboost joblib lxml h5py tqdm lightgbm lime \ 
           scikit-image tensorboardX plotly graphviz seaborn
RUN pip install tables sharedmem

# Basic computation frameworks
RUN pip install torch==2.0.1 --index-url https://download.pytorch.org/whl/cu118
RUN conda install tensorflow

# NLP tools
RUN conda install -c conda-forge nltk
RUN pip install transformers
RUN pip install -U pymystem3 # && python -c "import pymystem3 ; pymystem3.Mystem()"

# CV tools
RUN pip install torchvision --index-url https://download.pytorch.org/whl/cu118

# Jupyterlab
RUN conda install -c conda-forge jupyterlab
RUN conda install -c conda-forge nb_conda_kernels
RUN conda install -c conda-forge jupyter_contrib_nbextensions
RUN conda install -c conda-forge ipywidgets


# ==== Finalizing ====
VOLUME ["/notebook", "$HOME/jupyter/certs"]
WORKDIR /notebook

COPY --chown=$NB_UID:$NB_GID --chmod=777 test_scripts $HOME/test_scripts
COPY --chown=$NB_UID:$NB_GID --chmod=777 jupyter $HOME/jupyter

# RUN chmod -R 777 $CONDA_DIR
RUN chmod -R 777 $HOME

COPY --chmod=777 entrypoint.sh /entrypoint.sh
COPY --chmod=777 hashpwd.py /hashpwd.py

ENV JUPYTER_CONFIG_DIR="${HOME}/jupyter"
ENV JUPYTER_RUNTIME_DIR="${HOME}/jupyter/run"
ENV JUPYTER_DATA_DIR="${HOME}/jupyter/data"

EXPOSE 8888
EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "jupyter", "lab", "--ip=0.0.0.0", "--allow-root" ]
