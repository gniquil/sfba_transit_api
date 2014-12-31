module SFBATransitAPI
  class Route
    attr_accessor :name, :code, :directions, :stops, :agency

    def has_direction
      directions.count > 0
    end

    def to_s
      "#<SFBATransitAPI::Route:#{object_id} @name=\"#{name}\", @code=\"#{code}\", @direction_codes=\"#{direction_codes}\", @agency=<SFBATransitAPI::Agency:#{agency.object_id}>, directions.count=#{directions.count}, stops.count=#{stops.count}>"
    end

    def self.parse(agency_node, agency)
      agency_node.xpath(".//Route").map do |route_node|
        route = new


        route.agency = agency
        route.name = route_node["Name"]
        route.code = route_node["Code"]

        route.directions = Direction.parse(route_node, route)
        route.stops = Stop.parse(route_node, route)

        route
      end
    end
  end
end
