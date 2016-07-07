FROM nvidia/cuda:7.5-cudnn5-devel

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update
RUN apt-get install -yqq python python-pip python-dev build-essential \
    git wget gfortran libatlas-dev libatlas3-base libhdf5-dev
RUN update-alternatives --set libblas.so.3 /usr/lib/atlas-base/atlas/libblas.so.3
RUN update-alternatives --set liblapack.so.3 /usr/lib/atlas-base/atlas/liblapack.so.3

RUN pip install -U jupyter numpy scipy pandas nltk gensim sklearn theano \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl
RUN pip install -U annoy keras ujson line_profiler tables h5py sharedmem

EXPOSE 8888
VOLUME ["/notebook"]
WORKDIR /notebook

ADD test_scripts /test_scripts

ENV THEANO_FLAGS=mode=FAST_RUN,device=gpu,floatX=float32

CMD jupyter notebook --ip=0.0.0.0
