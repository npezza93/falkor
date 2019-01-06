# frozen_string_literal: true

require "falkor/parser/global_state"
require "yard"

module Falkor
  class Parser
    attr_accessor :files, :global_state

    def initialize(global_state, files)
      @global_state = global_state || GlobalState.new(self, 0)

      @files = files.dup
    end

    def parse
      global_state.block = Proc.new if block_given?

      until files.empty?
        file = files.shift
        YARD::Parser::SourceParser.new(
          YARD::Parser::SourceParser.parser_type, global_state
        ).parse(file)

        global_state.processed(file)
      end
    end
  end
end
