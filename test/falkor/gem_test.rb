# frozen_string_literal: true

require "test_helper"

module Falkor
  class GemTest < Minitest::Test
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
        assert_raises Gems::NotFound do
          Falkor::Gem.find("nonexistent_gem")
        end
      end
    end

    def test_find_when_version_is_nil_and_found
      VCR.use_cassette("rails_find") do
        assert_instance_of Falkor::Gem, Falkor::Gem.find("rails")
      end
    end

    def test_find_when_version_is_present_and_not_found
      VCR.use_cassette("empty_find_v2") do
        assert_raises Gems::NotFound do
          Falkor::Gem.find("nonexistent_gem", "1.0.0")
        end
      end
    end

    def test_find_when_version_is_present_and_found
      VCR.use_cassette("rails_find_v2") do
        assert_instance_of Falkor::Gem, Falkor::Gem.find("rails", "6.0.0")
      end
    end

    def test_name
      VCR.use_cassette("rails_find") do
        assert_equal "rails", Falkor::Gem.find("rails").name
      end

      VCR.use_cassette("rails_find_v2") do
        assert_equal "rails", Falkor::Gem.find("rails", "6.0.0").name
      end
    end

    def test_info
      expected = "Ruby on Rails is a full-stack web framework optimized for "\
                 "programmer happiness and sustainable productivity. It "\
                 "encourages beautiful code by favoring convention over "\
                 "configuration."
      VCR.use_cassette("rails_find") do
        assert_equal expected, Falkor::Gem.find("rails").info
      end

      VCR.use_cassette("rails_find_v2") do
        assert_equal expected, Falkor::Gem.find("rails", "6.0.0").info
      end
    end

    def test_version
      VCR.use_cassette("rails_find") do
        version = Falkor::Gem.find("rails").version
        assert_instance_of ::Gem::Version, version
        assert_equal "6.0.0", version.to_s
      end

      VCR.use_cassette("rails_find_v2") do
        version = Falkor::Gem.find("rails", "6.0.0").version
        assert_instance_of ::Gem::Version, version
        assert_equal "6.0.0", version.to_s
      end
    end

    def test_created_at
      VCR.use_cassette("rails_find") do
        assert_nil Falkor::Gem.find("rails").created_at
      end

      VCR.use_cassette("rails_find_v2") do
        assert_equal(
          Time.parse("2019-08-16T18:01:50.039Z"),
          Falkor::Gem.find("rails", "6.0.0").created_at
        )
      end
    end

    def test_project_uri
      url = "https://rubyonrails.org"

      VCR.use_cassette("rails_find") do
        assert_equal(url, Falkor::Gem.find("rails").project_uri)
      end

      VCR.use_cassette("rails_find_v2") do
        assert_equal(url, Falkor::Gem.find("rails", "6.0.0").project_uri)
      end
    end
  end
end
