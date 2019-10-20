# frozen_string_literal: true

require "falkor/concerns/installable"
require "gems"

module Falkor
  class Gem
    include Installable

    attr_accessor :name, :info, :version, :created_at, :project_uri

    class << self
      def search(query)
        return [] if query.nil? || query.empty?

        Gems.search(query).map do |gem|
          new(**gem.transform_keys(&:to_sym))
        end
      end

      def find(query, version = nil)
        gem_info =
          if version.nil?
            Gems.info(query)
          else
            rubygems_v2_info(query, version)
          end

        new(**gem_info.transform_keys(&:to_sym))
      end

      private

      def rubygems_v2_info(gem_name, version)
        response = Gems::Client.new.get(
          "/api/v2/rubygems/#{gem_name}/versions/#{version}.json"
        )
        JSON.parse(response)
      rescue JSON::ParserError
        {}
      end
    end

    def initialize(**attrs)
      self.name        = attrs[:name]
      self.info        = attrs[:info]
      self.created_at  = attrs[:created_at] && Time.parse(attrs[:created_at])
      self.project_uri = attrs[:homepage_uri]
      self.version     = ::Gem::Version.new(attrs[:version])
    end

    def other_versions
      @other_versions ||= Gems.versions(name).map do |payload|
        next if payload["number"] == version

        self.class.new(
          name: name,
          info: payload["summary"],
          version: payload["number"],
          created_at: payload["created_at"]
        )
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
