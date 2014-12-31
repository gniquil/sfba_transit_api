# SFBATransitAPI

## Information

SFBATransitAPI provides a simple wrapper around Real-time Transit Data Services
Application Programming Interface (API) sponsored by 511 in the San Francisco
Bay Area. More detail can be found here[]

## How to use

### Install the gem

```
gem install sfba_transit_api
```

### Register and get your secure token

Go to this website http://511.org/developer-resources_api-security-token_rtt.asp
and get your token.

### Create a new new client and query away

Assuming you put the token in an environment variable

```ruby
require 'sfba_transit_api'

client = SFBATransitAPI::Client.new(ENV['SFBA_TRANSIT_API_TOKEN'])

# When will the next MUNI bus 19 leave from the Polk and Sutter Station to go to
# Potrero Hill?

stops = client.get_stops_for_route(agency_name: "SF-MUNI", route_code: "19", route_direction: :outbound)

my_stop = stops.find { |stop| stop.name =~ /Polk.+Sutter/ }
puts my_stop.code
# => "16002"

puts client.get_next_departures_by_stop_code("16002").departure_times
# => [5, 12]

```
