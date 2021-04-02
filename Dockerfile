FROM crystallang/crystal:latest-alpine

WORKDIR /opt/app

RUN apk add -u sqlite-static sqlite-dev

# Bundle app source
COPY . .

RUN shards install --ignore-crystal-version

RUN crystal build server.cr --release

CMD ./server -p 80