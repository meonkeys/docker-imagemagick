#FIXME - here's how we'd create a slimmer Docker image: build and cleanup in one layer

#FROM ubuntu:18.04

#RUN apt-get update \
#  && apt-get -y dist-upgrade \
#  && sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list \
#  && apt-get update
#  && apt-get -y build-dep imagemagick libheif \
#  && apt-get install -y --no-install-recommends \
#    build-essential \
#    ca-certificates \
#    libltdl-dev \
#    libde265-dev \
#    wget \
#  && wget https://www.imagemagick.org/download/ImageMagick.tar.gz \
#  && wget https://github.com/strukturag/libheif/releases/download/v1.5.1/libheif-1.5.1.tar.gz \
#  && tar -xzf libheif-1.5.1.tar.gz \
#  && cd libheif-1.5.1 \
#  && ./configure \
#  && make \
#  && make install \
#  && cd ..
#  && tar -xzf ImageMagick.tar.gz \
#  && cd ImageMagick-7.0.8-68 \
#  && ./configure --with-heic \
#  && cd ImageMagick-7.0.8-68 \
#  && make \
#  && make install \
#  && ldconfig \
#  && apt-get -y autoremove --purge build-essential ca-certificates libltdl-dev wget libde265-dev \
#  && apt-get clean \
#  && rm -rf /var/lib/apt/lists/*
#  && rm -rf /tmp/* /var/tmp/*

#FIXME - splitting up steps is great for work-in-progress Docker images (or try `docker build --squash`)

FROM ubuntu:18.04

RUN apt-get update && apt-get -y dist-upgrade
RUN sed -i -- 's/# deb-src/deb-src/g' /etc/apt/sources.list \
  && apt-get update
RUN apt-get -y build-dep imagemagick libheif
RUN apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    libltdl-dev \
    libde265-0 \
    libde265-dev \
    wget

RUN wget https://www.imagemagick.org/download/ImageMagick.tar.gz \
  && wget https://github.com/strukturag/libheif/releases/download/v1.5.1/libheif-1.5.1.tar.gz \
  && tar -xzf ImageMagick.tar.gz \
  && tar -xzf libheif-1.5.1.tar.gz

# build libheif

RUN cd libheif-1.5.1 \
  && ./configure \
  && make -j6 \
  && make install

# build ImageMagick

RUN cd ImageMagick-7.0.8-68 \
  && ./configure --with-heic

# ImageMagick is 7.0.8-68, so exploded dir is "ImageMagick-7.0.8-68/"

# ldconfig - without, you get "identify: error while loading shared libraries: libMagickCore-7.Q16HDRI.so.6: cannot open shared object file: No such file or directory" after trying to run `identify --version`

RUN cd ImageMagick-7.0.8-68 \
  && make -j6 \
  && make install \
  && ldconfig

# TODO - abstract libheif and ImageMagick versions

# TODO - download specific versoin of ImageMagick source tarball

# TODO - take and confirm checksums for wget-downloaded files

# TODO - use long-form command-line switches, or document every one

# TODO - document timings for different steps and image sizes (this one is 1.5GB)

# TODO - preserve these tasks somewhere - maybe ../docker-snap-talk/docker-snap-talk-README.md.html or a separate file (I just want to keep track of the work I put into this)

# Warn folks against random websites. For example, do not download https://www.snapfiles.com/downloads/imagemagick/dlimagemagick.html . Who knows WTF this is. There are ads for removing spyware on the same page.
