# frozen_string_literal: true

module Falkor
  class Download
    class Ruby
      def initialize(version)
        minor_version = version.rpartition(".").first
        @file_name = "ruby-#{version}.tar.gz"
        @link = "http://#{host}/pub/ruby/#{minor_version}/#{file_name}"
      end

      def download
        FileUtils.mkdir("tmp/rubies") unless File.directory?("tmp/rubies")

        downloader.download(&Proc.new)
      end

      private

      attr_accessor :file_name, :link

      def host
        "ftp.ruby-lang.org"
      end

      def downloader
        @downloader ||= Download.new(link, File.join("rubies", file_name))
      end
    end
  end
end
