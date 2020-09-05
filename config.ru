require 'raven'
require 'load_gems'
require 'api'
require 'sequel_connect'

## Sentry
Raven.configure do |config|
  config.dsn = 'https://21ef2fa6c1c54496a26404e123835705@o434503.ingest.sentry.io/5391623'
end
use Raven::Rack

## Pony Mail
require 'pony'

Pony.options = {
  :via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',
    :enable_starttls_auto => true,
    :user_name            => ENV['SMTP_GMAIL_USERNAME'],
    :password             => ENV['SMTP_GMAIL_PASSWORD'],
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               => "localhost.localdomain" # the HELO domain provided by the client to the server
  }
}

run Sinatra::Application
