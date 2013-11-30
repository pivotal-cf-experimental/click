require 'spec_helper'
require 'click/database'
require 'click/database/writer'

describe Click::Database::Writer do
  it 'writes records to the database' do
    with_in_memory_db do |db|
      writer = Click::Database::Writer.new(db)
      clicker = Click::Clicker.new
      clicker.add_observer(writer)

      expect(Click::Database::Models::Snapshot.count).to eq(0)
      expect(Click::Database::Models::ObjectCount.count).to eq(0)

      before_time = Time.now
      clicker.click!
      after_time = Time.now

      expect(Click::Database::Models::Snapshot.count).to eq(1)
      expect(Click::Database::Models::ObjectCount.count).to be > 0
      snapshot = Click::Database::Models::Snapshot.first
      expect(snapshot.object_counts.count).to eq(Click::Database::Models::ObjectCount.count)
      expect(snapshot.timestamp).to be >= before_time
      expect(snapshot.timestamp).to be <= after_time
    end
  end
end
