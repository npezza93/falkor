# frozen_string_literal: true

require "rubygems/commands/fetch_command"

module Falkor
  class Download
    class Gem
      def initialize(gem_name, version: nil)
        @gem_name = gem_name
        @version = version
      end

      def download
        FileUtils.mkdir("tmp/gems") unless File.directory?("tmp/gems")

        Dir.chdir("tmp/gems") do
          ::Gem::Commands::FetchCommand.new.invoke_with_build_args(args, nil)
        end
        extract_tar_gz

        yield 100
        tar_file_name
      end

      private

      attr_accessor :gem_name

      def file_name
        File.join("tmp", "gems", "#{gem_name}-#{version}.gem")
      end

      def tar_file_name
        File.join("tmp", "gems", File.basename(file_name, ".gem") + ".tar.gz")
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
          dependency = ::Gem::Dependency.new(
            gem_name, @version || ::Gem::Requirement.default
          )
          specs_and_sources =
            ::Gem::SpecFetcher.fetcher.spec_for_dependency(dependency).first

          spec, _source = specs_and_sources.max_by { |spec,| spec.version }

          spec.version.to_s
        end
      end

      def package_source
        @package_source ||= ::Gem::Package::FileSource.new(file_name)
      end

      def extract_tar_gz
        package_source.with_read_io do |io|
          ::Gem::Package::TarReader.new(io).each do |entry|
            next unless entry.full_name == "data.tar.gz"

            File.open(tar_file_name, "wb") do |f|
              f.write entry.read
            end

            FileUtils.rm file_name
            break # ignore further entries
          end
        end

      end
    end
  end
end
