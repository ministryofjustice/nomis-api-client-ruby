require 'json'

module NOMIS
  module API
    # decorates a Net::HTTP response with a data method,
    # which parses the JSON in the response body
    class ParsedResponse
      attr_accessor :raw_response, :body, :status, :data

      def initialize(raw_response)
        self.raw_response = raw_response
        self.data = parse(raw_response)
      end

      def body
        raw_response.body
      end

      def parse(response)
        response.content_type == 'application/json' ? \
            JSON.parse(response.body) : response.body
      end

      def status
        raw_response.code
      end
    end
  end
end