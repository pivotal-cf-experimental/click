$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'click'

def with_in_memory_db
  Click::Database.with_in_memory_database do |db|
    yield db
  end
end

def initialize_models
  # ignore this implementation
  Click::Database.with_in_memory_database { }
end
