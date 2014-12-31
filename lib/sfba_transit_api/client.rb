module SFBATransitAPI
  class Client

    attr_accessor :connection

    def initialize(token, options={})
      self.connection = Connection.new(token, options)
    end

    def get_agencies
      response = get(:get_agencies)

      Agency.parse(response)
    end

    def get_routes_for_agency(agency_name)
      response = get(:get_routes_for_agency, {agency_name: agency_name})

      Agency.parse(response).map { |agency| agency.routes }.flatten
    end

    def get_routes_for_agencies(agency_names)
      response = get(:get_routes_for_agencies, {agency_names: agency_names.join("|")})

      Agency.parse(response).map { |agency| agency.routes }.flatten
    end

    def get_stops_for_route(route_info)
      route_idf = makeRouteIDF(route_info)

      response = get(:get_stops_for_route, {route_idf: route_idf})

      Agency.parse(response).map do |agency|
        agency.routes.map do |route|
          route.stops
        end.flatten
      end.flatten
    end

    def get_stops_for_routes(route_infos)
      route_idf = route_infos.map { |route_info| makeRouteIDF(route_info) }.join("|")

      response = get(:get_stops_for_routes, {route_idf: route_idf})

      Agency.parse(response).map do |agency|
        agency.routes.map do |route|
          route.stops
        end.flatten
      end.flatten
    end

    def get_next_departures_by_stop_code(stopcode)
      response = get(:get_next_departures_by_stop_code, stopcode: stopcode)

      Agency.parse(response).map do |agency|
        agency.routes.map do |route|
          route.stops
        end.flatten
      end.flatten.first
    end

    def makeRouteIDF(route_info)
      route_idf = "#{route_info[:agency_name]}~#{route_info[:route_code]}"
      route_idf += "~Inbound" if route_info[:route_direction] == :inbound
      route_idf += "~Outbound" if route_info[:route_direction] == :outbound
      route_idf
    end

    def get(method, options={})
      self.connection.get(method, options)
    end
  end
end
