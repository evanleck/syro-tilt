# frozen_string_literal: true
Gem::Specification.new do |spec|
  spec.name    = 'syro-tilt'
  spec.version = '0.2.1'
  spec.authors = ['Evan Lecklider']
  spec.email   = ['evan@lecklider.com']

  spec.summary     = 'Render Tilt templates in Syro routes.'
  spec.description = 'Render Tilt templates in Syro routes.'
  spec.homepage    = 'https://github.com/evanleck/syro-tilt'
  spec.license     = 'MIT'
  spec.files       = %w[lib/syro/tilt.rb lib/syro/tilt/cache.rb README.md LICENSE.txt]
  spec.test_files  = Dir.glob('test/**/*')

  spec.platform                  = Gem::Platform::RUBY
  spec.require_path              = 'lib'
  spec.required_ruby_version     = '>= 2.3.0'
  spec.required_rubygems_version = '>= 2.0'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/evanleck/syro-tilt/issues',
    'source_code_uri' => 'https://github.com/evanleck/syro-tilt'
  }

  spec.add_dependency 'syro', '~> 3.0'
  spec.add_dependency 'tilt', '~> 2.0'

  spec.add_development_dependency 'bundler', '>= 1.7'
  spec.add_development_dependency 'erubi', '>= 1.8'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
