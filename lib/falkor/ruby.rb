# frozen_string_literal: true

require "falkor/concerns/installable"

module Falkor
  class Ruby
    class NotFound < StandardError; end

    include Installable

    RELEASES = "https://raw.githubusercontent.com/ruby/www.ruby-lang.org/"\
               "master/_data/releases.yml"

    class << self
      def search(query)
        versions.keys.map do |version|
          new(version) if version.include? query
        end.compact
      end

      alias :find :new

      def versions
        YAML.
          load_file(Download.new(RELEASES, "ruby_releases.yml").download {}).
          select { |release| release.dig("url", "gz") }.
          map { |release| [release["version"], release.dig("url", "gz")] }.
          to_h
      end
    end

    def initialize(version)
      raise NotFound if self.class.versions[version].nil?

      @version = version
    end

    def other_versions
      self.class.versions.keys.map do |number|
        next if number == version

        self.class.new(number)
      end.compact
    end

    %i(root class method module constant classvariable macro).each do |type|
      define_method("#{type}_objects") do
        store.values_for_type(type)
      end
    end

    private

    attr_reader :version

    def file_name
      "ruby-#{version}.tar.gz"
    end

    def url
      self.class.versions[version]
    end

    def yard_filepath
      File.join(
        Dir.pwd, "tmp", File.basename(file_name, ".tar.gz") + ".falkor"
      )
    end
  end
end
