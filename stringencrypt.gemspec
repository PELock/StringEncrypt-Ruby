# frozen_string_literal: true

require_relative "lib/stringencrypt/version"

Gem::Specification.new do |spec|
  spec.name = "pelock-stringencrypt"
  spec.version = StringEncrypt::VERSION
  spec.authors = ["Bartosz Wójcik"]
  spec.email = ["support@pelock.com"]
  spec.summary = "StringEncrypt Web API Ruby SDK"
  spec.homepage = "https://www.stringencrypt.com"
  spec.license = "Apache-2.0"
  spec.required_ruby_version = ">= 2.7.0"
  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/PELock/StringEncrypt-Ruby",
    "bug_tracker_uri" => "https://www.pelock.com"
  }
end
