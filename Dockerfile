# server
FROM node:10.13-alpine as server


WORKDIR /app

COPY ./misc /misc
COPY server/ .
COPY docker/production/api /prod
COPY .git/ /.git
RUN sh /prod/docker-build.sh

# Client

FROM node:10.13-alpine as client

WORKDIR /app

COPY .git /.git
COPY client/ .
COPY misc/ /misc

RUN apk add --no-cache git

RUN rm -rf node_modules/

RUN npm install
RUN npm run build


FROM centos:7
RUN curl -sL https://rpm.nodesource.com/setup_10.x | bash - && yum install -y epel-release && yum install -y nodejs nginx gettext
WORKDIR /app
COPY --from=server /app /app
RUN rm -rf node_modules && npm update
COPY docker/production/nginx/nginx.conf /client/nginx.conf
COPY --from=client /app /client
ENV APP_DOMAIN localhost
ENV USE_TEST_DATA 0
ENV USE_TEST_AUTH 0
ENV APP_COOKIE_SECRET verysecuresecret
EXPOSE 8080
COPY ./startup.sh .
RUN chmod +x startup.sh
#CMD envsubst '\$APP_DOMAIN' < /client/nginx.conf > /etc/nginx/nginx.conf && nginx -g 'daemon off;' & && npm start -- --config config.json
CMD ["./startup.sh"]
