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
      expect(client.makeRouteIDF(agency_name: "SF-MUNI", route_code: "Some Route", route_direction: :inbound)).to eq "SF-MUNI~Some Route~Inbound"
      expect(client.makeRouteIDF(agency_name: "SF-MUNI", route_code: "Some Route", route_direction: :outbound)).to eq "SF-MUNI~Some Route~Outbound"
    end

    it "behaves correctly for `#get_agencies`", external: true do
      agencies = client.get_agencies

      expect(agencies.count).to be > 0

      expect(agencies.first.name).not_to be_nil
    end

    it "behaves correctly for `#get_routes_for_agency`", external: true do
      agencies = client.get_routes_for_agency "BART"

      expect(agencies.count).to be > 0

      expect(agencies.first.name).not_to be_nil
    end

    it "behaves correctly for `#get_routes_for_agencies`", external: true do
      routes = client.get_routes_for_agencies ["BART", "SF-MUNI"]

      expect(routes.count).to be > 0

      expect(routes.first.is_a?(Route)).to eq true
    end

    it "behaves correctly for `#get_stops_for_route(s)`", external: true do
      routes = client.get_stops_for_route agency_name: "SF-MUNI", route_code: "19", route_direction: :inbound

      inbound_count = routes.count

      expect(inbound_count).to be > 0

      expect(routes.first.is_a?(Stop)).to eq true

      routes = client.get_stops_for_routes [
        {
          agency_name: "SF-MUNI", route_code: "19", route_direction: :inbound
        },
        {
          agency_name: "SF-MUNI", route_code: "19", route_direction: :outbound
        }
      ]

      inout_bound_count = routes.count

      expect(inout_bound_count).to be > 0

      expect(inout_bound_count).to be > inbound_count

      expect(routes.first.is_a?(Stop)).to eq true
    end

    it "behaves correctly for `#get_next_departures_by_stop_code`", external: true do
      stop = client.get_next_departures_by_stop_code "16002"

      expect(stop.is_a?(Stop)).to eq true

      expect(stop.name).to eq "Polk St and Sutter St"
      expect(stop.code).to eq "16002"
      expect(stop.departure_times.count).to be > 0
      expect(stop.direction).to eq :outbound
      expect(stop.direction_name).to eq "Outbound to Hunters Point"

      route = stop.route

      expect(route.name).to eq "19-Polk"
      expect(route.code).to eq "19"
      expect(route.inbound_name).to eq nil
      expect(route.outbound_name).to eq "Outbound to Hunters Point"

      agency = route.agency

      expect(agency.name).to eq "SF-MUNI"
      expect(agency.mode).to eq "Bus"
      expect(agency.has_direction).to eq true
    end

  end
end
