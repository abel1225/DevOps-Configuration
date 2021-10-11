FROM nginx:v1.21.1
MAINTAINER abel <abel@qq.com>
RUN rm -rf /usr/share/nginx/html/*
ADD app/iview-admin/public.tar /usr/share/nginx/html
WORKDIR /usr/share/nginx/html