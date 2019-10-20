# frozen_string_literal: true

require "rubygems/package"
require "falkor/concerns/trackable_progress"

module Falkor
  module Extract
    class TarGz
      include TrackableProgress

      TAR_LONGLINK = "././@LongLink"

      def initialize(file_name, has_root_dir: false)
        @file_name = file_name
        @extraction_destination =
          if has_root_dir
            File.dirname(file_name)
          else
            source_destination
          end
      end

      def extract
        return source_destination if Dir.exist? source_destination

        FileUtils.mkdir_p extraction_destination

        block = block_given? ? Proc.new : proc {}

        report_progress(:write_each_tarfile, open_file(&:count), &block)
        FileUtils.rm file_name
        source_destination
      end

      private

      attr_reader :file_name, :extraction_destination

      def source_destination
        @source_destination ||= File.join(
          File.dirname(file_name), File.basename(file_name, ".tar.gz")
        )
      end

      def write_each_tarfile
        open_file do |tar|
          current_destination = nil
          tar.each do |tarfile|
            current_destination =
              handle_longlink_or_write(tarfile, current_destination)
            yield(1)
          end
        end
      end

      def open_file
        File.open(file_name, "rb") do |file|
          return_value = nil
          Zlib::GzipReader.wrap(file) do |gz|
            ::Gem::Package::TarReader.new(gz) do |tar|
              return_value = yield tar
            end
          end
          return_value
        end
      end

      def write_tarfile(tarfile, current_destination)
        current_destination ||=
          File.join extraction_destination, tarfile.full_name

        if directory?(tarfile)
          write_directory(tarfile, current_destination)
        elsif file?(tarfile)
          write_file(tarfile, current_destination)
        elsif tarfile.header.typeflag == "2" # Symlink
          File.symlink tarfile.header.linkname, current_destination
        end
        nil
      end

      def directory?(file)
        file.directory? || file.full_name.end_with?("/")
      end

      def file?(file)
        file.file? || !file.full_name.end_with?("/")
      end

      def write_directory(file, dest)
        File.delete dest if File.file? dest
        FileUtils.mkdir_p dest, mode: file.header.mode, verbose: false
      end

      def write_file(file, dest)
        if File.directory? dest
          FileUtils.rm_rf dest
        else
          FileUtils.mkdir_p(File.dirname(dest))
        end

        File.open dest, "wb" do |f|
          f.print file.read
        end
        FileUtils.chmod file.header.mode, dest, verbose: false
      end

      def handle_longlink_or_write(tarfile, dest)
        if tarfile.full_name == TAR_LONGLINK
          File.join extraction_destination, tarfile.read.strip
        else
          write_tarfile(tarfile, dest)
        end
      end
    end
  end
end
