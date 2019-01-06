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
        downloader.download(&Proc.new)
      end

      private

      attr_accessor :file_name, :link

      def host
        "ftp.ruby-lang.org"
      end

      def downloader
        @downloader ||= Download.new(link, file_name)
      end
    end
  end
end