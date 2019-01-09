# frozen_string_literal: true

require "falkor/version"
require "falkor/download"
require "falkor/download/ruby"
require "falkor/download/gem"
require "falkor/gunzip"
require "falkor/generate_yardoc"
require "falkor/store"

require "falkor/ruby"
require "falkor/gem"

module Falkor
  class Error < StandardError; end
end
