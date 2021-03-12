# frozen_string_literal: true

require 'rack/discord-interactions'
require 'json'

# App to process interaction requests
module Interactions
  def self.call(env)
    body = JSON.parse(env['rack.input'].read)

    case body['type']
    when 2 # COMMAND
      [200, { 'Content-Type' => 'application/json' }, ['{"type": 5}']]
    else
      [400, { 'Content-Type' => 'text/plain' }, ['Invalid type']]
    end
  end
end

app = Rack::Builder.app do
  map '/interactions' do
    use Rack::DiscordInteractions::Verifier, ENV['INTERACTIONS_PUBLIC_KEY']

    run Interactions
  end
end

run app
