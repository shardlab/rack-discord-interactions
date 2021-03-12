# frozen_string_literal: true

require 'sinatra'
require 'rack/discord-interactions'
require 'json'

use Rack::DiscordInteractions::Verifier, ENV['INTERACTIONS_PUBLIC_KEY'], path: '/interactions'

post '/interactions' do
  body = JSON.parse(request.body.read)

  case body['type']
  when 2 # COMMAND
    { type: 5 }.to_json
  else
    halt 400, 'Invalid type'
  end
end
