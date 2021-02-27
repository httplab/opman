# frozen_string_literal: true

$LOAD_PATH.push(File.expand_path("lib", __dir__))

# Maintain your gem's version:
require "op/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "opman"
  spec.version     = Op::VERSION
  spec.authors     = ["Alex Vasyutin"]
  spec.email       = ["alex@httplab.ru"]
  spec.homepage    = "https://github.com/httplab/opman"
  spec.summary     = "Op is operations manager"
  spec.description = "Op is set of tools which help to organize business logic in a Rails application"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 2.7.2"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://gems.httplab.ru"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency("rails", ">= 5.2.1")
  spec.add_development_dependency("pg")
end
