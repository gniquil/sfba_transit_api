module SFBATransitAPI
  class Stop
    attr_accessor :name, :code, :direction, :direction_name, :departure_times, :route

    def to_s
      "#<SFBATransitAPI::Stop:#{object_id} @name=\"#{name}\", @code=\"#{code}\", @direction=\"#{direction}\", @direction_name=\"#{direction_name}\", @route=<SFBATransitAPI::Route:#{route.object_id}>, departure_times=#{departure_times}>"
    end

    def self.parse_departure_times(stop_node)
      stop_node.xpath(".//DepartureTime").map do |departure_time_node|
        departure_time_node.text ? departure_time_node.text.to_i : nil
      end
    end

    def self.parse(route_node, route)
      if route.has_direction
        route_node.xpath(".//RouteDirection").map do |direction_node|

          if direction_node["Code"] == "Inbound"
            direction = :inbound
          elsif direction_node["Code"] == "Outbound"
            direction = :outbound
          end

          parse_stop(direction_node, route, direction, direction_node["Name"])
        end.flatten
      else
        parse_stop(route_node, route)
      end
    end

    def self.parse_stop(node, route, direction=nil, direction_name=nil)
      node.xpath(".//Stop").map do |stop_node|
        stop = new

        stop.route = route
        stop.name = stop_node["name"]
        stop.code = stop_node["StopCode"]
        stop.departure_times = parse_departure_times(stop_node)
        stop.direction = direction
        stop.direction_name = direction_name

        stop
      end
    end
  end
end
