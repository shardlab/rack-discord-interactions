# frozen_string_literal: true

require_relative 'lib/rack/discord-interactions/version'

Gem::Specification.new do |spec|
  spec.name          = 'rack-discord-interactions'
  spec.version       = Rack::DiscordInteractions::VERSION
  spec.authors       = ['Matthew Carey']
  spec.email         = ['matthew.b.carey@gmail.com']

  spec.summary       = 'Rack middleware for Discord Interactions.'
  spec.description   = 'Rack middleware for Discord Interaction validation.'
  spec.homepage      = 'https://github.com/shardlab/rack-discord-interactions'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/shardlab/rack-discord-interactions'
  spec.metadata['changelog_uri'] = 'https://github.com/shardlab/rack-discord-interactions/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ed25519', '>= 1.0.0', '< 2.0.0'
  spec.add_dependency 'rack', '>= 2.0.0', '< 3.0.0'
  spec.add_development_dependency 'rake', '~> 13.0.3'
  spec.add_development_dependency 'rspec', '~> 3.10.0'
  spec.add_development_dependency 'rubocop', '~> 1.9.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.9.2'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2.0'
  spec.add_development_dependency 'yard', '~> 0.9.26'
end
