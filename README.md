# Yabeda::Resque

[Yabeda](https://github.com/yabeda-rb/yabeda) metrics for your [Resque](https://github.com/resque/resque) jobs.

There are other options like [yabeda-activejob](https://github.com/Fullscript/yabeda-activejob), but this gem is specifically for Resque without ActiveJob.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add yabeda-resque

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install yabea-resque

## Usage

Add the following code to your application:

```ruby
Yabeda::Resque.install!
```

## Provided metrics

| Metric name       | Type  | Tags         | Description                         |
|-------------------|-------|--------------|-------------------------------------|
| `jobs_pending`    | gauge | none         | Number of jobs in all queues        |
| `jobs_processed`  | gauge | none         | Number of jobs processed            |
| `jobs_failed`     | gauge | none         | Number of jobs currently failed     |
| `workers_total`   | gauge | none         | Number of workers                   |
| `workers_working` | gauge | none         | Number of workers currently working |
| `queue_size`       | gauge | queue (name) | Number of jobs in a specific queue  |


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/yabeda-resque. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/yabeda-resque/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Yabeda::Resque project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/yabeda-resque/blob/main/CODE_OF_CONDUCT.md).
