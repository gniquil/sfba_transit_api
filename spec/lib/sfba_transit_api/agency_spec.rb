require 'spec_helper'

module SFBATransitAPI
  describe Agency do
    it "should correctly parse routes with directions" do
      xml_string = <<-XML
<RTT>
  <AgencyList>
    <Agency Name="AC Transit" HasDirection="True" Mode="Bus"></Agency>
    <Agency Name="BART" HasDirection="False" Mode="Rail"></Agency>
    <Agency Name="Caltrain" HasDirection="True" Mode="Rail"></Agency>
  </AgencyList>
</RTT>
      XML

      doc = Nokogiri::XML(xml_string)

      agencies = Agency.parse(doc)

      expect(agencies.count).to eq 3

      expect(agencies[0].name).to eq "AC Transit"
      expect(agencies[0].mode).to eq "Bus"
      expect(agencies[0].has_direction).to eq true

      expect(agencies[1].name).to eq "BART"
      expect(agencies[1].mode).to eq "Rail"
      expect(agencies[1].has_direction).to eq false

      expect(agencies[2].name).to eq "Caltrain"
      expect(agencies[2].mode).to eq "Rail"
      expect(agencies[2].has_direction).to eq true
    end

    it "should parse the full doc correctly" do
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
                    <DepartureTime>13</DepartureTime>
                    <DepartureTime>40</DepartureTime>
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

      agencies = Agency.parse(doc)

      expect(agencies.count).to eq 1

      agency = agencies.first

      expect(agency.name).to eq "SF-MUNI"
      expect(agency.mode).to eq "Bus"
      expect(agency.has_direction).to eq true

      expect(agency.routes.count).to eq 1

      route = agency.routes.first

      expect(route.name).to eq "19-Polk"
      expect(route.code).to eq "19"
      expect(route.inbound_name).to eq nil
      expect(route.outbound_name).to eq "Outbound to Hunters Point"
      expect(route.agency).to eq agency

      expect(route.stops.count).to eq 1

      stop = route.stops.first

      expect(stop.name).to eq "Polk St and Sutter St"
      expect(stop.code).to eq "16002"
      expect(stop.direction).to eq :outbound
      expect(stop.direction_name).to eq "Outbound to Hunters Point"
      expect(stop.departure_times).to eq [13, 40, 55]
      expect(stop.route).to eq route
    end
  end
end
