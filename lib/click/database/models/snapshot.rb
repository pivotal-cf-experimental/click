require 'sequel'
require 'set'

module Click
  module Database
    module Models
      class Snapshot < Sequel::Model
        many_to_one :session
        one_to_many :object_counts

        def difference(earlier)
          earlier_object_count_hash = Hash[earlier.object_counts_dataset.map([:class_name, :count])]
          later_object_count_hash = Hash[object_counts_dataset.map([:class_name, :count])]

          keys = Set.new(earlier_object_count_hash.keys + later_object_count_hash.keys)

          diff = {}
          keys.each do |key|
            diff[key] = later_object_count_hash.fetch(key, 0) - earlier_object_count_hash.fetch(key, 0)
          end

          diff
        end

        dataset_module do
          def after(time)
            filter { timestamp > time }
          end

          def before(time)
            filter { timestamp < time }
          end

          def by_session_name(session_name)
            session_dataset = Session.where(name: session_name)
            from_self.qualify.join(session_dataset, id: :session_id)
          end

          def sessions
            Session.where(id: from_self.map(:session_id).uniq)
          end

          def object_counts
            ObjectCount.where(snapshot_id: from_self.map(:id).uniq)
          end
        end
      end
    end
  end
end
