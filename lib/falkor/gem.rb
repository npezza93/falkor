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
      yardoc_file = generate_yardoc(extracted_path, &Proc.new)

      Falkor::Store.new(yardoc_file)
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

    def generate_yardoc(extracted_path)
      Falkor::GenerateYardoc.
        new(extracted_path).
        generate do |progress, description|
          yield :generating, progress, description
        end
    end
  end
end
