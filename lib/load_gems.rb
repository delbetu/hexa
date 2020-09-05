def env
  ENV['RACK_ENV'] || 'development'
end

# TODO: implement this
# def env
#   case(ENV['RACK_ENV'])
#   when 'production'
#     OpenStruct.new(production?: true, development?: false, test?: false, docker?: false)
#   when 'test'
#     OpenStruct.new(production?: false, development?: false, test?: true, docker?: false)
#   when 'docker'
#     OpenStruct.new(production?: false, development?: false, test?: true, docker?: true)
#   else # treat as 'development'
#     OpenStruct.new(production?: false, development?: true, test?: false, docker?: false)
#   end
# end

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
