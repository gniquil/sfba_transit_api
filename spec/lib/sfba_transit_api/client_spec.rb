require 'spec_helper'

module SFBATransitAPI
  describe Client do
    let(:token) { ENV["SFBA_TRANSIT_API_TOKEN"] || "asdfqwer" }

    let(:client) { Client.new token }

    it "should initialize correctly" do
      expect(client.connection.token).to eq token
    end

    it "make the right routeIDF" do
      expect(client.makeRouteIDF(agency_name: "SF-MUNI", route_code: "Some Route")).to eq "SF-MUNI~Some Route"
      expect(client.makeRouteIDF(agency_name: "SF-MUNI", route_code: "Some Route", route_direction_code: "Inbound")).to eq "SF-MUNI~Some Route~Inbound"
      expect(client.makeRouteIDF(agency_name: "SF-MUNI", route_code: "Some Route", route_direction_code: "Outbound")).to eq "SF-MUNI~Some Route~Outbound"
    end

    it "parses doc with only agency correctly" do
      xml_string = <<-XML
<RTT>
  <AgencyList>
    <Agency Name="AC Transit" HasDirection="True" Mode="Bus"></Agency>
    <Agency Name="BART" HasDirection="False" Mode="Rail"></Agency>
  </AgencyList>
</RTT>
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
        {
          "type" => "agency",
          "name" => "AC Transit",
          "has_direction" => true,
          "mode" => "Bus"
        },
        {
          "type" => "agency",
          "name" => "BART",
          "has_direction" => false,
          "mode" => "Rail"
        }
      ]
    end

    it "parses doc with direction-less routes correctly" do
      xml_string = <<-XML
<RTT>
  <AgencyList>
    <Agency Name="BART" HasDirection="False" Mode="Rail">
      <RouteList>
        <Route Name="Daly City" Code="747"></Route>
        <Route Name="Dublin Pleasanton" Code="920"></Route>
      </RouteList>
    </Agency>
  </AgencyList>
</RTT>
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
        {
          "type" => "agency",
          "name" => "BART",
          "has_direction" => false,
          "mode" => "Rail",
          "routes" => [
            {
              "type" => "route",
              "name" => "Daly City",
              "code" => "747"
            },
            {
              "type" => "route",
              "name" => "Dublin Pleasanton",
              "code" => "920"
            }
          ]
        }
      ]
    end

    it "parses doc with direction-ed routes correctly" do
      xml_string = <<-XML
<RTT>
  <AgencyList>
    <Agency Name="SF-MUNI" HasDirection="True" Mode="Bus">
      <RouteList>
        <Route Name="1-California" Code="1">
          <RouteDirectionList>
            <RouteDirection Code="Inbound" Name="Inbound to Downtown"></RouteDirection>
            <RouteDirection Code="Outbound" Name="Outbound to The Richmond District"></RouteDirection>
          </RouteDirectionList>
        </Route>
        <Route Name="10-Townsend" Code="10">
          <RouteDirectionList>
            <RouteDirection Code="Inbound" Name="Inbound to Pacific Heights"></RouteDirection>
            <RouteDirection Code="Outbound" Name="Outbound to General Hospital"></RouteDirection>
          </RouteDirectionList>
        </Route>
      </RouteList>
    </Agency>
  </AgencyList>
</RTT>
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
        {
          "type" => "agency",
          "name" => "SF-MUNI",
          "has_direction" => true,
          "mode" => "Bus",
          "routes" => [
            {
              "type" => "route",
              "name" => "1-California",
              "code" => "1",
              "route_directions" => [
                {
                  "type" => "route_direction",
                  "name" => "Inbound to Downtown",
                  "code" => "Inbound"
                },
                {
                  "type" => "route_direction",
                  "name" => "Outbound to The Richmond District",
                  "code" => "Outbound"
                }
              ]
            },
            {
              "type" => "route",
              "name" => "10-Townsend",
              "code" => "10",
              "route_directions" => [
                {
                  "type" => "route_direction",
                  "name" => "Inbound to Pacific Heights",
                  "code" => "Inbound"
                },
                {
                  "type" => "route_direction",
                  "name" => "Outbound to General Hospital",
                  "code" => "Outbound"
                }
              ]
            }
          ]
        }
      ]
    end

    it "parses doc with direction-ed stops correctly" do
      xml_string = <<-XML
