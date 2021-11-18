FROM nvidia/cuda:11.3.0-devel-ubuntu20.04

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update

RUN apt-get install -yqq curl

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libbz2-dev \
                         libssl-dev libreadline-dev \
                         libsqlite3-dev tk-dev libpng-dev libfreetype6-dev git \
                         cmake wget gfortran \
                         libatlas3-base libhdf5-dev libxml2-dev libxslt-dev \
                         zlib1g-dev pkg-config graphviz \
                         locales nodejs libffi-dev liblapacke-dev libblas-dev liblapack-dev liblzma-dev

ENV PATH="/opt/conda/bin:${PATH}"
ARG PATH="/opt/conda/bin:${PATH}"
RUN wget -nv https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh -O miniconda.sh && \ 
             bash miniconda.sh -b -p /opt/conda

RUN conda install -c conda-forge jupyterlab
RUN conda install -c conda-forge nb_conda_kernels
RUN conda install -c conda-forge jupyter_contrib_nbextensions

RUN conda install pip
RUN python -m pip install -U cython

RUN pip install torch==1.10.0+cu113 torchvision==0.11.1+cu113 torchaudio==0.10.0+cu113 \ 
                -f https://download.pytorch.org/whl/cu113/torch_stable.html
RUN pip install tensorflow-gpu

RUN pip install numpy scipy pandas gensim sklearn scikit-image \
           annoy ujson line_profiler tables sharedmem matplotlib \
           xgboost joblib lxml h5py tqdm lightgbm lime \ 
           scikit-image tensorboardX plotly graphviz seaborn

RUN pip install transformers allennlp nltk
#RUN pip install grpcio git+https://github.com/IINemo/isanlp.git \
RUN pip install deeppavlov --no-deps
RUN pip install -U pymystem3 # && python -c "import pymystem3 ; pymystem3.Mystem()"
RUN pip install pymorphy2[fast] pymorphy2-dicts-ru

RUN conda install ipykernel

RUN conda init && curl -sL https://deb.nodesource.com/setup_16.x | bash
RUN conda init && apt-get install -y nodejs

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
