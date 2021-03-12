# Rack::DiscordInteractions

Middleware to handle signature verification for Discord Interaction HTTP requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-discord-interactions'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rack-discord-interactions

## Usage

```ruby
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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shardlab/rack-discord-interactions. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shardlab/rack-discord-interactions/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::Slash::Commands project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shardlab/rack-discord-interactions/blob/master/CODE_OF_CONDUCT.md).
