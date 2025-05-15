# frozen_string_literal: true

RSpec.describe Yabeda::Resque do
  around(:each) do |example|
    Yabeda::Resque.install!
    Resque.redis = MockRedis.new
    original_inline = Resque.inline

    example.run

    Timecop.unfreeze
    Resque.inline = original_inline
  end

  it "has a version number" do
    expect(Yabeda::Resque::VERSION).not_to be nil
  end

  context "when job is enqueued" do
    it "increments enqueued job counter" do
      Resque.enqueue(DefaultJob)
      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_pending)
        .with(1)
    end

    it "increments queue size" do
      Resque.enqueue(DefaultJob)
      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.queue_sizes)
        .with_tags({queue: "default"})
        .with(1)
    end

    context "when other queue is used" do
      it "increments queue size for other queue" do
        Resque.enqueue_to(:other, DefaultJob)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.queue_sizes)
          .with_tags({queue: "other"})
          .with(1)
      end
    end
  end

  context "when job is processed" do
    it "increments successful job counter" do
      allow(::Resque).to receive(:info).and_return({
        processed: 1
      })

      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_processed)
        .with(1)
    end
  end

  context "when a job is being worked on" do
    let(:start_time) { Time.now.utc }
    let(:queue) { "default" }
    let(:working_workers) do
      [
        Resque::Worker.new(queue).tap { |w| w.job = {"queue" => "default", "run_at" => start_time.iso8601, "payload" => []} },
        Resque::Worker.new(queue).tap { |w| w.instance_variable_set :@job, {"queue" => "default", "run_at" => (start_time - 60).iso8601, "payload" => []} },
        Resque::Worker.new(queue).tap { |w| w.instance_variable_set :@job, {"queue" => "default", "run_at" => (start_time - 75).iso8601, "payload" => []} }
      ]
    end

    before(:each) do
      allow(::Resque).to receive(:working).and_return(working_workers)
    end

    context "when configured to measure in seconds" do
      before(:each) do
        Yabeda::Resque.install!(jobs_processing_oldest_age_unit: :seconds)
      end

      it "increments the jobs_processing_oldest_age" do
        Timecop.freeze(start_time)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(75)

        Timecop.travel(15)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(90)
      end
    end

    context "when configured to measure in minutes" do
      before(:each) do
        Yabeda::Resque.install!(jobs_processing_oldest_age_unit: :minutes)
      end

      it "increments the jobs_processing_oldest_age" do
        Timecop.freeze(start_time)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(1.25)

        Timecop.travel(15)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(1.5)
      end
    end

    context "when configured to measure in hours" do
      before(:each) do
        Yabeda::Resque.install!(jobs_processing_oldest_age_unit: :hours)
      end

      it "increments the jobs_processing_oldest_age" do
        Timecop.freeze(start_time + 3600 - 75)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age).with(1)

        Timecop.travel(3600 * 1.5)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(2.5)
      end
    end

    context "when configured to measure in days" do
      before(:each) do
        Yabeda::Resque.install!(jobs_processing_oldest_age_unit: :days)
      end

      it "increments the jobs_processing_oldest_age" do
        # 1 day later, but ignore the 75 seconds to get clean values
        Timecop.freeze(Time.at(start_time + (24 * 60 * 60) - 75))
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(1)

        Timecop.travel(24 * 60 * 60 * 1.5)
        expect { Yabeda.collect! }.to \
          update_yabeda_gauge(Yabeda.resque.jobs_processing_oldest_age)
          .with(2.5)
      end
    end
  end

  context "when a job fails" do
    it "increments failed job counter" do
      allow(::Resque).to receive(:info).and_return({
        failed: 1
      })

      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_failed)
        .with(1)
    end
  end

  context "when a job is delayed" do
    it "increments delayed job counter" do
      Resque.enqueue_in(1, DefaultJob)
      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_delayed)
        .with(1)
    end
  end

  context "workers" do
    it "collects workers count" do
      allow(::Resque).to receive(:info).and_return({
        workers: 1,
        working: 0
      })

      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.workers_total)
        .with(1)
        .and update_yabeda_gauge(Yabeda.resque.workers_working)
        .with(0)
    end
  end
end
