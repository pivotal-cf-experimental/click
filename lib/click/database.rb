require 'sequel'

module Click
  module Database
    class << self
      def with_database(connection_string)
        _with_db(Sequel.connect(connection_string)) do |db|
          yield db
        end
      end

      def with_in_memory_database
        require 'sqlite3'
        _with_db(Sequel.sqlite) do |db|
          yield db
        end
      end

      private
      def _with_db(db)
        ensure_tables!(db)
        Sequel::Model.db = db
        require 'click/database/models'
        yield db
      ensure
        Models::ObjectCount.dataset.delete
        Models::Snapshot.dataset.delete
        db = nil
        Sequel::Model.db = nil
      end

      def ensure_tables!(db)
        db.create_table?(:snapshots) do
          primary_key :id
          Time :timestamp, null: false
        end

        db.create_table?(:object_counts) do
          primary_key :id
          foreign_key :snapshot_id, :snapshots, null: false
          String :class_name, null: false
          Integer :count, null: false
        end
      end
    end
  end
end
