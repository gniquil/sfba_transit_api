require 'spec_helper'

module SFBATransitAPI
  describe Stop do
    it "should parse stops for direction less route correctly" do
      xml_string = <<-XML
<Route Name="Daly City" Code="747">
  <StopList>
    <Stop name="16th St. Mission (SF)" StopCode="10"></Stop>
    <Stop name="Civic Center (SF)" StopCode="12"></Stop>
  </StopList>
</Route>
      XML

      route_node = Nokogiri::XML(xml_string).at_xpath("//Route")

      route_double = double('Route', name: "Daly City", code: "747", has_direction: false)

      stops = Stop.parse(route_node, route_double)

      expect(stops.count).to eq 2

      expect(stops[0].name).to eq "16th St. Mission (SF)"
      expect(stops[0].code).to eq "10"
      expect(stops[0].direction).to eq nil
      expect(stops[0].direction_name).to eq nil
      expect(stops[0].route).to eq route_double

      expect(stops[1].name).to eq "Civic Center (SF)"
      expect(stops[1].code).to eq "12"
      expect(stops[1].direction).to eq nil
      expect(stops[1].direction_name).to eq nil
      expect(stops[1].route).to eq route_double
    end

    it "should parse stops for direction'ed routes correctly" do
      xml_string = <<-XML
<Route Name="19-Polk" Code="19">
  <RouteDirectionList>
    <RouteDirection Code="Outbound" Name="Outbound to Hunters Point">
      <StopList>
        <Stop name="Beach St and Polk St" StopCode="13093"></Stop>
        <Stop name="8th St and Brannan St" StopCode="13203"></Stop>
      </StopList>
    </RouteDirection>
  </RouteDirectionList>
</Route>
      XML

      route_node = Nokogiri::XML(xml_string).at_xpath("//Route")

      route_double = double('Route', name: "19-Polk", code: "19", has_direction: true)

      stops = Stop.parse(route_node, route_double)

      expect(stops.count).to eq 2

      expect(stops[0].name).to eq "Beach St and Polk St"
      expect(stops[0].code).to eq "13093"
      expect(stops[0].direction).to eq :outbound
      expect(stops[0].direction_name).to eq "Outbound to Hunters Point"
      expect(stops[0].route).to eq route_double

      expect(stops[1].name).to eq "8th St and Brannan St"
      expect(stops[1].code).to eq "13203"
      expect(stops[1].direction).to eq :outbound
      expect(stops[1].direction_name).to eq "Outbound to Hunters Point"
      expect(stops[1].route).to eq route_double
    end

    it "should parse stop with departure time for direction less route correctly" do
      xml_string = <<-XML
<Route Name="Daly City" Code="747">
  <StopList>
    <Stop name="16th St. Mission (SF)" StopCode="10">
      <DepartureTimeList>
        <DepartureTime>13</DepartureTime>
        <DepartureTime>40</DepartureTime>
        <DepartureTime>55</DepartureTime>
      </DepartureTimeList>
    </Stop>
  </StopList>
</Route>
      XML

      route_node = Nokogiri::XML(xml_string).at_xpath("//Route")

      route_double = double('Route', name: "Daly City", code: "747", has_direction: false)

      stops = Stop.parse(route_node, route_double)

      expect(stops.count).to eq 1

      expect(stops[0].name).to eq "16th St. Mission (SF)"
      expect(stops[0].code).to eq "10"
      expect(stops[0].direction).to eq nil
      expect(stops[0].direction_name).to eq nil
      expect(stops[0].departure_times).to eq [13, 40, 55]
      expect(stops[0].route).to eq route_double
    end

    it "should parse stops for direction'ed routes correctly" do
      xml_string = <<-XML
<Route Name="19-Polk" Code="19">
  <RouteDirectionList>
    <RouteDirection Code="Outbound" Name="Outbound to Hunters Point">
      <StopList>
        <Stop name="Beach St and Polk St" StopCode="13093">
          <DepartureTimeList>
            <DepartureTime>1</DepartureTime>
          </DepartureTimeList>
        </Stop>
      </StopList>
    </RouteDirection>
  </RouteDirectionList>
</Route>
      XML

      route_node = Nokogiri::XML(xml_string).at_xpath("//Route")

      route_double = double('Route', name: "19-Polk", code: "19", has_direction: true)

      stops = Stop.parse(route_node, route_double)

      expect(stops.count).to eq 1

      expect(stops[0].name).to eq "Beach St and Polk St"
      expect(stops[0].code).to eq "13093"
      expect(stops[0].direction).to eq :outbound
      expect(stops[0].direction_name).to eq "Outbound to Hunters Point"
      expect(stops[0].departure_times).to eq [1]
      expect(stops[0].route).to eq route_double
    end

  end
end
