FROM ubuntu as base
RUN apt-get update && apt-get upgrade -y

FROM base as source
RUN apt-get install -y curl gcc make libtool autoconf automake automake1.11 unzip wget
RUN mkdir /tmp/c-icap
   
COPY ./c-icap/ /tmp/c-icap/c-icap/
COPY ./c-icap-modules /tmp/c-icap/c-icap-modules  

FROM source as build    
ARG SONAR_TOKEN

#install sonar scanner and build wrapper
RUN cd /opt && wget -O sonar.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.4.0.2170-linux.zip && unzip sonar.zip  
RUN cd /opt && wget -O build.zip https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && unzip build.zip

#build and scan c-icap
RUN cd /tmp/c-icap/c-icap &&  \
    autoreconf -i && \
    ./configure --prefix=/usr/local/c-icap && /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir build_wrapper_output_directory make install
        
#build and scan c-icap-modules
RUN cd /tmp/c-icap/c-icap-modules && \
    autoreconf -i && \
    ./configure --with-c-icap=/usr/local/c-icap --prefix=/usr/local/c-icap && /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir build_wrapper_output_directory make install && \
    echo >> /usr/local/c-icap/etc/c-icap.conf && echo "Include gw_rebuild.conf" >> /usr/local/c-icap/etc/c-icap.conf

    
FROM base AS ms-package-signing
RUN  apt-get update \
  && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*
  
RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb

FROM ms-package-signing AS dotnet-sdk 
RUN apt-get install -y apt-transport-https && \
  apt-get update && \
  apt-get install -y dotnet-sdk-3.1
