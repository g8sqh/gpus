FROM arm64v8/nginx:alpine
MAINTAINER Martin Zurowietz <martin@cebitec.uni-bielefeld.de>

ADD .docker/vhost.conf /etc/nginx/conf.d/default.conf
