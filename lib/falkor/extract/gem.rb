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
            next if entry.full_name != "data.tar.gz"

            write_tar_file(entry.read)

            remove_file
            break # ignore further entries
          end
        end

        tar_file_name
      end

      private

      attr_reader :file_name

      def write_tar_file(contents)
        File.open(tar_file_name, "wb") do |file|
          file.write contents
        end
      end

      def tar_file_name
        File.join(
          File.dirname(file_name), File.basename(file_name, ".gem") + ".tar.gz"
        )
      end

      def remove_file
        FileUtils.rm file_name
      end
    end
  end
end
