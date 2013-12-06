$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'click'
require 'securerandom'
require 'rspec/given'

def initialize_models
  Click::Database.with_in_memory_database { }
end

RSpec.configure do |c|
  c.before(:suite) do
    Click::Database.prepare(Sequel.sqlite)
  end
end
