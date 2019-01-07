# frozen_string_literal: true

module Falkor
  module Gems
    class Unpack
      def initialize(file_path)
        @file_path = file_path
      end

      def unpack
        FileUtils.mkdir_p(destination_dir)

        package_source.with_read_io do |io|
          reader = Gem::Package::TarReader.new io

          reader.each do |entry|
            next unless entry.full_name == "data.tar.gz"

            extract_data_gz(entry, &Proc.new)
            break # ignore further entries
          end
        end

        destination_dir
      end

      private

      attr_accessor :file_path

      def destination_dir
        File.join("tmp", "gems", File.basename(file_path, ".gem"))
      end

      def package_source
        @package_source ||= Gem::Package::FileSource.new(file_path)
      end

      def extract_data_gz(entry)
        with_entry_tempfile(entry) do |file|
          Falkor::Gunzip.new(file.path, destination_dir).gunzip(&Proc.new)
        end
      end

      def with_entry_tempfile(entry)
        tempfile = Tempfile.new
        file_name = tempfile.path
        tempfile.write(entry.read)
        tempfile.close

        yield tempfile

        tempfile.close!
        FileUtils.rm_rf File.join(destination_dir, File.basename(file_name))
      end
    end
  end
end

# package = Gem::Package.new Gem::Package::FileSource.new(path), security_policy
# package.extract_files target_dir
