module Click
  module Database
    def self.ensure_tables!(db)
      create_table?(:snapshots) do
        primary_key :id
        Time :timestamp, null: false
      end

      create_table?(:object_counts) do
        primary_key :id
        foreign_key :snapshot_id, :snapshots, null: false
        String :class_name, null: false
        Integer :count, null: false
      end
    end
  end
end
