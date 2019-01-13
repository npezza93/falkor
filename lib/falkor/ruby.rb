# frozen_string_literal: true

module Falkor
  class VersionNotFound < StandardError; end
  class Ruby
    VERSIONS = {
      "2.6.0" =>
        "https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.0.tar.gz",
      "2.5.3" =>
        "https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.3.tar.gz",
      "2.4.5" =>
        "https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.5.tar.gz",
      "2.3.8" =>
        "https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.8.tar.gz",
    }.freeze

    def self.search(query)
      return [] if query.nil? || query.empty?

      VERSIONS.keys.map do |version|
        next unless version.include? query

        new(version)
      end.compact
    end

    def self.find(query)
      new(query)
    end

    def initialize(version)
      raise VersionNotFound if VERSIONS[version].nil?

      @version = version
    end

    def other_versions
      VERSIONS.keys.map do |number|
        next if number == version

        self.class.new(number)
      end.compact
    end

    %i(root class method module constant classvariable macro).each do |type|
      define_method("#{type}_objects") do
        store.values_for_type(type)
      end
    end

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

    attr_accessor :version

    def file_name
      "ruby-#{version}.tar.gz"
    end

    def url
      VERSIONS[version]
    end

    def yard_filepath
      File.join(
        Dir.pwd, "tmp", File.basename(file_name, ".tar.gz") + ".falkor"
      )
    end

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
