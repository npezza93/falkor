# frozen_string_literal: true

require "test_helper"

module Falkor
  module Extract
    class GemTest < Minitest::Test
      def setup
        FileUtils.mkdir_p "tmp"
        FileUtils.cp("test/fixtures/redi_search.gem", "tmp/redi_search.gem")
      end

      def teardown
        FileUtils.rm_rf("tmp/redi_search.tar.gz")
      end

      def test_extract
        refute File.exist?("tmp/redi_search.tar.gz")

        extractor = Falkor::Extract::Gem.new("tmp/redi_search.gem")
        assert_equal "tmp/redi_search.tar.gz", extractor.extract {}

        assert File.exist?("tmp/redi_search.tar.gz")
        refute File.exist?("tmp/redi_search.gem")
      end
    end
  end
end
