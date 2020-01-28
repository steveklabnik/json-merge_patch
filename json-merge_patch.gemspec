# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'json/merge_patch/version'

Gem::Specification.new do |spec|
  spec.name          = 'json-merge_patch'
  spec.version       = JSON::MergePatch::VERSION
  spec.authors       = ['Steve Klabnik']
  spec.email         = ['steve@steveklabnik.com']
  spec.description   = 'An implementation of the json-merge-patch draft.'
  spec.summary       = 'An implementation of the json-merge-patch draft.'
  spec.homepage      = 'http://json-merge-patch.herokuapp.com/'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4.0'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
end
