
FROM bitwalker/alpine-elixir-phoenix:1.11.3 as builder


ENV appdir /opt/extendedservice
ENV MIX_ENV=prod \
REPLACE_OS_VARS=true \
APP_NAME=extendedservice \
RELEASE_NAME=extendedservice
WORKDIR ${appdir}
COPY . .
RUN apk update
RUN mix local.rebar --force
RUN mix local.hex --force 
RUN mix archive.install hex phx_new 1.5.7
RUN mix clean \
  && mix deps.get  \
  && mix compile \
  && cd /opt/extendedservice \
  && mix phx.digest \
  && mix release ${RELEASE_NAME} 

FROM alpine:3.12.3
EXPOSE 4000
EXPOSE 4369
RUN apk update
RUN apk add --no-cache bash openssl ncurses-libs
ENV appver=0.1.0 \
    APP_NAME=extendedservice \
    RELEASE_NAME=extendedservice \
    MIX_ENV=prod
WORKDIR /opt/extendedservice
COPY --from=builder /opt/${APP_NAME}/_build/${MIX_ENV}/rel/${RELEASE_NAME} ./
CMD ["bin/extendedservice", "start"]
