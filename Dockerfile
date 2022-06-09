FROM ruby:3.1.2-slim

ENV ROOT="/app" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

WORKDIR ${ROOT}

RUN set -ex \
  && apt-get update \
  && apt-get install -y curl gnupg vim imagemagick\
  && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs yarn default-libmysqlclient-dev build-essential shared-mime-info libvips libidn11-dev \
  && gem install bundler

COPY Gemfile ${ROOT}
COPY Gemfile.lock ${ROOT}

RUN bundle install

COPY . ${ROOT}

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
