# frozen_string_literal: true

require "rubygems/package"
require "falkor/concerns/trackable_progress"

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
        tar.each do |tarfile|
          write_tarfile(tarfile)
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

    def write_tarfile(tarfile)
      destination_file = File.join(destination, tarfile.full_name)

      if directory?(tarfile)
        FileUtils.mkdir_p destination_file
      else
        FileUtils.mkdir_p(File.dirname(tarfile.full_name))

        File.open(destination_file, "wb") { |f| f.write(tarfile.read) }
        File.chmod(tarfile.header.mode, destination_file)
      end
    end

    def directory?(file)
      file.directory? || file.full_name.end_with?("/")
    end

    def destination_dir
      File.join(destination, File.basename(source, ".tar.gz"))
    end
  end
end
