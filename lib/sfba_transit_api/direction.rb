module SFBATransitAPI
  class Direction
    attr_accessor :name, :code, :route

    def to_s
      "#<SFBATransitAPI::Direction:#{object_id} @name=\"#{name}\", @code=\"#{code}\", @route=<SFBATransitAPI::Route:#{route.object_id}>>"
    end

    def self.parse(route_node, route)
      route_node.xpath(".//RouteDirection").map do |direction_node|
        parse_direction_node(direction_node, route)
      end
    end

    def self.parse_direction_node(direction_node, route)
      return nil if direction_node.nil? or direction_node.name != 'RouteDirection'

      direction = new

      direction.route = route
      direction.name = direction_node["Name"]
      direction.code = direction_node["Code"]

      direction
    end
  end
end
