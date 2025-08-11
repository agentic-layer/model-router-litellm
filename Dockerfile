FROM ghcr.io/berriai/litellm:main-stable

WORKDIR /app

EXPOSE 4000/tcp

CMD ["--port", "4000", "--config", "config.yaml"]