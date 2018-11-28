# Grab the latest version from here: https://www.apollographql.com/docs/engine/proxy/proxy-release-notes.html
FROM gcr.io/mdg-public/engine:2018.02-50-gef2fc6d4e as engine

# Include your app-specific engine config file, renamed to config.json
COPY config.json /config.json

# Start up Engine with the provided config
ENTRYPOINT ["/engineproxy_linux_amd64", "-config", "/config.json"]
