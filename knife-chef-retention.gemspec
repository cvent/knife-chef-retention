# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)
require "knife-chef-retention/version"

Gem::Specification.new do |s|
  s.name        = "knife-chef-retention"
  s.version     = Knife::ChefRetention::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = "Brent Montague"
  s.email       = "bmontague@cvent.com"
  s.homepage    = "https://github.com/cvent/knife-chef-retention"
  s.summary     = "Chef Knife plugin to help cleanup old items on the Chef Server"
  s.description = "A knife plugin to handle deleting of items in a safe manor"

  s.license     = "Apache License, v2.0"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = "~> 3.1"

  s.add_dependency "chef", ">= 18.4"
end
