# frozen_string_literal: true

require "falkor/concerns/installable"

module Falkor
  class VersionNotFound < StandardError; end

  class Ruby
    include Installable

    RELEASES = "https://raw.githubusercontent.com/ruby/www.ruby-lang.org/"\
               "master/_data/releases.yml"

    def self.versions
      YAML.
        load_file(Download.new(RELEASES, "ruby_releases.yml").download {}).
        select { |release| release.dig("url", "gz") }.
        map { |release| [release["version"], release.dig("url", "gz")] }.
        to_h
    end

    def self.search(query)
      return [] if query.nil? || query.empty?

      versions.keys.map do |version|
        next unless version.include? query

        new(version)
      end.compact
    end

    def self.find(query)
      new(query)
    end

    def initialize(version)
      raise VersionNotFound if self.class.versions[version].nil?

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
