# frozen_string_literal: true

require "rubygems/commands/fetch_command"

module Falkor
  module Gems
    class Fetch
      def initialize(gem_name, version = nil)
        @gem_name = gem_name
        @version = version
      end

      def fetch
        FileUtils.mkdir("tmp/gems") unless File.directory?("tmp/gems")

        Dir.chdir("tmp/gems") do
          Gem::Commands::FetchCommand.new.invoke_with_build_args(args, nil)
        end

        file_name
      end

      private

      attr_accessor :gem_name

      def file_name
        File.join("tmp", "gems", "#{gem_name}-#{version}.gem")
      end

      def args
        if @version
          [gem_name, "-v", @version]
        else
          [gem_name]
        end
      end

      def version
        @version ||= begin
          dependency = Gem::Dependency.new(
            gem_name, @version || Gem::Requirement.default
          )
          specs_and_sources =
            Gem::SpecFetcher.fetcher.spec_for_dependency(dependency).first

          specs_and_sources.max_by do |spec, _source| 
            spec.version
          end.first.version.to_s
        end
      end
    end
  end
end
