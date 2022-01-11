# frozen_string_literal: true

require_relative 'lib/novel_scraping/version'

Gem::Specification.new do |spec|
  spec.name          = 'novel_scraping'
  spec.version       = NovelScraping::VERSION
  spec.authors       = ['ciloholic']
  spec.email         = ['']

  spec.summary       = 'novel_scraping helps scraping novel sites.'
  spec.description   = ''
  spec.homepage      = 'https://github.com/ciloholic'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.1.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'rack'
end
