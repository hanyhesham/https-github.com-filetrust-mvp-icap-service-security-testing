FROM ubuntu as base
RUN apt-get update && apt-get upgrade -y

FROM base as source
RUN apt-get install -y curl gcc make libtool autoconf automake automake1.11 unzip wget
RUN mkdir /tmp/c-icap
   
COPY ./c-icap/ /tmp/c-icap/c-icap/
COPY ./c-icap-modules /tmp/c-icap/c-icap-modules  

FROM source as build    

#Install sonar scanner and build wrapper
RUN cd /opt && wget -O sonar.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.4.0.2170-linux.zip && unzip sonar.zip  
RUN cd /opt && wget -O build.zip https://sonarcloud.io/static/cpp/build-wrapper-linux-x86.zip && unzip build.zip

RUN cd /tmp/c-icap/c-icap &&  \
    autoreconf -i && \
    ./configure --prefix=/usr/local/c-icap && /opt/build-wrapper-linux-x86/build-wrapper-linux-x86-64 --out-dir build_wrapper_output_directory make install

RUN cd /tmp/c-icap/c-icap && /opt/sonar-scanner-4.4.0.2170-linux/bin/sonar-scanner -X -Dsonar.organization=hanyhesham   -Dsonar.projectKey=hanyhesham_https-github.com-filetrust-mvp-icap-service-security-testing   -Dsonar.sources=.   -Dsonar.cfamily.build-wrapper-output=build_wrapper_output_directory   -Dsonar.host.url=https://sonarcloud.io
