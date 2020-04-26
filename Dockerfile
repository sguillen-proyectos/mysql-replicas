FROM mysql:5.7
LABEL maintainer=github.com/donkeysharp

# Temporal for development only
RUN apt update && \
    apt install -y procps

COPY scripts/wrapper.sh /usr/bin/wrapper.sh
RUN chmod 755 /usr/bin/wrapper.sh

ENTRYPOINT ["/usr/bin/wrapper.sh"]
CMD ["master"]
