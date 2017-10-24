FROM nginx:latest
MAINTAINER Dobedobedo

RUN apt-get update && apt-get -y install \
	python-certbot-nginx \
	cron \
	&& rm -rf /var/lib/apt/lists/*

# Schedule Let's encrypt renewal
COPY ./certbot-renew.sh /etc/cron.daily/
RUN chmod +x /etc/cron.daily/certbot-renew.sh

VOLUME /etc/nginx/conf.d
VOLUME /usr/share/nginx/html
VOLUME /etc/letsencrypt/

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]