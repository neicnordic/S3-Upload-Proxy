FROM golang:1.13.4-alpine3.10
RUN apk add --no-cache git
COPY . .
ENV GO111MODULE=on
ENV GOPATH=$PWD
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN go build -ldflags "-extldflags -static" -o ./build/s3proxy main.go
RUN echo "nobody:x:65534:65534:nobody:/:/sbin/nologin" > passwd

FROM scratch
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=0 /go/build/s3proxy s3proxy
COPY --from=0 /go/passwd /etc/passwd
USER 65534
EXPOSE 8000
ENTRYPOINT [ "/s3proxy" ]
