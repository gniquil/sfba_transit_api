require 'active_support/core_ext/string'

module SFBATransitAPI
  class Client

    attr_accessor :connection

    # Initialize the client
    #
    # @param token [String] obtained from http://www.511.org/developer-resources_api-security-token_rtt.asp
    # @return [String] the object converted into the expected format.
    def initialize(token, options={})
      self.connection = Connection.new(token, options)
    end

    def get_agencies
      response = get(:get_agencies)

      parse(response)
    end

    def get_routes_for_agency(agency_name)
      response = get(:get_routes_for_agency, {agency_name: agency_name})

      parse(response)
    end

    def get_routes_for_agencies(agency_names)
      response = get(:get_routes_for_agencies, {agency_names: agency_names.join("|")})

      parse(response)
    end

    def get_stops_for_route(route_info)
      route_idf = makeRouteIDF(route_info)

      response = get(:get_stops_for_route, {route_idf: route_idf})

      parse(response)
    end

    def get_next_departures_by_stop_code(stopcode)
      response = get(:get_next_departures_by_stop_code, stopcode: stopcode)

      parse(response)
    end

    def makeRouteIDF(route_info)
      route_idf = "#{route_info[:agency_name]}~#{route_info[:route_code]}"
      route_idf += "~#{route_info[:route_direction_code]}" if route_info[:route_direction_code]
      route_idf
    end

    def get(method, options={})
      self.connection.get(method, options)
    end

    def parse(doc)
      agency_list_node = doc.at_xpath("//AgencyList")
      if agency_list_node
        parse_agencies(agency_list_node)
      else
        nil
      end
    end

    def parse_agencies(agency_list_node)
      agency_list_node.xpath("./Agency").map do |agency_node|
        result = { "type" => "agency" }

        agency_node.attributes.each do |key, val|
          result[key.underscore] = to_boolean_if_possible(val.value)
        end

        route_list_node = agency_node.at_xpath("./RouteList")
        if route_list_node
          result["routes"] = parse_routes(route_list_node)
        end

        result
      end
    end

    def parse_routes(route_list_node)
      route_list_node.xpath("./Route").map do |route_node|
        result = { "type" => "route" }

        route_node.attributes.each do |key, val|
          result[key.underscore] = val.value
        end

        route_direction_list_node = route_node.at_xpath("./RouteDirectionList")
        if route_direction_list_node
          result["route_directions"] = parse_route_directions(route_direction_list_node)
        else
          stop_list_node = route_node.at_xpath("./StopList")
          if stop_list_node
            result["stops"] = parse_stops(stop_list_node)
          end
        end

        result
      end
    end

    def parse_route_directions(route_direction_list_node)
      route_direction_list_node.xpath("./RouteDirection").map do |route_direction_node|
        result = { "type" => "route_direction" }

        route_direction_node.attributes.each do |key, val|
          result[key.underscore] = val.value
        end

        stop_list_node = route_direction_node.at_xpath("./StopList")
        if stop_list_node
          result["stops"] = parse_stops(stop_list_node)
        end

        result
      end
    end

    def parse_stops(stop_list_node)
      stop_list_node.xpath("./Stop").map do |stop_node|
        result = { "type" => "stop" }

        stop_node.attributes.each do |key, val|
          result[key.underscore] = val.value
        end

        departure_time_list_node = stop_node.at_xpath("./DepartureTimeList")
        if departure_time_list_node
          result["departure_times"] = parse_departure_times(departure_time_list_node)
        end

        result
      end
    end

    def parse_departure_times(departure_time_list_node)
      departure_time_list_node.xpath("./DepartureTime").map do |departure_time_node|
        departure_time_node.text ? departure_time_node.text.to_i : nil
      end
    end

    def to_boolean_if_possible(value)
      if value.downcase == "true"
        true
      elsif value.downcase == "false"
        false
      else
        value
      end
    end
  end
end
