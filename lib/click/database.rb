require 'sequel'

module Click
  module Database
    class << self
      def with_database(connection_string)
        db = Sequel.connect(connection_string)
        ensure_tables!(db)
        Sequel::Model.db = db
        require 'click/database/models'
        yield db
      ensure
        db = nil
        Sequel::Model.db = nil
      end

      private
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
