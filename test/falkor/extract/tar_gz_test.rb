# frozen_string_literal: true

require "test_helper"

module Falkor
  module Extract
    class TarGzTest < Minitest::Test
      def setup
        FileUtils.mkdir_p "tmp"
        FileUtils.cp("test/fixtures/tar.tar.gz", "tmp/tar.tar.gz")
      end

      def teardown
        FileUtils.rm_rf("tmp/tar")
      end

      def test_extract
        refute File.exist?("tmp/tar/tar_dir/folder/tar_file")

        extractor = Falkor::Extract::TarGz.new("tmp/tar.tar.gz")
        assert_equal "tmp/tar", extractor.extract {}

        assert File.exist?("tmp/tar/tar_dir/folder/tar_file")
        refute File.exist?("tmp/tar.tar.gz")
      end
    end
  end
end
