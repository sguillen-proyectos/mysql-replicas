FROM nginx:alpine
LABEL maintainer=@donkeysharp

RUN ln -sf /dev/stdout /var/log/nginx/mysql_access.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY mysql-loadbalancer.conf /etc/nginx/mysql-loadbalancer.conf
