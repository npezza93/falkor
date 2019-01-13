# frozen_string_literal: true

module Falkor
  module Extract
    class Gem
      def initialize(file_name)
        @file_name = file_name
      end

      def extract
        ::Gem::Package::FileSource.new(file_name).with_read_io do |io|
          ::Gem::Package::TarReader.new(io).each do |entry|
            next unless entry.full_name == "data.tar.gz"

            File.open(tar_file_name, "wb") { |f| f.write entry.read }

            FileUtils.rm file_name
            break # ignore further entries
          end
        end

        tar_file_name
      end

      private

      attr_accessor :file_name

      def tar_file_name
        File.join(Dir.pwd, "tmp", File.basename(file_name, ".gem") + ".tar.gz")
      end
    end
  end
end
