# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "falkor/version"

Gem::Specification.new do |spec|
  spec.name          = "falkor"
  spec.version       = Falkor::VERSION
  spec.authors       = "Nick Pezza"
  spec.email         = "npezza93@gmail.com"
  spec.license       = "MIT"
  spec.summary       = %q(A parser that Just Works)

  spec.homepage      = "https://github.com/npezza93/falkor"
  spec.metadata["github_repo"] = "ssh://github.com/npezza93/falkor"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] =
    "https://github.com/npezza93/falkor/releases"

  spec.require_path  = "lib"
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test)/}) }
  end

  spec.required_ruby_version = ">= 2.4.0"

  spec.add_dependency             "gems",     "~> 1.1"
  spec.add_dependency             "yard",     "< 0.10.0"

  spec.add_development_dependency "bundler", ">= 1.17", "< 3"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
