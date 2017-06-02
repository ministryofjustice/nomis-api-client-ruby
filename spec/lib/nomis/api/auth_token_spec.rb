require 'spec_helper'

require 'nomis/api'

describe NOMIS::API::AuthToken do
  describe '#payload' do
    describe 'return value' do
      it 'is a Hash' do
        expect(subject.payload).to be_a(Hash)
      end

      it 'has token set to the client_token' do
        subject.client_token = 'my client token'
        expect(subject.payload[:token]).to eq('my client token')
      end

      it 'has iat set to current_timestamp + iat_fudge_factor' do
        subject.now = 33
        subject.iat_fudge_factor = 10
        expect(subject.payload[:iat]).to eq(43)
      end
    end
  end

  describe '#bearer_token' do
    context 'when the keys are valid' do
      before do
        allow(subject).to receive(:validate_keys!)
        allow(subject).to receive(:auth_token).and_return('generated auth token')
      end

      it 'returns "Bearer auth_token"' do
        expect(subject.bearer_token).to eq('Bearer generated auth token')
      end
    end
    context 'when the keys are not valid' do
      before do
        allow(subject).to receive(:validate_keys!).and_raise(NOMIS::API::TokenMismatchError)
      end

      it 'raises a TokenMismatchError' do
        expect { subject.bearer_token }.to raise_error(NOMIS::API::TokenMismatchError)
      end
    end
  end

  describe '#validate_keys!' do
    context 'when client_public_key_base64 equals expected_client_public_key' do
      before do
        allow(subject).to receive(:client_public_key_base64)
          .and_return('abc1')
        allow(subject).to receive(:expected_client_public_key)
          .and_return('abc1')
      end

      it 'does not raise a TokenMismatchError' do
        expect { subject.validate_keys! }.to_not raise_error
      end
    end

    context 'when client_public_key_base64 does not equal expected_client_public_key' do
      before do
        allow(subject).to receive(:client_public_key_base64)
          .and_return('abc123')
        allow(subject).to receive(:expected_client_public_key)
          .and_return('def456')
      end

      it 'raises a TokenMismatchError' do
        expect { subject.validate_keys! }.to raise_error(
          NOMIS::API::TokenMismatchError
        )
      end
    end
  end

  describe '#auth_token' do
    before do
      allow(subject).to receive(:payload).and_return 'my payload'
      allow(subject).to receive(:client_key).and_return 'my client key'
    end

    it 'JWT-encodes the payload with the client_key via the ES256 algorithm' do
      expect(JWT).to receive(:encode).with(
        'my payload', 'my client key', 'ES256'
      )
      subject.send(:auth_token)
    end

    it 'returns the JWT-encoded payload' do
      allow(JWT).to receive(:encode).and_return('encoded auth token')
      expect(subject.send(:auth_token)).to eq('encoded auth token')
    end
  end
end