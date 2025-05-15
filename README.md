# Yabeda::Resque

[Yabeda](https://github.com/yabeda-rb/yabeda) metrics for your [Resque](https://github.com/resque/resque) jobs.

There are other options like [yabeda-activejob](https://github.com/Fullscript/yabeda-activejob), but this gem is specifically for Resque without ActiveJob.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add yabeda-resque

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install yabeda-resque

## Usage

Add the following code to your existing Yabeda setup:

```ruby
Yabeda::Resque.install!
```

## Configuration

Configuration can be passed to the `Yabeda::Resque.install!` method, e.g.: `Yabeda::Resque.install!(option_name: :value)` The following options are available:

* `jobs_processing_oldest_age_unit`:
    The unit of the `jobs_processing_oldest_age` metric. This can be set to `:seconds`, `:minutes`, `:hours` or `:days`. The default value is nil, which means the metric is turned off and will not collected.

## Provided metrics

| Metric name       | Type  | Tags     | Description                                          |
|-------------------|-------|----------|------------------------------------------------------|
| `jobs_pending`    | gauge | none     | Number of jobs in all queues                         |
| `jobs_processed`  | gauge | none     | Number of jobs processed                             |
| `jobs_failed`     | gauge | none     | Number of jobs currently failed                      |
| `workers_total`   | gauge | none     | Number of workers                                    |
| `workers_working` | gauge | none     | Number of workers currently working                  |
| `queue_sizes`     | gauge | queue (name) | Number of jobs in a specific queue                   |
| `jobs_processing_oldest_age`     | gauge | none     | Age of the oldest processing job (unit configurable) |

Yabeda::Resque detects if [resque-scheduler](https://github.com/resque/resque-scheduler) is being used and adds the following metrics:

| Metric name    | Type  | Tags         | Description            |
|----------------|-------|--------------|------------------------|
| `jobs_delayed` | gauge | none         | Number of delayed jobs |

Please note that due to the design of the resque-scheduler the delayed jobs are not
included in the `queue_sizes` metric. Gathering this information can be quite expensive when there are a lot of delayed jobs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jbockler/yabeda-resque. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jbockler/yabeda-resque/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Yabeda::Resque project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jbockler/yabeda-resque/blob/main/CODE_OF_CONDUCT.md).
