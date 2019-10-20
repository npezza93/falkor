# frozen_string_literal: true

require "test_helper"

module Falkor
  class GemTest < Minitest::Test # rubocop:disable Metrics/ClassLength
    def teardown
      FileUtils.rm_rf("tmp/redi_search-2.0.1")
      FileUtils.rm_rf("tmp/redi_search-2.0.1.falkor")
    end

    def test_search_class_method_when_blank_is_passed
      assert_equal [], Falkor::Gem.search(nil)
      assert_equal [], Falkor::Gem.search("")
    end

    def test_search_class_method_when_nothing_is_found
      VCR.use_cassette("empty_search") do
        assert_equal [], Falkor::Gem.search("nonexistent_gem")
      end
    end

    def test_search_class_method
      VCR.use_cassette("rails_search") do
        assert Falkor::Gem.search("rails").all? do |gem|
          assert_instance_of Falkor::Gem, gem
        end
      end
    end

    def test_find_when_version_is_nil_and_not_found
      VCR.use_cassette("empty_find") do
        assert_raises(Gems::NotFound) { find("nonexistent_gem") }
      end
    end

    def test_find_when_version_is_nil_and_found
      VCR.use_cassette("rails_find") do
        assert_instance_of Falkor::Gem, find("rails")
      end
    end

    def test_find_when_version_is_present_and_not_found
      VCR.use_cassette("empty_find_v2") do
        assert_raises(Gems::NotFound) { find("nonexistent_gem", "1.0.0") }
      end
    end

    def test_find_when_version_is_present_and_found
      VCR.use_cassette("rails_find_v2") do
        assert_instance_of Falkor::Gem, find("rails", "6.0.0")
      end
    end

    def test_name
      VCR.use_cassette("rails_find") do
        assert_equal "rails", find("rails").name
      end
    end

    def test_name_v2
      VCR.use_cassette("rails_find_v2") do
        assert_equal "rails", find("rails", "6.0.0").name
      end
    end

    def test_info
      VCR.use_cassette("rails_find") do
        assert_equal rails_description, find("rails").info
      end
    end

    def test_info_v2
      VCR.use_cassette("rails_find_v2") do
        assert_equal rails_description, find("rails", "6.0.0").info
      end
    end

    def test_version
      VCR.use_cassette("rails_find") do
        version = find("rails").version
        assert_instance_of ::Gem::Version, version
        assert_equal "6.0.0", version.to_s
      end
    end

    def test_version_v2
      VCR.use_cassette("rails_find_v2") do
        version = find("rails", "6.0.0").version
        assert_instance_of ::Gem::Version, version
        assert_equal "6.0.0", version.to_s
      end
    end

    def test_created_at
      VCR.use_cassette("rails_find") { assert_nil find("rails").created_at }
    end

    def test_created_at_v2
      VCR.use_cassette("rails_find_v2") do
        assert_equal(Time.parse("2019-08-16T18:01:50.039Z"),
                     find("rails", "6.0.0").created_at)
      end
    end

    def test_project_uri
      VCR.use_cassette("rails_find") do
        assert_equal("https://rubyonrails.org", find("rails").project_uri)
      end
    end

    def test_project_uri_v2
      VCR.use_cassette("rails_find_v2") do
        assert_equal("https://rubyonrails.org",
                     find("rails", "6.0.0").project_uri)
      end
    end

    def test_other_versions
      VCR.use_cassette("rails_versions") do
        versions = find("rails", "6.0.0").other_versions
        assert versions.all? { |gem| assert_instance_of(Falkor::Gem, gem) }
        assert_equal 353, versions.size
      end
    end

    def test_root_objects
      VCR.use_cassette("redi_search_find") do
        assert_respond_to find("redi_search"), :root_objects
      end
    end

    def test_method_objects
      VCR.use_cassette("redi_search_find") do
        assert_respond_to find("redi_search"), :method_objects
      end
    end

    def test_module_objects
      VCR.use_cassette("redi_search_find") do
        assert_respond_to find("redi_search"), :module_objects
      end
    end

    def test_constant_objects
      VCR.use_cassette("redi_search_find") do
        assert_respond_to find("redi_search"), :constant_objects
      end
    end

    def test_classvariable_objects
      VCR.use_cassette("redi_search_find") do
        assert_respond_to find("redi_search"), :classvariable_objects
      end
    end

    def test_class_objects
      VCR.use_cassette("redi_search_find") do
        redi_search = find("redi_search")
        refute_empty redi_search.class_objects
      end
    end

    private

    def find(name, version = nil)
      Falkor::Gem.find(name, version)
    end

    def rails_description
      "Ruby on Rails is a full-stack web framework optimized for programmer "\
      "happiness and sustainable productivity. It encourages beautiful code "\
      "by favoring convention over configuration."
    end
  end
end
