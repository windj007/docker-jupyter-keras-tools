FROM nvidia/cuda:7.5-cudnn5-devel

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update
RUN apt-get install -yqq python python-pip python-dev build-essential \
    git wget gfortran libatlas-base-dev libatlas-dev libatlas3-base libhdf5-dev \
    libfreetype6-dev libpng12-dev pkg-config libxml2-dev libxslt-dev \
    libboost-program-options-dev zlib1g-dev libboost-python-dev

RUN pip install -U cython
RUN pip install -U numpy # thanks to libatlas-base-dev (base! not libatlas-dev), it will link to atlas
RUN pip install -U jupyter scipy pandas nltk gensim sklearn theano \
        https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.10.0-cp27-none-linux_x86_64.whl \
        annoy git+https://github.com/fchollet/keras ujson line_profiler tables sharedmem matplotlib
RUN pip install -U h5py lxml git+https://github.com/openai/gym sacred git+https://github.com/marcotcr/lime \
        plotly pprofile mlxtend vowpalwabbit

RUN git clone --recursive https://github.com/dmlc/xgboost /tmp/xgboost && \
    cd /tmp/xgboost && \
    make && \
    cd python-package && \
    python setup.py install

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
