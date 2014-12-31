require 'faraday'
require 'active_support/core_ext/string'
require 'nokogiri'

module SFBATransitAPI
  class Connection

    attr_accessor :token, :path_prefix

    def initialize(token, options={})
      self.token = token
      self.path_prefix = options.fetch(:path_prefix, PATH_PREFIX)

      @connection = Faraday.new(:url => options.fetch(:api_endpoint, API_ENDPOINT))
    end

    def get(method, options={})
      path = "#{path_prefix}/#{method.to_s.camelize}.aspx"
      params = options_to_params(options)
      params["token"] = token

      response = request(path, params)

      if response.status != 200
        raise ResponseException, "Server responded with #{response.status}"
      end

      xml_doc = Nokogiri::XML(response.body)

      error_node = xml_doc.at_xpath("/transitServiceError")

      if error_node
        raise ResponseException, error_node.text
      end

      xml_doc
    end

    def request(path, params)
      @connection.get path, params
    end

    def options_to_params(options)
      options.inject({}) do |memo, pair|
        key = pair[0].to_s.camelize(:lower).sub(/idf/i, "IDF")
        value = pair[1]
        memo[key] = value
        memo
      end
    end
  end
end
