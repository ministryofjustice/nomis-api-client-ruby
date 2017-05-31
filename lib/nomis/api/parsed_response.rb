require 'json'

module NOMIS
  module API
    # decorates a Net::HTTP response with a data method,
    # which parses the JSON in the response body
    class ParsedResponse
      attr_accessor :raw_response, :body, :status, :data

      def initialize(raw_response)
        self.raw_response = raw_response
        self.data = JSON.parse(raw_response.body)
      end

      def body
        raw_response.body
      end
      def status
        raw_response.code
      end
    end
  end
end