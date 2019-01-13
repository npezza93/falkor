# frozen_string_literal: true

require "falkor/progress"

module Falkor
  module TrackableProgress
    def report_progress(method_to_run, total, *args)
      progress = Progress.new(total)
      send(method_to_run, *args) do |amount, description = nil|
        progress.increment!(amount, description, &Proc.new)
      end
    end
  end
end
