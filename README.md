# Click

[![Build Status](https://travis-ci.org/pivotal-cf-experimental/click.png?branch=master)](https://travis-ci.org/pivotal-cf-experimental/click)

A tool to track down object leaks in a Ruby process.

## Installation

Add this line to your application's Gemfile:

    gem 'click', git: "https://github.com/pivotal-cf-experimental/click.git"

And then execute:

    $ bundle

## Example

See [the demo app](demo/app.rb) for an example of a simple Sinatra app that uses an existing Sequel database and that leaks objects when connecting to a certain endpoint.
Try running the app and then running `click-console /tmp/click_demo_memory.sqlite` to inspect the live database.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
