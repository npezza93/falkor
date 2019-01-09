# frozen_string_literal: true

require "yard"

module Falkor
  class Store
    def initialize(yardoc_file_path)
      @store = YARD::RegistryStore.new
      store.load(yardoc_file_path)
    end

    %i(root class method module constant classvariable macro).each do |type|
      define_method("values_for_#{type}") do
        store.values_for_type(type)
      end
    end

    private

    attr_accessor :store
  end
end
