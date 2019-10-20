# frozen_string_literal: true

module Falkor
  class Progress
    def initialize(total)
      @total = total
      @current = 0
      @previous = 0
    end

    def increment!(amount, description)
      self.previous, self.current = current, current + amount

      return if percentage(previous) == percentage(current) && !description

      yield percentage(current), description
    end

    private

    attr_reader :total
    attr_accessor :current, :previous

    def percentage(amount)
      (amount.to_f / total * 100).to_i
    end
  end
end
