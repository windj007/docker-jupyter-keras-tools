FROM nvidia/cuda:7.5-cudnn5-devel

MAINTAINER Roman Suvorov windj007@gmail.com

RUN apt-get clean && apt-get update
RUN apt-get install -yqq python python-pip python-dev build-essential \
    git wget libopenblas-dev gfortran

RUN pip install -U jupyter sklearn theano \
    https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl

EXPOSE 8888
VOLUME ["/notebook"]
WORKDIR /notebook

ENTRYPOINT ["jupyter", "notebook"]
