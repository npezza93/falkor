# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "falkor/version"

Gem::Specification.new do |spec|
  spec.name          = "falkor"
  spec.version       = Falkor::VERSION
  spec.authors       = ["Nick Pezza"]
  spec.email         = ["npezza93@gmail.com"]
  spec.license       = "MIT"
  spec.summary       = "A parser that Just Works"

  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency             "gems",     "~> 1.1"
  spec.add_dependency             "yard",     "< 0.10.0"

  spec.add_development_dependency "bundler",  "~> 1.17"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry",      "~> 0.12.2"
  spec.add_development_dependency "rake",     "< 13.0"
  spec.add_development_dependency "rubocop",  "< 1.0.0"
end
