$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'payload/version'
require 'date'

Gem::Specification.new do |s|
  s.authors = ['thoughtbot', 'Joe Ferris']
  s.description = 'Dependency configuration and injection for Ruby and Rails.'
  s.email = 'support@thoughtbot.com'
  s.extra_rdoc_files = %w(LICENSE README.md CONTRIBUTING.md)
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/thoughtbot/payload'
  s.license = 'MIT'
  s.name = %q{payload}
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')
  s.summary = 'Dependency configuration and injection for Ruby and Rails.'
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.version = Payload::VERSION

  s.add_development_dependency 'rack'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.1.0'
end
