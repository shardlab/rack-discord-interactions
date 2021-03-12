# frozen_string_literal: true

require 'rack/discord-interactions'
require 'rack/mock'

RSpec.describe Rack::DiscordInteractions::Verifier do
  let(:app) { ->(env) { [200, env, []] } }
  let(:signing_key) { Ed25519::SigningKey.generate }
  let(:public_key) { signing_key.verify_key.to_bytes.unpack1('H*') }
  let(:verifier) do
    described_class.new(app, public_key, path: '/interactions')
  end

  describe '#initialize' do
    it 'converts the public key into a verifying key' do
      middleware_key = verifier.instance_variable_get(:@verify_key)

      expect(middleware_key.to_str).to eq signing_key.verify_key.to_str
    end
  end

  describe '#call' do
    context 'when the request matches the provided route' do
      it 'verifies the request' do
        allow(verifier).to receive(:verify)

        verifier.call(Rack::MockRequest.env_for('/interactions'))

        expect(verifier).to have_received(:verify).with an_instance_of(Rack::Request)
      end
    end

    context 'when the request does not match the provided route' do
      it 'does not verify the request' do
        allow(verifier).to receive(:verify)

        verifier.call(Rack::MockRequest.env_for('/not-interactions'))

        expect(verifier).not_to have_received(:verify)
      end

      it 'forwards the env to the app' do
        allow(app).to receive(:call)
        env = Rack::MockRequest.env_for('/not_interactions')

        verifier.call(env)

        expect(app).to have_received(:call).with env
      end
    end

    describe '#verify' do
      let(:request) { Rack::Request.new(Rack::MockRequest.env_for('/interactions')) }

      before do
        ts = Time.now.to_i.to_s
        data = '{"type": 2}'

        request.set_header('HTTP_X_SIGNATURE_TIMESTAMP', ts)
        request.set_header('HTTP_X_SIGNATURE_ED25519', signing_key.sign("#{ts}#{data}").unpack1('H*'))

        request.body.string = data
      end

      context 'when the timestamp header is missing' do
        before do
          request.delete_header('HTTP_X_SIGNATURE_TIMESTAMP')
        end

        it 'returns a bad request response' do
          response = Rack::MockResponse.new(*verifier.verify(request))

          expect(response.bad_request?).to be true
        end
      end

      context 'when the ed25519 header is missing' do
        it 'returns a bad request response' do
          request.delete_header('HTTP_X_SIGNATURE_ED25519')
          response = Rack::MockResponse.new(*verifier.verify(request))

          expect(response.bad_request?).to be true
        end
      end

      context 'when the signature is invalid' do
        it 'returns an unauthorized response' do
          request.set_header('HTTP_X_SIGNATURE_ED25519', 'invalid')
          response = Rack::MockResponse.new(*verifier.verify(request))

          expect(response.unauthorized?).to be true
        end
      end

      context 'when the signature does not match' do
        before do
          request.set_header('HTTP_X_SIGNATURE_ED25519', signing_key.sign('invalid').unpack1('H*'))
        end

        it 'returns an unauthorized response' do
          response = Rack::MockResponse.new(*verifier.verify(request))

          expect(response.unauthorized?).to be true
        end
      end

      context 'when the signature matches' do
        it 'passes the env to the app' do
          allow(app).to receive(:call)

          verifier.verify(request)

          expect(app).to have_received(:call).with(request.env)
        end
      end

      context 'when it is a ping' do
        before do
          allow(app).to receive(:call)
          ts = Time.now.to_i.to_s
          data = '{"type": 1}'

          request.set_header('HTTP_X_SIGNATURE_TIMESTAMP', ts)
          request.set_header('HTTP_X_SIGNATURE_ED25519', signing_key.sign("#{ts}#{data}").unpack1('H*'))

          request.body.string = data
        end

        it 'automatically responds to pings' do
          response = Rack::MockResponse.new(*verifier.verify(request))
          expect(JSON.parse(response.body)['type']).to eq 1
        end
      end

      context 'when handle_pings is false' do
        let(:verifier) do
          described_class.new(app, public_key, path: '/interactions', handle_pings: false)
        end

        before do
          allow(app).to receive(:call)
          ts = Time.now.to_i.to_s
          data = '{"type": 1}'

          request.set_header('HTTP_X_SIGNATURE_TIMESTAMP', ts)
          request.set_header('HTTP_X_SIGNATURE_ED25519', signing_key.sign("#{ts}#{data}").unpack1('H*'))

          request.body.string = data
        end

        it 'passes the env to the app' do
          verifier.verify(request)

          expect(app).to have_received(:call).with(request.env)
        end
      end

      it 'verifies the signature' do
        response = Rack::MockResponse.new(*verifier.verify(request))
        expect(response.successful?).to be true
      end
    end
  end
end
