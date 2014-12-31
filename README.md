# SFBATransitAPI

## Information

SFBATransitAPI provides a simple wrapper around Real-time Transit Data Services
Application Programming Interface (API) sponsored by 511 in the San Francisco
Bay Area. More detail can be found http://www.511.org/developer-resources_transit-api.asp.

## How to use

### Install the gem

```
> gem install sfba_transit_api
```

### Register and get your secure token

Go to this website http://511.org/developer-resources_api-security-token_rtt.asp
and get your token.

### Create a new new client and query away

Assuming you put the token in an environment variable

```ruby
require 'sfba_transit_api'

client = SFBATransitAPI.client ENV['SFBA_TRANSIT_API_TOKEN']

# When will the next MUNI bus 19 leave from the Polk and Sutter Station to go to
# Potrero Hill?

stops = client.get_stops_for_route(agency_name: "SF-MUNI", route_code: "19", route_direction: :outbound)

my_stop = stops.find { |stop| stop.name =~ /Polk.+Sutter/ }
puts my_stop.code
# => "16002"

puts client.get_next_departures_by_stop_code("16002").departure_times
# => [5, 12]

```

## API

TODO (Read the test or code for now)

```
module SFBATransitAPI

  # creates the client
  #
  # @param token [String]
  # @param opts [Hash]
  # @option opts [String] :api_endpoint default to "http://services.my511.org"
  # @option opts [String] :path_prefix default to "/Transit2.0"
  # @return [SFBATransitAPI::Client]
  def client(token, opts={}); end

  class Client

    # get a list of transit agencies
    #
    # @return [Array<SFBATransitAPI::Agency>]
    def get_agencies; end

    # get a list of routes for a given agency
    #
    # @param agency_name [String]
    # @return [Array<SFBATransitAPI::Route>]
    def get_routes_for_agency(agency_name); end

    # get a list of routes for multiple agencies
    #
    # @param agency_names [Array<String>]
    # @return [Array<SFBATransitAPI::Route>]
    def get_routes_for_agencies(agency_names); end

    # get a list of stops for a given route
    #
    # @param route_info [Hash]
    # @option route_info [String] :agency_name required
    # @option route_info [String] :route_code required
    # @option route_info [Symbol] :route_direction optional, or :inbound, :outbound
    # @return [Array<SFBATransitAPI::Route>]
    def get_stops_for_route(route_info); end

    # get a list of stops for multiple routes
    #
    # @param route_infos [Array<Hash>] see `#get_stops_for_route` for param info
    # @return [Array<SFBATransitAPI::Route>]
    def get_stops_for_route(route_info); end

    # get a stop with departure times
    #
    # @param stopcode [String]
    # @return [Array<SFBATransitAPI::Stop>] with departure_time populated
    def get_next_departures_by_stop_code(stopcode); end
  end

  # @attr [String] name
  # @attr [Boolean] has_direction
  # @attr [String] mode e.g. "Bus", "Rail"
  # @attr [Array<SFBATransitAPI::Route>] routes
  class Agency; end

  # @attr [String] name
  # @attr [String] code
  # @attr [String] inbound_name
  # @attr [String] outbound_name
  # @attr [Boolean] has_direction
  # @attr [Array<SFBATransitAPI::Stop>] stops
  # @attr [SFBATransitAPI::Agency] agency
  class Route; end

  # @attr [String] name
  # @attr [String] code
  # @attr [Symbol] direction values can be nil, :inbound, :outbound
  # @attr [String] direction_name can be nil
  # @attr [Array<Fixnum>] departure_times can be []
  # @attr [SFBATransitAPI::Route] route can be []
  class Stop; end
end
```

## Note on tesing

There are a few tests that require hitting the real endpoint, which is currently
tagged as `external`. To run the tests without these tests

```
> rspec --tag ~@external
```

or run it with your token

```
> SFBA_TRANSIT_API_TOKEN=[your token here] rspec
```

or simply add it to your .env file