<RTT>
  <AgencyList>
    <Agency Name="SF-MUNI" HasDirection="True" Mode="Bus">
      <RouteList>
        <Route Name="19-Polk" Code="19">
          <RouteDirectionList>
            <RouteDirection Code="Outbound" Name="Outbound to Hunters Point">
              <StopList>
                <Stop name="Beach St and Polk St" StopCode="13093"></Stop>
              </StopList>
            </RouteDirection>
          </RouteDirectionList>
        </Route>
      </RouteList>
    </Agency>
  </AgencyList>
</RTT>
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
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
                      "name" => "Beach St and Polk St",
                      "stop_code" => "13093"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ]
    end

    it "parses doc with direction-less stops correctly" do
      xml_string = <<-XML
<RTT>
  <AgencyList>
    <Agency Name="BART" HasDirection="False" Mode="Rail">
      <RouteList>
        <Route Name="Daly City" Code="747">
          <StopList>
            <Stop name="16th St. Mission (SF)" StopCode="10"></Stop>
          </StopList>
        </Route>
      </RouteList>
    </Agency>
  </AgencyList>
</RTT>
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
        {
          "type" => "agency",
          "name" => "BART",
          "has_direction" => false,
          "mode" => "Rail",
          "routes" => [
            {
              "type" => "route",
              "name" => "Daly City",
              "code" => "747",
              "stops" => [
                {
                  "type" => "stop",
                  "name" => "16th St. Mission (SF)",
                  "stop_code" => "10"
                }
              ]
            }
          ]
        }
      ]
    end

    it "parses doc with direction-less departure times correctly" do
      xml_string = <<-XML
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
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
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
    end

    it "parses doc with direction-ed departure times correctly" do
      xml_string = <<-XML
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
      XML

      doc = Nokogiri::XML(xml_string)

      result = client.parse(doc)

      expect(result).to eq [
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
    end

    it "behaves correctly for `#get_agencies`", external: true do
      agencies = client.get_agencies

      expect(agencies.count).to be > 0

      expect(agencies.first["name"]).not_to be_nil
    end

    it "behaves correctly for `#get_routes_for_agency`", external: true do
      agencies = client.get_routes_for_agency "BART"

      expect(agencies.count).to be > 0

      expect(agencies.first["name"]).not_to be_nil
    end

    it "behaves correctly for `#get_routes_for_agency` with directions", external: true do
      agencies = client.get_routes_for_agency "AC Transit"

      routes = agencies.first["routes"]

      expect(routes.count).to be > 0

      expect(routes.first["name"]).not_to be_nil
      expect(routes.first["route_directions"].count).to be > 0
    end

    it "behaves correctly for `#get_routes_for_agencies`", external: true do
      agencies = client.get_routes_for_agencies ["BART", "SF-MUNI"]

      expect(agencies.count).to eq 2

      routes = agencies[0]["routes"]

      expect(routes.count).to be > 0

      expect(routes[0]["type"]).to eq "route"

      routes = agencies[1]["routes"]

      expect(routes.count).to be > 0

      expect(routes[0]["type"]).to eq "route"
    end

    it "behaves correctly for `#get_stops_for_route`", external: true do
      agencies = client.get_stops_for_route agency_name: "SF-MUNI", route_code: "19", route_direction_code: "Inbound"

      routes = agencies[0]["routes"]

      expect(routes.count).to eq 1

      route_directions = routes[0]["route_directions"]

      expect(route_directions.count).to eq 1

      stops = route_directions[0]["stops"]

      expect(stops.count).to be > 1

      expect(stops[0]["type"]).to eq "stop"
    end

    it "behaves correctly for `#get_next_departures_by_stop_code`", external: true do
      agencies = client.get_next_departures_by_stop_code "16002"

      stops = agencies[0]["routes"][0]["route_directions"][0]["stops"]

      stop = stops[0]

      expect(stop["name"]).to eq "Polk St and Sutter St"
      expect(stop["stop_code"]).to eq "16002"
      expect(stop["departure_times"].count).to be > 0
    end

    it "behaves correctly for `#get_next_departures_by_stop_code` with multiple routes", external: true do
      agencies = client.get_next_departures_by_stop_code "16189"

      routes = agencies[0]["routes"]

      expect(routes.count).to eq 2

      stop = routes[0]["route_directions"][0]["stops"][0]

      expect(stop["name"]).to eq "Rhode Island St and 16th St"
      expect(stop["stop_code"]).to eq "16189"
      expect(stop["departure_times"].count).to be > 0

      stop = routes[1]["route_directions"][0]["stops"][0]

      expect(stop["name"]).to eq "Rhode Island St and 16th St"
      expect(stop["stop_code"]).to eq "16189"
      expect(stop["departure_times"].count).to be > 0
    end

  end
end
