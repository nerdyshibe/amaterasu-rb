# frozen_string_literal: true

require_relative 'lib/amaterasu/version'

Gem::Specification.new do |spec|
  spec.name = 'amaterasu'
  spec.version = Amaterasu::VERSION
  spec.authors = ['Fernando Eufrásio']
  spec.summary = 'A cycle-accurate Game Boy emulator written in Ruby'
  spec.homepage = 'https://github.com/nerdyshibe/amaterasu-rb'
  spec.license = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = 'https://github.com/nerdyshibe/amaterasu/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|bench|bin)/|^\.|^Gemfile|^Rakefile})
  end

  spec.bindir = 'exe'
  spec.executables = ['amaterasu']
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi', '>= 1.15.5'
  spec.add_dependency 'zeitwerk', '>= 2.8.2'

  spec.required_ruby_version = '>= 3.2.0'
end
