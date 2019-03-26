# frozen_string_literal: true
Gem::Specification.new do |spec|
  spec.name = 'syro-tilt'
  spec.version = '0.2.0'
  spec.authors = ['Evan Lecklider']
  spec.email = ['evan@lecklider.com']
  spec.summary = 'Render Tilt templates in Syro routes.'
  spec.description = 'Render Tilt templates in Syro routes.'
  spec.homepage = 'https://github.com/evanleck/syro-tilt'
  spec.license = 'MIT'
  spec.files = `git ls-files`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'syro', '~> 3.0'
  spec.add_dependency 'tilt', '~> 2.0'

  spec.add_development_dependency 'bundler', '>= 1.7'
  spec.add_development_dependency 'erubi', '>= 1.8'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
