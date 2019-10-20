# frozen_string_literal: true

if ENV["COV"]
  require "simplecov"

  SimpleCov.start do
    add_filter "/test/"
  end
end

require "minitest/autorun"
require "minitest/pride"
require "pry"
require "falkor"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
