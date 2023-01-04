FROM node:19-alpine3.16 as base

RUN set -eux; \
    apk update; \
    apk add \
        alpine-sdk \
        python3

RUN npm install --global --quiet npm truffle ganache

FROM base as truffle

RUN mkdir -p /app
WORKDIR /app

COPY package.json /app
COPY package-lock.json /app

RUN npm install --quiet

COPY truffle-config.js /app
COPY contracts /app/contracts
COPY migrations /app/migrations/
COPY test /app/test/

CMD ["truffle", "version"]

FROM base as ganache

RUN mkdir -p /home
WORKDIR /home
EXPOSE 8545

ENTRYPOINT ["ganache", "--host 0.0.0.0"]
