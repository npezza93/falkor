# frozen_string_literal: true

require "rubygems/package"
require "falkor/concerns/trackable_progress"

TAR_LONGLINK = "././@LongLink"

module Falkor
  class Gunzip
    include TrackableProgress

    def initialize(source, destination)
      @source = source
      @destination = destination
    end

    def gunzip
      FileUtils.rm_rf destination_dir
      FileUtils.mkdir_p destination_dir

      report_progress(:write_each_tarfile, open_file(&:count), &Proc.new)
      destination_dir
    end

    private

    attr_accessor :source, :destination, :track_progress

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
      File.open(source, "rb") do |file|
        return_value = nil
        Zlib::GzipReader.wrap(file) do |gz|
          Gem::Package::TarReader.new(gz) do |tar|
            return_value = yield tar
          end
        end
        return_value
      end
    end

    def write_tarfile(tarfile, current_destination)
      current_destination ||= File.join destination, tarfile.full_name

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
      FileUtils.rm_rf dest if File.directory? dest
      File.open dest, "wb" do |f|
        f.print file.read
      end
      FileUtils.chmod file.header.mode, dest, verbose: false
    end

    def handle_longlink_or_write(tarfile, dest)
      if tarfile.full_name == TAR_LONGLINK
        File.join destination, tarfile.read.strip
      else
        write_tarfile(tarfile, dest)
      end
    end

    def destination_dir
      File.join(destination, File.basename(source, ".tar.gz"))
    end
  end
end
