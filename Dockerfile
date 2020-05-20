FROM mysql:5.7
LABEL maintainer=github.com/donkeysharp

# Temporal for development only
RUN apt update && \
    mkdir -p /opt/mysql/conf && \
    apt install -y gettext-base && \
    apt install -y procps vim less net-tools

RUN mkdir -p /opt/mysql/conf/sql

COPY conf/* /opt/mysql/conf/
COPY scripts/sql/* /opt/mysql/conf/sql/

COPY scripts/wrapper.sh /usr/bin/wrapper.sh
RUN chmod 755 /usr/bin/wrapper.sh

ENTRYPOINT ["/usr/bin/wrapper.sh"]
CMD ["master"]
