require 'sfba_transit_api'
require 'dotenv'

Dotenv.load

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
