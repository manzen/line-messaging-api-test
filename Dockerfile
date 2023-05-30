FROM ruby:2.7.1

ENV ROOT="/app" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

WORKDIR ${ROOT}

RUN set -ex \
  && apt-get update \
  && apt-get install -y curl gnupg vim imagemagick\
  && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y nodejs yarn default-libmysqlclient-dev build-essential \
  && gem install bundler \
  && npm install -g @2fd/graphdoc

COPY Gemfile ${ROOT}
COPY Gemfile.lock ${ROOT}

RUN bundle install

RUN set -ex \
  && bundle exec rails assets:precompile

COPY . ${ROOT}

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
