require 'sequel'

module Click
  module Database
    module Models
      class ObjectCount < Sequel::Model
        many_to_one :snapshot

        dataset_module do
          def by_session_name(session_name)
            snapshot_dataset = Snapshot.by_session_name(session_name)
            from_self.qualify.join(snapshot_dataset, id: :snapshot_id)
          end
        end
      end
    end
  end
end
