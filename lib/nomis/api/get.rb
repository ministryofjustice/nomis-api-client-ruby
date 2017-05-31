require 'uri'
require 'net/http'
require 'pp'
require 'byebug'

require 'nomis/api/auth_token'
require 'nomis/api/parsed_response'

module NOMIS
  module API
    # Convenience wrapper around an API call
    # Manages defaulting of params from env vars,
    # and parsing the returned JSON
    class Get
      attr_accessor :params, :auth_token, :base_url, :path

      def initialize(opts={})
        self.auth_token = opts[:auth_token] || default_auth_token(opts)
        self.base_url   = opts[:base_url] || ENV['NOMIS_API_BASE_URL']
        self.params = opts[:params] || {}
        self.path = opts[:path]
      end

      def execute
        uri = URI.join(base_url, path)
        uri.query = URI.encode_www_form(params)

        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = auth_token

        ParsedResponse.new(get_response(req))
      end

      protected

      def default_auth_token(params={})
        ENV['NOMIS_API_AUTH_TOKEN'] || NOMIS::API::AuthToken.new(params).bearer_token
      end

      def get_response(req)
        http = Net::HTTP.new(req.uri.hostname, req.uri.port)
        http.use_ssl = (req.uri.scheme == "https")
        http.request(req)
      end
    end
  end
end