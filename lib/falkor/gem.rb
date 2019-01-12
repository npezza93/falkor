# frozen_string_literal: true

module Falkor
  class Gem
    def initialize(name, version: nil)
      @name = name
      @version = version
    end

    def generate
      gzip_file_path = download(&Proc.new)
      extracted_path = gunzip(gzip_file_path, &Proc.new)

      yardoc_filename = File.basename(extracted_path)
      yardoc_filepath =
        generate_yardoc(extracted_path, "." + yardoc_filename, &Proc.new)

      FileUtils.mv(yardoc_filepath, File.join("tmp", yardoc_filename))
      FileUtils.rm(gzip_file_path)
      FileUtils.rm_rf(extracted_path)
      Falkor::Store.new(yardoc_filepath)
    end

    private

    attr_accessor :name, :version

    def download
      Falkor::Download::Gem.new(name, version: version).download do |progress|
        yield :downloading, progress
      end
    end

    def gunzip(gzip_file_path)
      Falkor::Gunzip.new(gzip_file_path).gunzip do |progress|
        yield :extracting, progress
      end
    end

    def generate_yardoc(extracted_path, yardoc_filename)
      Falkor::GenerateYardoc.
        new(extracted_path, yardoc_filename).
        generate do |progress, description|
          yield :generating, progress, description
        end
    end
  end
end
