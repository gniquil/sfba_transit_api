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

agencies = client.get_stops_for_route(agency_name: "SF-MUNI", route_code: "19", route_direction_code: "Outbound")

stops = agencies[0]["routes"][0]["route_directions"][0]["stops"]

my_stop = stops.find { |stop| stop["name"] =~ /Polk.+Sutter/ }

puts my_stop.stop_code
# => "16002"

puts client.get_next_departures_by_stop_code("16002")[0]["routes"][0]["route_directions"][0]["stops"][0]["departure_times"]
# => [5, 12]

```

### Result format

Since this is a very thin wrapper around the API, minimal effort is applied in
"reinterpreting" the result. Generally a response should look like the following,
with agencies that have directions:

```xml
<RTT>
  <AgencyList>
    <Agency Name="SF-MUNI" HasDirection="True" Mode="Bus">
      <RouteList>
        <Route Name="19-Polk" Code="19">
          <RouteDirectionList>
            <RouteDirection Code="Outbound" Name="Outbound to Hunters Point">
              <StopList>
                <Stop name="Polk St and Sutter St" StopCode="16002">
                  <DepartureTimeList>
                    <DepartureTime>21</DepartureTime>
                    <DepartureTime>36</DepartureTime>
                    <DepartureTime>55</DepartureTime>
                  </DepartureTimeList>
                </Stop>
              </StopList>
            </RouteDirection>
          </RouteDirectionList>
        </Route>
      </RouteList>
    </Agency>
  </AgencyList>
</RTT>
```

```ruby
[
  {
    "type" => "agency",
    "name" => "SF-MUNI",
    "has_direction" => true,
    "mode" => "Bus",
    "routes" => [
      {
        "type" => "route",
        "name" => "19-Polk",
        "code" => "19",
        "route_directions" => [
          {
            "type" => "route_direction",
            "name" => "Outbound to Hunters Point",
            "code" => "Outbound",
            "stops" => [
              {
                "type" => "stop",
                "name" => "Polk St and Sutter St",
                "stop_code" => "16002",
                "departure_times" => [21, 36, 55]
              }
            ]
          }
        ]
      }
    ]
  }
]
```

or with agencies without directions:

```xml
<RTT>
  <AgencyList>
    <Agency Name="BART" HasDirection="False" Mode="Rail">
      <RouteList>
        <Route Name="24th St. Mission" Code="587">
          <StopList>
            <Stop name="16th St. Mission (SF)" StopCode="10">
              <DepartureTimeList/>
            </Stop>
          </StopList>
        </Route>
        <Route Name="Daly City" Code="747">
          <StopList>
            <Stop name="16th St. Mission (SF)" StopCode="10">
              <DepartureTimeList>
                <DepartureTime>15</DepartureTime>
                <DepartureTime>29</DepartureTime>
                <DepartureTime>42</DepartureTime>
              </DepartureTimeList>
            </Stop>
          </StopList>
        </Route>
      </RouteList>
    </Agency>
  </AgencyList>
</RTT>
```

```ruby
[
  {
    "type" => "agency",
    "name" => "BART",
    "has_direction" => false,
    "mode" => "Rail",
    "routes" => [
      {
        "type" => "route",
        "name" => "24th St. Mission",
        "code" => "587",
        "stops" => [
          {
            "type" => "stop",
            "name" => "16th St. Mission (SF)",
            "stop_code" => "10",
            "departure_times" => []
          }
        ]
      },
      {
        "type" => "route",
        "name" => "Daly City",
        "code" => "747",
        "stops" => [
          {
            "type" => "stop",
            "name" => "16th St. Mission (SF)",
            "stop_code" => "10",
            "departure_times" => [ 15, 29, 42 ]
          }
        ]
      }
    ]
  }
]
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
    # @return [Array<Hash>]
    def get_agencies; end

    # get a list of routes for a given agency
    #
    # @param agency_name [String]
    # @return [Array<Hash>]
    def get_routes_for_agency(agency_name); end

    # get a list of routes for multiple agencies
    #
    # @param agency_names [Array<String>]
    # @return [Array<Hash>]
    def get_routes_for_agencies(agency_names); end

    # get a list of stops for a given route
    #
    # @param route_info [Hash]
    # @option route_info [String] :agency_name required
    # @option route_info [String] :route_code required
    # @option route_info [String] :route_direction_code optional if agency is direction-less
    # @return [Array<Hash>]
    def get_stops_for_route(route_info); end

    # get a list of stops for multiple routes
    #
    # @param route_infos [Array<Hash>] see `#get_stops_for_route` for param info
    # @return [Array<Hash>]
    def get_stops_for_route(route_info); end

    # get a stop with departure times
    #
    # @param stopcode [String]
    # @return [Array<Hash>]
    def get_next_departures_by_stop_code(stopcode); end
  end

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
