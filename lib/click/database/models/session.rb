require 'sequel'

module Click
  module Database
    module Models
      class Session < Sequel::Model
        one_to_many :snapshots

        dataset_module do
          def by_name(name)
            from_self.where(name: name)
          end

          def snapshots
            Snapshot.where(session_id: from_self.map(:id))
          end
        end
      end
    end
  end
end
