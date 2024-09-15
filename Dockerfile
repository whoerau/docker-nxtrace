FROM golang:alpine3.20 AS binarybuilder
RUN apk --no-cache --no-progress add \
    gcc git musl-dev

ENV CGO_ENABLED=0
ARG VERSION
ARG TARGETARCH
WORKDIR /home

RUN git clone https://github.com/nxtrace/NTrace-core.git &&\
    cd NTrace-core && VERSION=$(git describe --tags `git rev-list --tags --max-count=1`) &&\
    git checkout $VERSION &&\
    go build -o nxtrace -trimpath -ldflags="-X 'github.com/nxtrace/NTrace-core/config.Version=${VERSION}' \
                                            -X 'main.version=${VERSION:1}' \
                                            -X 'main.arch=${TARGETARCH}' \
                                            -w -s"

FROM alpine:3.18

RUN apk --no-cache --no-progress add \
    ca-certificates \
    tzdata
ENV TZ="Asia/Shanghai"
RUN cp "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone 

WORKDIR /home
COPY --from=binarybuilder /home/NTrace-core/nxtrace ./nxtrace

# USER nobody

ENTRYPOINT ["/home/nxtrace"]
