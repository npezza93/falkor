# frozen_string_literal: true

require "falkor/concerns/installable"
require "gems"

module Falkor
  class GemNotFound < StandardError; end

  class Gem
    include Installable

    attr_accessor :name, :info, :version

    def self.search(query)
      return [] if query.nil? || query.empty?

      Gems.search(query).map do |gem|
        new(**gem.transform_keys(&:to_sym))
      end
    end

    def self.find(query)
      new(**Gems.info(query).transform_keys(&:to_sym))
    end

    def initialize(**attrs)
      gem_info = Gems.info(attrs[:name])

      raise GemNotFound if gem_info.nil? || gem_info.empty?

      self.name    = attrs[:name]
      self.info    = attrs[:info]
      self.version = ::Gem::Version.new(attrs[:version])
    end

    def other_versions
      @other_versions ||= Gems.versions(name).map do |payload|
        version = ::Gem::Version.new(payload["number"])

        next if version == self.version

        self.class.new(name: name, info: info, version: payload["number"])
      end.compact
    end

    %i(root class method module constant classvariable macro).each do |type|
      define_method("#{type}_objects") do
        store.values_for_type(type)
      end
    end

    private

    def file_name
      "#{name}-#{version}.gem"
    end

    def url
      "https://rubygems.org/gems/#{file_name}"
    end

    def yard_filepath
      File.join(Dir.pwd, "tmp", File.basename(file_name, ".gem") + ".falkor")
    end

    def extract(file_path)
      Falkor::Extract::TarGz.new(
        Falkor::Extract::Gem.new(file_path).extract
      ).extract do |progress|
        yield :extracting, progress
      end
    end
  end
end
