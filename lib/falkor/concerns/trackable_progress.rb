# frozen_string_literal: true

require "falkor/progress_tracker"

module Falkor
  module TrackableProgress
    def report_progress(method_to_run, total, *args)
      progress_tracker = ProgressTracker.new(total)
      send(method_to_run, *args) do |progress, description = nil|
        progress_tracker.progress(progress, description, &Proc.new)
      end
    end
  end
end
