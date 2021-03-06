<p align="center">
  <a href="https://github.com/npezza93/falkor">
    <img src="./.github/logo.jpg" width="350">
  </a>
</p>


# Falkor

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'falkor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install falkor

## Usage


#### Ruby Core and Stlib

```ruby
store = Falkor::Ruby.new(version).generate do |action, progress, description|
  puts action, progress, description
end
```

#### Remote Gem

```ruby
store = Falkor::Gem.new(name, version: (optional)).generate do |action, progress, description|
  puts action, progress, description
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, execute bin/publish (major|minor|patch) which will update the version number in version.rb, create a git tag for the version, push git commits and tags, and push the .gem file to rubygems.org and GitHub.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/npezza93/falkor. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Falkor project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/npezza93/falkor/blob/master/CODE_OF_CONDUCT.md).
