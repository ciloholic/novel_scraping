ARG RUBY_VERSION_ARG

FROM ruby:${RUBY_VERSION_ARG:-4}-alpine

ARG BUNDLER_VERSION_ARG

RUN apk add --no-cache bash build-base git less tzdata yaml-dev && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

WORKDIR /app

COPY Gemfile .

ENV LANG=ja_JP.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_SERVE_STATIC_FILES=true
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH $BUNDLE_BIN:$PATH
RUN gem update --system && \
    gem install --no-document bundler -v $BUNDLER_VERSION_ARG && \
    bundle config set force_ruby_platform true
