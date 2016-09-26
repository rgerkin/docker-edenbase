# EDeN dependencies docker container
#
# VERSION       0.1.0

FROM ubuntu:14.04

MAINTAINER Daniel Maticzka, maticzkd@informatik.uni-freiburg.de

ENV DEBIAN_FRONTEND noninteractive

ADD requirements.txt .

# requests: system level package has a bug that makes installing from requirements.txt fail
# weblogo installation from requirements.txt complains about missing numpy, so install beforehand
# scikit-learn installation from requirements.txt complains about missing scipy, so install beforehand
RUN apt-get -qq update && \
    apt-get install --no-install-recommends -y apt-transport-https \
    python3-dev libc-dev python3-pip gfortran libfreetype6-dev libpng-dev python-openbabel pkg-config \
    build-essential libblas-dev liblapack-dev git-core wget software-properties-common python3-pygraphviz \
    libopenbabel-dev swig libjpeg62-dev && \
    add-apt-repository ppa:bibi-help/bibitools && add-apt-repository ppa:j-4/vienna-rna && \
    apt-get -qq update && \
    apt-get install --no-install-recommends -y rnashapes vienna-rna && \
    pip install distribute --upgrade && \
    pip install "requests==2.7.0" "numpy==1.8.0" "scipy==0.14.0" && \
    pip install -r requirements.txt && \
    pip install "jupyter==1.0.0" && \
    apt-get remove -y --purge libzmq-dev software-properties-common libc-dev libreadline-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

## from jupyter documentation
# Add Tini. Tini operates as a process subreaper for jupyter. This prevents
# kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

RUN mkdir /export
EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--notebook-dir=/export/"]
