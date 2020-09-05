FROM nginx:1.16-alpine
MAINTAINER David Hutchinson <djch-biigle@hutchhome.co.uk>

ADD .docker/vhost.conf /etc/nginx/conf.d/default.conf
