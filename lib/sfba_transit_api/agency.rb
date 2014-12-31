module SFBATransitAPI
  class Agency
    attr_accessor :name, :has_direction, :mode, :routes

    def to_s
      "#<SFBATransitAPI::Agency:#{object_id} @name=\"#{name}\", @has_direction=#{has_direction}, @mode=\"#{mode}\", routes.count=#{routes.count}>"
    end

    def has_direction=(has_direction)
      if has_direction.is_a? String
        @has_direction = has_direction.downcase == "true" ? true : false
      else
        @has_direction = has_direction ? true : false
      end
    end

    def self.parse(node)
      node.xpath("//Agency").map do |agency_node|
        agency = new

        agency.name = agency_node["Name"]
        agency.has_direction = agency_node["HasDirection"]
        agency.mode = agency_node["Mode"]
        agency.routes = Route.parse(agency_node, agency)

        agency
      end
    end
  end
end
