# frozen_string_literal: true

RSpec.describe Yabeda::Resque do
  around(:each) do |example|
    Yabeda::Resque.install!
    Resque.redis = MockRedis.new
    original_inline = Resque.inline

    example.run

    Resque.inline = original_inline
  end

  it "has a version number" do
    expect(Yabeda::Resque::VERSION).not_to be nil
  end

  context "when job is enqueued" do
    it "increments successful job counter" do
      Resque.enqueue(DefaultJob)
      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_pending)
        .with(1)
    end
  end

  context "when job is processed" do
    it "increments successful job counter" do
      Resque.inline = true
      Resque.enqueue(DefaultJob)

      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_processed)
        .with(1)
    end
  end

  context "when a job fails" do
    it "increments successful job counter" do
      Resque.inline = true
      Resque.enqueue(DefaultJob)

      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.jobs_failed)
        .with(1)
    end
  end

  context "workers" do
    it "collects workers count" do
      Resque.inline = true
      Resque.enqueue(DefaultJob)

      expect { Yabeda.collect! }.to \
        update_yabeda_gauge(Yabeda.resque.workers_total)
        .with(1)
        .and update_yabeda_gauge(Yabeda.resque.workers_working)
        .with(0)
    end
  end
end
