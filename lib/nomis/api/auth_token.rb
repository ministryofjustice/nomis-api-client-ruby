require 'base64'
require 'jwt'
require 'openssl'

module NOMIS
  module API
    # Encapsulates the complexity of generating a JWT bearer token
    class AuthToken
      attr_accessor :client_token, :client_key, :iat_fudge_factor, :now

      # iat_fudge_factor allows you to correct for time drift between your
      # client and the target server.
      # For instance, if the server time is more than 10s in the future, it
      # will reject any client-generated bearer tokens on the grounds of
      # 'iat skew too large' (the timestamp in your payload is too old)
      # In that case, you can pass an iat_fudge_factor of, say, 5, to generate a
      # timestamp tagged 5s into the future and bring it back within the
      # acceptable range.
      def initialize(params = {})
        self.client_key = OpenSSL::PKey::EC.new( params[:client_key] \
                            || default_client_key(params)
                          )
        self.client_token = params[:client_token] \
                          || default_client_token(params)

        self.iat_fudge_factor = default_iat_fudge_factor(params)
      end

      def bearer_token
        validate_keys!

        "Bearer #{auth_token}"
      end

      def payload
        {
          iat: current_timestamp + iat_fudge_factor,
          token: client_token
        }
      end

      # Validate that the supplied private key matches the token's public key.
      # Obviously this step is optional, but when testing locally it's
      # easy to get one's private keys in a muddle, and the API gateway's
      # error message can only say that the generated JWT token does not
      # validate.
      def validate_keys!
        unless client_public_key_base64 == expected_client_public_key
          raise TokenMismatchError, 
                'Incorrect private key supplied ' \
                + '(does not match public key within token)',
                caller
        end
      end

      protected

      def auth_token
        JWT.encode(payload, client_key, 'ES256')
      end

      def client_public_key_base64
        client_public_key = OpenSSL::PKey::EC.new client_key
        client_public_key.private_key = nil
        Base64.strict_encode64(client_public_key.to_der)
      end

      def expected_client_public_key
        JWT.decode(client_token, nil, nil)[0]['key']
      end

      def current_timestamp
        now || Time.now.to_i
      end

      def default_client_key(params = {})
        path = params[:client_key_file] || ENV['NOMIS_API_CLIENT_KEY_FILE']
        path ? read_client_key_file(path) : nil
      end
      
      def default_client_token(params = {})
        path = params[:client_token_file] || ENV['NOMIS_API_CLIENT_TOKEN_FILE']
        path ? read_client_key_file(path) : nil
      end

      def default_iat_fudge_factor(params={})
        ENV['NOMIS_API_IAT_FUDGE_FACTOR'].to_i || 0
      end

      def read_client_token_file(path)
        File.open(File.expand_path(path), 'r').read.chomp('')
      end

      def read_client_key_file(path)
        File.open(File.expand_path(path), 'r').read
      end

    end
  end
end