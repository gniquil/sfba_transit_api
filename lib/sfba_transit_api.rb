require_relative "./sfba_transit_api/stop"
require_relative "./sfba_transit_api/direction"
require_relative "./sfba_transit_api/route"
require_relative "./sfba_transit_api/agency"
require_relative "./sfba_transit_api/connection"
require_relative "./sfba_transit_api/client"

module SFBATransitAPI

  API_ENDPOINT = "http://services.my511.org"
  PATH_PREFIX = "/Transit2.0"

  class ResponseException < Exception
  end

  def self.client(token, options={})
    Client.new(token, options)
  end
end
