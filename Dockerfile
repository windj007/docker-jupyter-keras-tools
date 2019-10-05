FROM nvidia/cuda:10.1-devel-ubuntu18.04

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update

RUN apt-get install -yqq curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libbz2-dev \
                         libssl-dev libreadline-dev \
                         libsqlite3-dev tk-dev libpng-dev libfreetype6-dev git \
                         cmake wget gfortran \
                         libatlas3-base libhdf5-dev libxml2-dev libxslt-dev \
                         zlib1g-dev pkg-config graphviz \
                         locales nodejs libffi-dev liblapacke-dev libblas-dev liblapack-dev

ENV PYENV_ROOT /opt/.pyenv
RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
ENV PATH /opt/.pyenv/shims:/opt/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pyenv install 3.7.4
RUN pyenv global 3.7.4

RUN pip  install -U pip
RUN python -m pip install -U cython

RUN pip install tensorflow-gpu==1.14
RUN pip install torch==1.2.0

RUN pip install git+https://github.com/rkern/line_profiler.git
RUN python -m pip install  \
           numpy scipy pandas gensim sklearn \
           annoy keras ujson line_profiler tables sharedmem matplotlib \
           xgboost joblib lxml h5py tqdm

RUN pip install transformers allennlp grpcio \
        git+https://github.com/IINemo/isanlp.git nltk \
        git+https://github.com/facebookresearch/fastText.git
RUN pip install deeppavlov --no-deps
RUN pip install -U pymystem3 # && python -c "import pymystem3 ; pymystem3.Mystem()"
#RUN pip install pymorphy2[fast] pymorphy2-dicts-ru

RUN python -m pip install -U \
        git+https://github.com/pybind/pybind11.git nmslib \
        git+https://github.com/openai/gym \
        sacred git+https://github.com/marcotcr/lime \
        plotly pprofile mlxtend fitter mpld3 \
        imbalanced-learn forestci category_encoders hdbscan seaborn networkx eli5 \
        pydot graphviz dask[complete] opencv-python keras-vis pandas-profiling \
        git+https://github.com/IINemo/active_learning_toolbox \
        scikit-image tensorboardX patool \
        skorch fastcluster imgaug torchvision \
        git+https://github.com/IINemo/libact.git

RUN python -m pip install -U jupyter jupyterlab \
        jupyter_nbextensions_configurator jupyter_contrib_nbextensions

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
RUN chmod 777 /jupyter
COPY entrypoint.sh /entrypoint.sh
COPY hashpwd.py /hashpwd.py

ENV JUPYTER_CONFIG_DIR="/jupyter"

ENTRYPOINT ["/entrypoint.sh"]
CMD [ "jupyter", "notebook", "--ip=0.0.0.0", "--allow-root" ]
