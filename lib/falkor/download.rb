# frozen_string_literal: true

require "falkor/concerns/trackable_progress"

module Falkor
  class Download
    include TrackableProgress

    def initialize(url, file_name)
      @url = url
      @file_name = file_name
    end

    def download
      request do |response, file_size|
        next unless success?(response)

        report_progress(:write_chunks, file_size, response, &Proc.new)
        destination
      end
    end

    private

    attr_accessor :url, :file_name, :track_progress

    def request
      uri = URI(url)
      return_value = nil

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(Net::HTTP::Get.new(uri)) do |response|
          return_value = yield response, response["content-length"].to_i
        end
      end

      return_value
    end

    def write_chunks(response)
      FileUtils.mkdir_p "tmp"
      FileUtils.rm_rf destination

      File.open(destination, "wb") do |file|
        response.read_body do |chunk|
          file.write chunk

          yield(chunk.size)
        end
      end
    end

    def success?(response)
      (200..299).cover?(response.code.to_i)
    end

    def destination
      File.join(Dir.pwd, "tmp", file_name)
    end
  end
end
