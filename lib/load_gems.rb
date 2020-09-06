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

################## config gems for different environments ##################

## Sentry
if env == 'production'
  Raven.configure do |config|
    config.dsn = 'https://21ef2fa6c1c54496a26404e123835705@o434503.ingest.sentry.io/5391623'
  end
else
  use Raven::Rack
end

## Pony Mail
require 'pony'

case env
when 'production'
  Pony.options = {
    via: :smtp,
    via_options: {
      address: 'smtp.gmail.com',
      port: '587',
      enable_starttls_auto: true,
      user_name: ENV['SMTP_GMAIL_USERNAME'],
      password: ENV['SMTP_GMAIL_PASSWORD'],
      authentication: :plain, # :plain, :login, :cram_md5, no auth by default
      domain: "localhost.localdomain" # the HELO domain provided by the client to the server
    }
  }
when 'development'
  Pony.options = { # send to mailcatcher
    via: :smtp,
    via_options: {
      address: 'mailcatcher',
      port: '1025'
    }
  }
else # test
  Pony.override_options = { :via => :test  }
end

require 'extensions'
