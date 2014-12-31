require 'spec_helper'

module SFBATransitAPI
  describe Route do
    it "should correctly parse routes with directions" do
      xml_string = <<-XML
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
    <Route Name="108-Treasure Island" Code="108">
      <RouteDirectionList>
        <RouteDirection Code="Inbound" Name="Inbound to Downtown"></RouteDirection>
        <RouteDirection Code="Outbound" Name="Outbound to Treasure Island"></RouteDirection>
      </RouteDirectionList>
    </Route>
  </RouteList>
</Agency>
      XML

      agency_node = Nokogiri::XML(xml_string).at_xpath("//Agency")

      agency_double = double('Agency', name: "SF-Muni", mode: "Bus", has_direction: true)

      routes = Route.parse(agency_node, agency_double)

      expect(routes.count).to eq 3

      expect(routes[0].name).to eq "1-California"
      expect(routes[0].code).to eq "1"
      expect(routes[0].inbound_name).to eq "Inbound to Downtown"
      expect(routes[0].outbound_name).to eq "Outbound to The Richmond District"
      expect(routes[0].has_direction).to eq true
      expect(routes[0].agency).to eq agency_double

      expect(routes[1].name).to eq "10-Townsend"
      expect(routes[1].code).to eq "10"
      expect(routes[1].inbound_name).to eq "Inbound to Pacific Heights"
      expect(routes[1].outbound_name).to eq "Outbound to General Hospital"
      expect(routes[1].has_direction).to eq true
      expect(routes[1].agency).to eq agency_double

      expect(routes[2].name).to eq "108-Treasure Island"
      expect(routes[2].code).to eq "108"
      expect(routes[2].inbound_name).to eq "Inbound to Downtown"
      expect(routes[2].outbound_name).to eq "Outbound to Treasure Island"
      expect(routes[2].has_direction).to eq true
      expect(routes[2].agency).to eq agency_double
    end

    it "should correctly parse routes without directions" do
      xml_string = <<-XML
<Agency Name="SF-MUNI" HasDirection="False" Mode="Bus">
  <RouteList>
    <Route Name="1-California" Code="1"></Route>
  </RouteList>
</Agency>
      XML

      agency_node = Nokogiri::XML(xml_string).at_xpath("//Agency")

      agency_double = double('Agency', name: "SF-Muni", mode: "Bus", has_direction: false)

      routes = Route.parse(agency_node, agency_double)

      expect(routes.count).to eq 1

      expect(routes[0].name).to eq "1-California"
      expect(routes[0].code).to eq "1"
      expect(routes[0].inbound_name).to eq nil
      expect(routes[0].outbound_name).to eq nil
      expect(routes[0].has_direction).to eq false
      expect(routes[0].agency).to eq agency_double
    end
  end
end
