FROM denoland/deno:alpine

WORKDIR /app

USER deno

COPY server.ts .
RUN deno cache server.ts

EXPOSE 8080

CMD ["run", "--allow-net", "server.ts"]
