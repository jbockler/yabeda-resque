# frozen_string_literal: true

require_relative "resque/version"

require "yabeda"
require "resque"

module Yabeda
  module Resque
    class << self
      def monitor_delayed?
        defined?(::Resque::Scheduler)
      end

      def install!(**options)
        Yabeda.configure do
          group :resque do
            default_options = {aggregation: :most_recent}
            gauge :jobs_pending, **default_options, comment: "Number of pending jobs"
            gauge :jobs_processed, **default_options, comment: "Number of processed jobs"
            gauge :jobs_failed, **default_options, comment: "Number of failed jobs"

            gauge :queue_size, tags: %i[queue], **default_options, comment: "Number of jobs in a specific queue"

            gauge :workers_total, **default_options, comment: "Number of workers"
            gauge :workers_working, **default_options, comment: "Number of workers busy"

            # Plugin for delayed jobs
            if ::Yabeda::Resque.monitor_delayed?
              gauge :jobs_delayed, **default_options, comment: "Number of delayed jobs"
            end
          end

          collect do
            resque_info = ::Resque.info
            resque.jobs_failed.set({}, resque_info[:failed])
            resque.jobs_pending.set({}, resque_info[:pending])
            resque.jobs_processed.set({}, resque_info[:processed])

            if ::Yabeda::Resque.monitor_delayed?
              resque.jobs_delayed.set({}, ::Resque.count_all_scheduled_jobs)
            end

            ::Resque.queue_sizes.each do |queue, size|
              resque.queue_size.set({queue: queue}, size)
            end

            resque.workers_total.set({}, resque_info[:workers])
            resque.workers_working.set({}, resque_info[:working])
          end
        end
      end
    end
  end
end
