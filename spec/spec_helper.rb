$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'click'
require 'securerandom'
require 'rspec/given'

def test_db
  $click_test_db ||= Click::Database.prepare(Sequel.sqlite)
end

def with_in_memory_db
  Click::Database.with_in_memory_database do |db|
    Click::Database::Models::ObjectCount.dataset.delete
    Click::Database::Models::Snapshot.dataset.delete

    yield db
  end
end

def initialize_models
  Click::Database.with_in_memory_database { }
end
