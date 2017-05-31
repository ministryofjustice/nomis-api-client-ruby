require 'uri'
require 'net/http'
require 'pp'

require 'nomis/api/auth_token'
require 'nomis/api/parsed_response'

module NOMIS
  module API
    # Convenience wrapper around an API call
    # Manages defaulting of params from env vars,
    # and parsing the returned JSON
    class Post
      attr_accessor :params, :auth_token, :base_url, :path

      def initialize(opts={})
        self.auth_token = opts[:auth_token] || default_auth_token(opts)
        self.base_url   = opts[:base_url] || ENV['NOMIS_API_BASE_URL']
        self.params = opts[:params]
        self.path = opts[:path]
      end

      def execute
        uri = URI.join(base_url, path)

        req = Net::HTTP::Post.new(uri)
        req['Authorization'] = auth_token
        req['Accept'] = 'application/json, */*'
        req['Content-type'] = 'application/json'

        ParsedResponse.new(post_response(req))
      end

      protected

      def default_auth_token(params={})
        ENV['NOMIS_API_AUTH_TOKEN'] || NOMIS::API::AuthToken.new(params).bearer_token
      end


      def post_response(req)
        http = Net::HTTP.new(req.uri.hostname, req.uri.port)
        http.use_ssl = (req.uri.scheme == 'https')
        req.body = params.to_json
        http.request(req)
      end

      def stringify_hash(data)
        h={}
        data.each{|k,v| h[k.to_s] = v }
        h
      end

    end
  end
end