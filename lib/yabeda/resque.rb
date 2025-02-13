# frozen_string_literal: true

require_relative "resque/version"

require "yabeda"
require "resque"

module Yabeda
  module Resque
    class << self
      def install!
        Yabeda.configure do
          group :resque do
            gauge :jobs_pending, aggregation: :most_recent, comment: "Number of pending jobs"
            gauge :jobs_processed, aggregation: :most_recent, comment: "Number of processed jobs"
            gauge :jobs_failed, aggregation: :most_recent, comment: "Number of failed jobs"

            gauge :workers_total, aggregation: :most_recent, comment: "Number of workers"
            gauge :workers_working, aggregation: :most_recent, comment: "Number of workers busy"
          end

          collect do
            resque_info = ::Resque.info
            resque.jobs_failed.set({}, resque_info[:failed])
            resque.jobs_pending.set({}, resque_info[:pending])
            resque.jobs_processed.set({}, resque_info[:processed])

            resque.workers_total.set({}, resque_info[:workers])
            resque.workers_working.set({}, resque_info[:working])
          end
        end
      end
    end
  end
end
