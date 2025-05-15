# frozen_string_literal: true

require_relative "resque/version"

require "yabeda"
require "resque"

module Yabeda
  module Resque
    class << self
      DEFAULT_CONFIG = {
        jobs_processing_oldest_age_unit: nil
      }.freeze

      def monitor_delayed?
        defined?(::Resque::Scheduler)
      end

      def jobs_processing_oldest_age(config)
        oldest_timestamp = ::Resque.working.map { |worker| worker.job(false)["run_at"] }.min
        return 0 if oldest_timestamp.nil?
        age_in_seconds = (Time.now - Time.parse(oldest_timestamp)).to_i
        return 0 if age_in_seconds < 0

        case config[:jobs_processing_oldest_age_unit]
        when :seconds
          age_in_seconds
        when :minutes
          age_in_seconds / 60.0
        when :hours
          age_in_seconds / 3600.0
        when :days
          age_in_seconds / 86_400.0
        else
          raise ArgumentError, "Unsupported time unit: #{unit.inspect}"
        end
      end

      def install!(**config)
        config = DEFAULT_CONFIG.merge(config)

        Yabeda.configure do
          group :resque do
            default_options = {aggregation: :most_recent}
            gauge :jobs_pending, **default_options, comment: "Number of pending jobs"
            gauge :jobs_processed, **default_options, comment: "Number of processed jobs"
            gauge :jobs_failed, **default_options, comment: "Number of failed jobs"

            if config[:jobs_processing_oldest_age_unit]
              gauge :jobs_processing_oldest_age, **default_options, comment: "How long the longest processing job has been running in #{config[:jobs_processing_oldest_age_unit]}"
            end

            gauge :queue_sizes, tags: %i[queue], **default_options, comment: "Number of jobs in a specific queue"

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

            if config[:jobs_processing_oldest_age_unit]
              value = ::Yabeda::Resque.jobs_processing_oldest_age(config)
              resque.jobs_processing_oldest_age.set({}, value)
            end

            if ::Yabeda::Resque.monitor_delayed?
              resque.jobs_delayed.set({}, ::Resque.count_all_scheduled_jobs)
            end

            ::Resque.queue_sizes.each do |queue, size|
              resque.queue_sizes.set({queue: queue}, size)
            end

            resque.workers_total.set({}, resque_info[:workers])
            resque.workers_working.set({}, resque_info[:working])
          end
        end
      end
    end
  end
end
