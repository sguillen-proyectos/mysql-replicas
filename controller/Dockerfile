FROM alpine:latest

RUN apk update && \
    apk add mysql-client vim bash nmap

RUN mkdir -p /opt/scripts/

COPY controller.sh /usr/bin/controller.sh
COPY *.sql /opt/scripts/
RUN chmod +x /usr/bin/controller.sh

CMD ["tail", "-f", "/dev/null"]
