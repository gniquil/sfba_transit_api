require 'spec_helper'

module SFBATransitAPI
  describe Direction do
    it "should correctly parse the directions" do
      xml_string = <<-XML
<Route Name="1-California" Code="1">
  <RouteDirectionList>
    <RouteDirection Code="Inbound" Name="Inbound to Downtown"></RouteDirection>
    <RouteDirection Code="Outbound" Name="Outbound to The Richmond District"></RouteDirection>
  </RouteDirectionList>
</Route>
      XML

      route_node = Nokogiri::XML(xml_string).at_xpath("//Route")

      route_double = double('Route', name: "Daly City", code: "747", has_direction: false)

      directions = Direction.parse(route_node, route_double)

      expect(directions.count).to eq 2

      expect(directions[0].name).to eq "Inbound to Downtown"
      expect(directions[0].code).to eq "Inbound"
      expect(directions[0].route).to eq route_double

      expect(directions[1].name).to eq "Outbound to The Richmond District"
      expect(directions[1].code).to eq "Outbound"
      expect(directions[1].route).to eq route_double
    end
  end
end
