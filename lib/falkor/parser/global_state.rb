# frozen_string_literal: true

module Falkor
  class Parser
    class GlobalState
      attr_accessor :ordered_parser, :total_processed, :cruby_processed_files,
                    :cruby_namespaces, :cruby_symbols, :cruby_override_comments,
                    :method_count, :block

      def initialize(ordered_parser, total_processed)
        @ordered_parser = ordered_parser
        @total_processed = total_processed
      end

      def processed(file_name)
        return if block.nil?

        block.call(1, "Parsed #{file_name}")
      end
    end
  end
end
