# frozen_string_literal: true

require "falkor/version"
require "falkor/download"
require "falkor/download/ruby"
require "falkor/gunzip"
require "falkor/generate_yardoc"

module Falkor
  class Error < StandardError; end
end
