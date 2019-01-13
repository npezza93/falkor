# frozen_string_literal: true

module Falkor
  module Installable
    def download
      return yard_filepath if Dir.exist? yard_filepath

      block =
        if block_given?
          Proc.new
        else
          proc {}
        end

      generate_documentation(extract(download_source(&block), &block), &block)
    end

    private

    def download_source
      Falkor::Download.new(url, file_name).download do |progress|
        yield :downloading, progress
      end
    end

    def extract(file_path)
      Falkor::Extract::TarGz.
        new(file_path, has_root_dir: true).
        extract do |progress|
          yield :extracting, progress
        end
    end

    def generate_documentation(file_path)
      Falkor::Yard::Documentation.
        new(file_path, yard_filepath).
        generate do |progress, description|
          yield :generating, progress, description
        end
    end

    def store
      @store ||= begin
        reg_store = YARD::RegistryStore.new
        reg_store.load(download)
        reg_store
      end
    end
  end
end
