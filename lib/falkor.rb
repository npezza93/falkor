# frozen_string_literal: true

require "falkor/version"

require "falkor/download"
require "falkor/download/ruby"
require "falkor/download/gem"

require "falkor/extract/gem"
require "falkor/extract/tar_gz"

require "falkor/yard/documentation"

require "falkor/ruby"
require "falkor/gem"

module Falkor
  class Error < StandardError; end
end
