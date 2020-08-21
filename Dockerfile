FROM ruby:2.7.1-alpine3.10

RUN apk add --no-cache build-base ca-certificates curl git nginx tzdata sudo postgresql-client postgresql-dev nodejs yarn openssh
RUN gem install bundler -v 2.1.4
RUN bundle config silence_root_warning 1

ENV APP_ROOT /deployqa
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

ADD Gemfile $APP_ROOT
ADD Gemfile.lock $APP_ROOT
RUN bundle install

ADD package.json $APP_ROOT
ADD yarn.lock $APP_ROOT
RUN yarn

ADD . $APP_ROOT
RUN bundle exec rake assets:precompile
