# frozen_string_literal: true

source 'http://rubygems.org'
ruby '2.7.1'

gem 'bcrypt', '~> 3.1.16', platform: :ruby
gem 'fast_jsonapi'
gem 'graphql'
gem 'jwt'
gem 'pg'
gem 'pony'
gem 'pry'
gem 'rack-contrib'
gem 'rack-graphiql'
gem 'rake'
gem 'sentry-raven'
gem 'sequel'
gem 'sidekiq'
gem 'sinatra'

group :test, :development do
  gem 'byebug'
  gem 'dotenv'
  gem 'mailcatcher'
  gem 'rubocop', require: false
  gem 'shotgun'
  gem 'sqlite3'
end

group :test do
  gem 'capybara'
  gem 'rspec'
  # Workaround for cc-test-reporter with SimpleCov 0.18.
  # Stop upgrading SimpleCov until the following issue will be resolved.
  # https://github.com/codeclimate/test-reporter/issues/418
  gem 'simplecov', '~> 0.19', require: false
end
