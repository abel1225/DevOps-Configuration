FROM golang:1.4

RUN apt-get update
RUN apt-get install -y vim bash golang
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

ENV GOPATH /gopath
ENV CODISLABS ${GOPATH}/src/github.com/CodisLabs  #存放Codis源码目录
ENV CODIS  ${CODISLABS}/codis
ENV GOX    ${GOPATH}/src/golang.org/x
ENV PATH   ${GOPATH}/bin:${PATH}:${CODIS}/bin

WORKDIR ${GOX}
RUN git clone https://github.com/golang/net.git  #获取gonet源码

WORKDIR ${CODISLABS}
RUN git clone https://github.com/CodisLabs/codis.git #获取codis源码

WORKDIR ${CODIS}
RUN git checkout release3.0  #基于codis3.0release版本构建

WORKDIR ${CODIS}
RUN make

WORKDIR /codis