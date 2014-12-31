module SFBATransitAPI
  class Route
    attr_accessor :name, :code, :inbound_name, :outbound_name, :stops, :agency

    def has_direction
      not (inbound_name.nil? and outbound_name.nil?)
    end

    def to_s
      "#<SFBATransitAPI::Route:#{object_id} @name=\"#{name}\", @code=\"#{code}\", @inbound_name=\"#{inbound_name}\", @outbound_name=\"#{outbound_name}\", @agency=<SFBATransitAPI::Agency:#{agency.object_id}>, stops.count=#{stops.count}>"
    end

    def self.parse(agency_node, agency)
      agency_node.xpath(".//Route").map do |route_node|
        route = new


        route.agency = agency
        route.name = route_node["Name"]
        route.code = route_node["Code"]

        direction_nodes = route_node.xpath(".//RouteDirection")
        if direction_nodes.count > 0
          direction_nodes.each do |direction_node|
            if direction_node["Code"] == "Inbound"
              route.inbound_name = direction_node["Name"]
            elsif direction_node["Code"] == "Outbound"
              route.outbound_name = direction_node["Name"]
            end
          end
        end

        route.stops = Stop.parse(route_node, route)

        route
      end
    end
  end
end
