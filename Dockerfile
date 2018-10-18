FROM golang:1.11.1-alpine3.7

RUN apk --no-cache add git curl
RUN go get golang.org/x/tools/cmd/goimports

RUN mkdir -p /go/src/github.com/ewilde/kms-template/

WORKDIR /go/src/github.com/ewilde/kms-template

COPY . .

RUN goimports -l -d $(find . -type f -name '*.go' -not -path "./vendor/*") \
    && CGO_ENABLED=0 GOOS=linux go build --ldflags "-s -w" -a -installsuffix cgo -o kms-template .

FROM alpine:3.7

RUN addgroup -g 1000 -S app \
    && adduser -u 1000 -S -g app app && apk --no-cache add \
    ca-certificates

WORKDIR /home/app

COPY --from=0 /go/src/github.com/ewilde/kms-template/kms-template .
RUN chown -R app:app ./
RUN mkdir -p  /run/secrets ; chown -R app:app /run/secrets
VOLUME ["/run/secrets"]

USER app

CMD ./kms-template
