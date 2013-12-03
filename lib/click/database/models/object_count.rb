require 'sequel'

module Click
  module Database
    module Models
      class ObjectCount < Sequel::Model
        many_to_one :snapshot

        dataset_module do
          def by_session_name(session_name)
            session_dataset = Session.where(name: session_name)
            snapshot_dataset = Snapshot.join(session_dataset, id: :session_id)
            from_self.join(snapshot_dataset, id: :snapshot_id)
          end
        end
      end
    end
  end
end
