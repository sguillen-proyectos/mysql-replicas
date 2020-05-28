FROM golang:1.13-alpine as build
LABEL maintainer=@donkeysharp

RUN mkdir -p /opt/src
WORKDIR /opt/src

COPY src/go.mod /opt/src/go.mod
COPY src/go.sum /opt/src/go.sum

RUN go mod download

COPY ./src/ /opt/src/
RUN CGO_ENABLED=0 go build -o app main.go


FROM alpine:latest
LABEL maintainer=@donkeysharp
COPY --from=build /opt/src/app /usr/bin/app

RUN chmod 755 /usr/bin/app

EXPOSE 8000

CMD ["app"]
