FROM ruby:3.0.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev imagemagick

RUN gem install bundler

WORKDIR hexa_app
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
