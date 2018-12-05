FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update

RUN apt-get install -yqq curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash

RUN apt-get install -yqq build-essential libbz2-dev libssl-dev libreadline-dev \
                         libsqlite3-dev tk-dev libpng-dev libfreetype6-dev git \
                         cmake wget gfortran libatlas-base-dev libatlas-dev \
                         libatlas3-base libhdf5-dev libxml2-dev libxslt-dev \
                         zlib1g-dev pkg-config graphviz liblapacke-dev \
                         locales nodejs

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pyenv install 3.6.7
RUN pyenv global 3.6.7

RUN pip  install -U pip
RUN python -m pip install -U cython
RUN python -m pip install -U numpy # thanks to libatlas-base-dev (base! not libatlas-dev), it will link to atlas

RUN python -m pip install scipy pandas nltk gensim sklearn tensorflow-gpu \
        annoy keras ujson line_profiler tables sharedmem matplotlib torch torchvision

RUN pip install git+https://github.com/pybind/pybind11.git 
RUN pip install nmslib
RUN python -m pip install -U \
        h5py lxml git+https://github.com/openai/gym sacred git+https://github.com/marcotcr/lime \
        plotly pprofile mlxtend fitter mpld3 \
        git+https://github.com/facebookresearch/fastText.git \
        imbalanced-learn forestci category_encoders hdbscan seaborn networkx joblib eli5 \
        pydot graphviz dask[complete] opencv-python keras-vis pandas-profiling \
        git+https://github.com/windj007/libact/#egg=libact \
        git+https://github.com/IINemo/active_learning_toolbox \
        scikit-image pymorphy2[fast] pymorphy2-dicts-ru tqdm tensorboardX patool \
        skorch fastcluster \
        xgboost imgaug grpcio git+https://github.com/IINemo/isanlp.git

RUN pip install -U pymystem3 # && python -c "import pymystem3 ; pymystem3.Mystem()"

RUN python -m pip install -U jupyter jupyterlab \
        jupyter_nbextensions_configurator jupyter_contrib_nbextensions==0.2.4

RUN pyenv rehash

RUN jupyter contrib nbextension install --system && \
    jupyter nbextensions_configurator enable --system && \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension && \
    jupyter labextension install @jupyterlab/toc && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager

RUN git clone --recursive https://github.com/Microsoft/LightGBM /tmp/lgbm && \
    cd /tmp/lgbm && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cd ../python-package && \
    python setup.py install && \
    cd /tmp && \
    rm -r /tmp/lgbm

RUN git clone https://code.googlesource.com/re2 /tmp/re2 && \
    cd /tmp/re2 && \
    make CFLAGS='-fPIC -c -Wall -Wno-sign-compare -O3 -g -I.' && \
    make test && \
    make install && \
    make testinstall && \
    ldconfig && \
    pip install -U fb-re2

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

EXPOSE 8888
VOLUME ["/notebook", "/jupyter/certs"]
WORKDIR /notebook

ADD test_scripts /test_scripts
ADD jupyter /jupyter
COPY entrypoint.sh /entrypoint.sh
COPY hashpwd.py /hashpwd.py

ENV JUPYTER_CONFIG_DIR="/jupyter"

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "jupyter", "notebook", "--ip=0.0.0.0", "--allow-root" ]
