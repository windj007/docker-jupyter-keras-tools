FROM nvidia/cuda:8.0-cudnn5-devel

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update
RUN apt-get install -yqq python python-pip python-dev build-essential \
    git wget gfortran libatlas-base-dev libatlas-dev libatlas3-base libhdf5-dev \
    libfreetype6-dev libpng12-dev pkg-config libxml2-dev libxslt-dev \
    libboost-program-options-dev zlib1g-dev libboost-python-dev cmake

RUN pip install -U pip
RUN pip install -U cython
RUN pip install -U numpy # thanks to libatlas-base-dev (base! not libatlas-dev), it will link to atlas
RUN pip install -U jupyter scipy pandas nltk gensim sklearn theano tensorflow \
        annoy git+https://github.com/fchollet/keras ujson line_profiler tables sharedmem matplotlib
RUN pip install -U h5py lxml git+https://github.com/openai/gym sacred git+https://github.com/marcotcr/lime \
        plotly pprofile mlxtend vowpalwabbit fitter mpld3 \
        jupyter_nbextensions_configurator jupyter_contrib_nbextensions fasttext \
        imbalanced-learn forestci category_encoders hdbscan seaborn networkx joblib
RUN jupyter contrib nbextension install --system && \
    jupyter nbextensions_configurator enable --system

RUN git clone --recursive https://github.com/dmlc/xgboost /tmp/xgboost && \
    cd /tmp/xgboost && \
    make && \
    cd python-package && \
    python setup.py install

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

RUN pip uninstall -y tensorflow && \
    pip install -U tensorflow-gpu

EXPOSE 8888
VOLUME ["/notebook", "/jupyter/certs"]
WORKDIR /notebook

ADD test_scripts /test_scripts
ADD jupyter /jupyter
COPY entrypoint.sh /entrypoint.sh
COPY hashpwd.py /hashpwd.py

ENV JUPYTER_CONFIG_DIR="/jupyter"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["jupyter", "notebook", "--ip=0.0.0.0"]
