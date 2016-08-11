#!/bin/bash

if [ ! -z "$HASHED_PASSWORD" ]
then
    sed -i "s/# c.NotebookApp.password = u''/c.NotebookApp.password = u'$HASHED_PASSWORD'/g" /jupyter/jupyter_notebook_config.py
fi

if [ ! -z "$SSL" ]
then
    sed -i \
        -e "s/# c.NotebookApp.certfile/c.NotebookApp.certfile/g" \
        -e "s/# c.NotebookApp.keyfile/c.NotebookApp.keyfile/g" \
        /jupyter/jupyter_notebook_config.py
fi

if [ -z "$THEANO_FLAGS" ]
then
    export THEANO_FLAGS="mode=FAST_RUN,device=gpu,floatX=float32"
fi

$@
