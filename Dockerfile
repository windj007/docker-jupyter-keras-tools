FROM nvidia/cuda:8.0-cudnn5-devel

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update
RUN apt-get install -yqq python3 python3-pip python3-dev build-essential \
    git wget gfortran libatlas-base-dev libatlas-dev libatlas3-base libhdf5-dev \
    libfreetype6-dev libpng12-dev pkg-config libxml2-dev libxslt-dev \
    libboost-program-options-dev zlib1g-dev libboost-python-dev cmake

#alias python=python3
RUN pip3 install -U pip
RUN pip3 install -U cython
RUN pip3 install -U numpy # thanks to libatlas-base-dev (base! not libatlas-dev), it will link to atlas
RUN pip3 install -U jupyter scipy pandas nltk gensim sklearn theano tensorflow-gpu \
        annoy git+https://github.com/fchollet/keras ujson line_profiler tables sharedmem matplotlib
RUN pip3 install -U h5py lxml git+https://github.com/openai/gym sacred git+https://github.com/marcotcr/lime \
        plotly pprofile mlxtend fitter mpld3 \
        jupyter_nbextensions_configurator jupyter_contrib_nbextensions==0.2.4 fasttext \
        imbalanced-learn forestci category_encoders hdbscan seaborn networkx joblib eli5

# PROBLEM: Vowpalwabbit cannot be built
# RUN pip3 install -U vowpalwabbit
#

RUN jupyter contrib nbextension install --system && \
    jupyter nbextensions_configurator enable --system && \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension

RUN git clone --recursive https://github.com/dmlc/xgboost /tmp/xgboost && \
    cd /tmp/xgboost && \
    make && \
    cd python-package && \
    python3 setup.py install

RUN git clone --recursive https://github.com/Microsoft/LightGBM /tmp/lgbm && \
    cd /tmp/lgbm && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cd ../python-package && \
    python3 setup.py install && \
    cd /tmp && \
    rm -r /tmp/lgbm
    
RUN ln -s /usr/local/cuda-8.0/targets/x86_64-linux/lib/stubs/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1
RUN pip3 install -U tensorflow-gpu

EXPOSE 8888
VOLUME ["/notebook", "/jupyter/certs"]
WORKDIR /notebook

ADD test_scripts /test_scripts
ADD jupyter /jupyter
COPY entrypoint.sh /entrypoint.sh
COPY hashpwd.py /hashpwd.py

ENV JUPYTER_CONFIG_DIR="/jupyter"

ENTRYPOINT ["/entrypoint.sh"]
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]
