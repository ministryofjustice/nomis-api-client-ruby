require 'spec_helper'

require 'nomis/api'

describe NOMIS::API::ParsedResponse do
  describe '#parse' do
    subject{ described_class.new(response) }

    context 'given a response' do
      let(:response){ double(:response, content_type: content_type, body: body) }

      context 'with content type of application/json' do
        let(:content_type){ 'application/json' }
        let(:body){ '{"a_key": "a value"}' }

        it 'returns the body parsed as JSON' do
          expect(subject.send(:parse, response)).to eq( {'a_key' => 'a value'} )
        end
      end

      context 'with a non-JSON content type' do
        let(:content_type){ 'text/html' }
        let(:body){ 'DB is down' }

        it 'returns the body as-is' do
          expect(subject.send(:parse, response)).to eq(body)
        end
      end
    end
  end
end