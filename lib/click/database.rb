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

      def prepare(sequel_db)
        ensure_tables!(sequel_db)
        assign_db_to_models(sequel_db)
        sequel_db
      end

      private
      def _with_db(db)
        prepare(db)
        yield db
      end

      def assign_db_to_models(db)
        require 'click/database/models'
        Click::Database::Models::Session.db ||= db
        Click::Database::Models::Snapshot.db ||= db
        Click::Database::Models::ObjectCount.db ||= db
      end

      def ensure_tables!(db)
        db.create_table?(:sessions) do
          primary_key :id
          String :name, null: false
          Time :started_at, null: false
        end

        db.create_table?(:snapshots) do
          primary_key :id
          foreign_key :session_id, :sessions, null: false
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
