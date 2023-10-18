FROM ubuntu:20.04

ENV SOFT /soft

ARG DEBIAN_FRONTEND=noninteractive

ARG SAMTOOLSVER=1.18
ARG HSTLIBSVER=1.18
ARG LIBDEFLATEVER=1.18

ARG BCFTOOLSVER=1.18
ARG VCFTOOLSVER=0.1.16

RUN apt-get update

WORKDIR $SOFT

RUN apt-get install -y libncurses5-dev \
 libbz2-dev \
 liblzma-dev \
 libcurl4-gnutls-dev \
 zlib1g-dev \
 gcc \
 g++ \
 wget \
 make \
 cmake \
 pkg-config \
 gawk

RUN apt-get autoclean && rm -rf /var/lib/apt/lists/*

#htslib
RUN wget -q https://github.com/samtools/htslib/releases/download/${HSTLIBSVER}/htslib-${HSTLIBSVER}.tar.bz2 && \
    tar -xjf htslib-${HSTLIBSVER}.tar.bz2 && \
    rm htslib-${HSTLIBSVER}.tar.bz2 && \
    cd htslib-${HSTLIBSVER} && \
    ./configure && \
    make && \
    make install

#libdeflate
RUN wget https://github.com/ebiggers/libdeflate/archive/v${LIBDEFLATEVER}/${LIBDEFLATEVER}.tar.gz && \
  tar -xzf ${LIBDEFLATEVER}.tar.gz && \
  rm -v ${LIBDEFLATEVER}.tar.gz && \
  cd libdeflate-${LIBDEFLATEVER} && \
  mkdir build && \
  cmake -B build && cmake --build build && \
  cd build && \
  make && \
  make install

#samtools
RUN wget https://github.com/samtools/samtools/releases/download/${SAMTOOLSVER}/samtools-${SAMTOOLSVER}.tar.bz2 && \
 tar -xjf samtools-${SAMTOOLSVER}.tar.bz2 && \
 rm samtools-${SAMTOOLSVER}.tar.bz2 && \
 cd samtools-${SAMTOOLSVER} && \
 ./configure --with-libdeflate=${SOFT}/libdeflate-${LIBDEFLATEVER}/build --with-htslib=${SOFT}/htslib-${HSTLIBSVER} && \
 make && \
 make install

#vcftools
RUN wget https://github.com/vcftools/vcftools/releases/download/v${VCFTOOLSVER}/vcftools-${VCFTOOLSVER}.tar.gz && \
  tar -xzf vcftools-${VCFTOOLSVER}.tar.gz && \
  rm vcftools-${VCFTOOLSVER}.tar.gz && \
  cd vcftools-${VCFTOOLSVER} && \
  ./configure && \
  make && \
  make install

#bcftools
RUN wget https://github.com/samtools/bcftools/releases/download/${BCFTOOLSVER}/bcftools-${BCFTOOLSVER}.tar.bz2 && \
  tar -xjf bcftools-${BCFTOOLSVER}.tar.bz2 && \
  rm -v bcftools-${BCFTOOLSVER}.tar.bz2 && \
  cd bcftools-${BCFTOOLSVER} && \
  make && \
  make install

RUN rm -rf *