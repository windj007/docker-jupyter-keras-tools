FROM nvidia/cuda:8.0-cudnn6-devel

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update
RUN apt-get install -yqq build-essential libbz2-dev libssl-dev libreadline-dev \
                         libsqlite3-dev tk-dev libpng-dev libfreetype6-dev git \
                         cmake wget gfortran libatlas-base-dev libatlas-dev \
                         libatlas3-base libhdf5-dev libxml2-dev libxslt-dev \
                         zlib1g-dev pkg-config curl graphviz liblapacke-dev \
                         locales

RUN curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
ENV PYENV_ROOT /root/.pyenv
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN pyenv install 3.6.0
RUN pyenv global 3.6.0

RUN pip  install -U pip
RUN python -m pip install -U cython
RUN python -m pip install -U numpy # thanks to libatlas-base-dev (base! not libatlas-dev), it will link to atlas
RUN python -m pip install -U jupyter scipy pandas nltk gensim sklearn theano tensorflow-gpu==1.3.0 \
        annoy git+https://github.com/fchollet/keras ujson line_profiler tables sharedmem matplotlib
RUN python -m pip install -U h5py lxml git+https://github.com/openai/gym sacred git+https://github.com/marcotcr/lime \
        plotly pprofile mlxtend fitter mpld3 \
        jupyter_nbextensions_configurator jupyter_contrib_nbextensions==0.2.4 fasttext \
        imbalanced-learn forestci category_encoders hdbscan seaborn networkx joblib eli5 \
        pydot graphviz dask[complete] opencv-python keras-vis pandas-profiling \
        git+https://github.com/windj007/libact/#egg=libact \
        git+https://github.com/IINemo/active_learning_toolbox \
        scikit-image http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl \
        torchvision pymorphy2[fast] pymorphy2-dicts-ru tqdm tensorboardX patool skorch
RUN python -m pip install imgaug
RUN pip install -U pymystem3 # && python -c "import pymystem3 ; pymystem3.Mystem()"

RUN pyenv rehash

RUN jupyter contrib nbextension install --system && \
    jupyter nbextensions_configurator enable --system && \
    jupyter nbextension enable --py --sys-prefix widgetsnbextension

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

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN ln -s /usr/local/cuda-8.0/targets/x86_64-linux/lib/stubs/libcuda.so /usr/lib/x86_64-linux-gnu/libcuda.so.1
RUN pip install -U tensorflow-gpu==1.3.0

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
