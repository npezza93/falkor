# frozen_string_literal: true

require "falkor/concerns/trackable_progress"
require "yard"

module Falkor
  class GenerateYardoc
    include TrackableProgress

    FILE_GLOB =
      YARD::Parser::SourceParser::DEFAULT_PATH_GLOB + ["*.c", "ext/**/*.rb"]

    def initialize(source_dir, yardoc_file = ".yardoc")
      @source_dir = source_dir
      @yardoc_file = yardoc_file
    end

    def generate
      in_source_dir do
        with_yardoc_file do
          YARD::Registry.lock_for_writing do
            parser = YARD::Parser::OrderedParser.new(OpenStruct.new, files)

            parser.parse(&Proc.new)
            YARD::Registry.save(true)
          end
        end
      end

      File.join(Dir.pwd, source_dir, yardoc_file)
    end

    private

    attr_accessor :source_dir, :yardoc_file

    def files
      @files ||=
        FILE_GLOB.map do |path|
          path = "#{path}/**/*.{rb,c,cc,cxx,cpp}" if File.directory?(path)
          path = Dir[path].sort_by { |d| [d.length, d] } if path.include?("*")

          path
        end.flatten.select { |p| File.file?(p) }
    end

    def in_source_dir
      Dir.chdir(File.join(Dir.pwd, source_dir)) { yield }
    end

    def with_yardoc_file
      YARD::Registry.yardoc_file = yardoc_file
      yield
      YARD::Registry.yardoc_file = nil
    end
  end
end