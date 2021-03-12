# frozen_string_literal: true

require 'ed25519'
require 'json'

module Rack
  # Discord interaction middleware collection
  module DiscordInteractions
    # Middleware to handle verification of interaction signatures
    class Verifier
      # @!visibility private
      MISSING_HEADERS = [400, {}, ['Missing headers']].freeze

      # @!visibility private
      PONG = [200, { 'Content-Type' => 'application/json' }, ['{"type":1}']].freeze

      # @!visibility private
      INVALID_SIGNATURE = [401, {}, ['Invalid request signature']].freeze

      # @param app [#call] The rack app, or an object that responds to `#call`.
      # @param public_key [String] The public key of the application.
      # @param path [String] Path to verify, will verify all requests if `nil`.
      # @param handle_pings [true, false] Whether the middleware should automatically handle responding to pings.
      def initialize(app, public_key, path: nil, handle_pings: true)
        @app = app
        @verify_key = Ed25519::VerifyKey.new([public_key].pack('H*'))
        @path = path
        @handle_pings = handle_pings
      end

      # @!visibility private
      # @param env [Hash]
      def call(env)
        if env['PATH_INFO'] == @path || @path.nil?
          request = Rack::Request.new(env)
          verify(request)
        else
          @app.call(env)
        end
      end

      # @!visibility private
      # @param request [Rack::Request]
      def verify(request)
        timestamp = request.get_header('HTTP_X_SIGNATURE_TIMESTAMP')
        signature = request.get_header('HTTP_X_SIGNATURE_ED25519')
        body = request.body.read

        return MISSING_HEADERS unless timestamp && signature

        @verify_key.verify([signature].pack('H*'), timestamp + body)
        request.body.rewind

        return PONG if @handle_pings && JSON.parse(body)['type'] == 1

        @app.call(request.env)
      rescue ArgumentError, Ed25519::VerifyError
        INVALID_SIGNATURE
      end
    end
  end
end
