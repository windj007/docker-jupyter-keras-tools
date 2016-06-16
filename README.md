# docker-jupyter-keras-tools
Dockerized version of Jupyter with installed Keras, TensorFlow, Theano, etc

## Run

This by default enables all the devices.

    docker run -ti --rm \
        $(for d in /dev/nvidia* ; do echo -n "--device=$d " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcuda.* ; do echo -n "-v $f:$f " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcudnn.* ; do echo -n "-v $f:$f " ; done) \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        windj007/docker-jupyter-keras-tools

After that, jupyter notebook will be available at http://<hostname>:8888/.
        
        
## Test

### Theano

    docker run -ti --rm \
        $(for d in /dev/nvidia* ; do echo -n "--device=$d " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcuda.* ; do echo -n "-v $f:$f " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcudnn.* ; do echo -n "-v $f:$f " ; done) \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        windj007/docker-jupyter-keras-tools \
        /test_scripts/test_theano.py


### TensorFlow

    docker run -ti --rm \
        $(for d in /dev/nvidia* ; do echo -n "--device=$d " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcuda.* ; do echo -n "-v $f:$f " ; done) \
        $(for f in /usr/lib/x86_64-linux-gnu/libcudnn.* ; do echo -n "-v $f:$f " ; done) \
        -v `pwd`:/notebook \
        -p 8888:8888 \
        windj007/docker-jupyter-keras-tools \
        /test_scripts/test_tensorflow.py


## Build from Scratch

    git clone https://github.com/windj007/docker-jupyter-keras-tools
    cd docker-jupyter-keras-tools
    docker build -t windj007/docker-jupyter-keras-tools .
