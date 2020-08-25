env = ENV['RACK_ENV'] || 'development'

if env != 'production'
  require 'dotenv'
  Dotenv.overload(".env") if env == 'development'
  Dotenv.overload(".env.test") if env == 'test'
  Dotenv.overload(".env.docker") if env == 'docker'

  puts "DATABASE_URL #{ENV['DATABASE_URL']}"
end

APP_ROOT = ENV.fetch('APP_ROOT', Dir.pwd)
$LOAD_PATH << "#{APP_ROOT}/lib"

ENV['BUNDLE_GEMFILE'] ||= File.join(APP_ROOT, '/', 'Gemfile')
require "rubygems"
require "bundler"
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

require 'extensions'
