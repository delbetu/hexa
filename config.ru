require 'raven'
require 'load_gems'
require 'api'
require 'sequel_connect'

## Sentry
Raven.configure do |config|
  config.dsn = 'https://21ef2fa6c1c54496a26404e123835705@o434503.ingest.sentry.io/5391623'
end
use Raven::Rack

run Sinatra::Application
