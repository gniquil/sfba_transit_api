module SFBATransitAPI
  class Stop
    attr_accessor :name, :code, :departure_times, :route, :direction

    def to_s
      "#<SFBATransitAPI::Stop:#{object_id} @name=\"#{name}\", @code=\"#{code}\", @direction=<SFBATransitAPI::Direction:#{direction.object_id}>, @route=<SFBATransitAPI::Route:#{route.object_id}>, departure_times=#{departure_times}>"
    end

    def self.parse_departure_times(stop_node)
      stop_node.xpath(".//DepartureTime").map do |departure_time_node|
        departure_time_node.text ? departure_time_node.text.to_i : nil
      end
    end

    def self.parse(route_node, route)
      route_node.xpath(".//Stop").map do |stop_node|
        stop = new

        stop.route = route
        stop.direction = Direction.parse_direction_node(stop_node.parent.parent, route)

        stop.name = stop_node["name"]
        stop.code = stop_node["StopCode"]
        stop.departure_times = parse_departure_times(stop_node)

        stop
      end
    end
  end
end
