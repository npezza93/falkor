# frozen_string_literal: true

module Falkor
  class ProgressTracker
    def initialize(total)
      @total = total
      @current = 0
      @previous = 0
    end

    def progress(amount)
      self.previous, self.current = current, current + amount

      return if percentage(previous) == percentage(current)

      yield percentage(current)
    end

    private

    attr_accessor :total, :current, :previous

    def percentage(amount)
      (amount.to_f / total * 100).to_i
    end
  end
end