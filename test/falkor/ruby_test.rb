# frozen_string_literal: true

require "test_helper"

module Falkor
  class RubyTest < Minitest::Test
    def teardown
      FileUtils.rm_rf("tmp/ruby_releases.yml")
    end

    def test_search
      VCR.use_cassette("ruby_versions") do
        results = Falkor::Ruby.search("2.6.0")

        assert_equal 6, results.size
        assert_instance_of Falkor::Ruby, results.first
      end
    end

    def test_search_when_not_found
      VCR.use_cassette("ruby_versions") do
        assert_empty Falkor::Ruby.search("thing")
      end
    end

    def test_versions
      VCR.use_cassette("ruby_versions") do
        assert Falkor::Ruby.versions.values.all?
        assert_instance_of Hash, Falkor::Ruby.versions
      end
    end

    def test_find
      VCR.use_cassette("ruby_versions") do
        assert_instance_of Falkor::Ruby, Falkor::Ruby.find("2.6.0")
      end
    end

    def test_find_when_not_found
      VCR.use_cassette("ruby_versions") do
        assert_raises Falkor::Ruby::NotFound do
          Falkor::Ruby.find("2.6.20")
        end
      end
    end

    def test_other_versions
      VCR.use_cassette("ruby_versions") do
        versions = Falkor::Ruby.find("2.6.0").other_versions

        refute_empty versions
        assert_instance_of Falkor::Ruby, versions.first
      end
    end

    def test_root_objects
      VCR.use_cassette("ruby_versions") do
        assert_respond_to Falkor::Ruby.find("2.6.0"), :root_objects
      end
    end

    def test_method_objects
      VCR.use_cassette("ruby_versions") do
        assert_respond_to Falkor::Ruby.find("2.6.0"), :method_objects
      end
    end

    def test_module_objects
      VCR.use_cassette("ruby_versions") do
        assert_respond_to Falkor::Ruby.find("2.6.0"), :module_objects
      end
    end

    def test_constant_objects
      VCR.use_cassette("ruby_versions") do
        assert_respond_to Falkor::Ruby.find("2.6.0"), :constant_objects
      end
    end

    def test_classvariable_objects
      VCR.use_cassette("ruby_versions") do
        assert_respond_to Falkor::Ruby.find("2.6.0"), :classvariable_objects
      end
    end

    # def test_class_objects
    #   VCR.use_cassette("ruby_2.6.0") do
    #     refute_empty Falkor::Ruby.find("2.6.0").class_objects
    #   end
    # end
  end
end
