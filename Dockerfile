FROM ubuntu:16.04

USER root

ARG branch_name
ENV env_branch_name=$branch_name

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* \ 
  && apt-get update -o Acquire::CompressionTypes::Order::=gz \
  && apt-get update \
  && apt-get install -y bzip2 ca-certificates wget curl software-properties-common nginx supervisor ffmpeg
  
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5AFA7A83
  
RUN tee "/etc/apt/sources.list.d/kurento.list" > /dev/null \
	&& add-apt-repository "deb [arch=amd64] http://ubuntu.openvidu.io/dev xenial kms6"

# 'maven-debian-helper' installs an old Maven version in Ubuntu 14.04 (Trusty), \
# so this ensures that the effective version is the one from 'maven'. \
	
RUN apt-get update \
    && apt-get install -y build-essential \
	  cmake \
	  debhelper \
	  default-jdk \
	  gdb \
	  git openssh-client \
	  maven \
	  pkg-config \
	  wget \
	  maven-debian-helper- \
	  libboost-dev \
	  libboost-filesystem-dev \
	  libboost-log-dev \
	  libboost-program-options-dev \
	  libboost-regex-dev \
	  libboost-system-dev \
	  libboost-test-dev \
	  libboost-thread-dev \
	  libevent-dev \
	  libglib2.0-dev \
	  libglibmm-2.4-dev \
	  libopencv-dev \
	  libsigc++-2.0-dev \
	  libsoup2.4-dev \
	  libssl-dev \
	  libvpx-dev \
	  libxml2-utils \
	  uuid-dev \
	  gstreamer1.5-plugins-base \
	  gstreamer1.5-plugins-good \
	  gstreamer1.5-plugins-bad \
	  gstreamer1.5-plugins-ugly \
	  gstreamer1.5-libav \
	  gstreamer1.5-nice \
	  gstreamer1.5-tools \
	  gstreamer1.5-x \
	  libgstreamer1.5-dev \
	  libgstreamer-plugins-base1.5-dev \
	  libnice-dev \
	  openh264-gst-plugins-bad-1.5 \
	  openwebrtc-gst-plugins-dev \
	  kmsjsoncpp-dev \
	  ffmpeg 
	  
COPY checkout_script.sh .
#COPY settings.xml /usr/share/maven/conf/settings.xml
	
RUN git clone https://github.com/Kurento/kms-omni-build.git \
    && cd kms-omni-build/ \
	&& git submodule update --init --recursive \
	&& git submodule update --remote \
	&& REF=$env_branch_name \
	&& ../checkout_script.sh `pwd` $env_branch_name \
	&& TYPE=Debug \
	&& mkdir build-$TYPE \
	&& cd build-$TYPE/ \
	&& cmake -DCMAKE_BUILD_TYPE=$TYPE .. \
	&& make
	
COPY MediaElement.conf.ini kms-omni-build/kms-core/src/server/config/MediaElement.conf.ini
COPY SdpEndpoint.conf.json kms-omni-build/kms-core/src/server/config/SdpEndpoint.conf.json

CMD cd kms-omni-build/build-Debug \
    && kurento-media-server/server/kurento-media-server     --modules-path=.     --modules-config-path=./config     --conf-file=./config/kurento.conf.json     --gst-plugin-path=.
	
