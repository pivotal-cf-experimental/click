require 'sequel'

module Click
  module Database
    module Models
      class Snapshot < Sequel::Model
        one_to_many :object_counts

        dataset_module do
          def after(time)
            filter { timestamp > time }
          end

          def before(time)
            filter { timestamp < time}
          end

          def by_session_name(session_name)
            session_dataset = Session.where(name: session_name)
            from_self.qualify.join(session_dataset, id: :session_id)
          end
        end
      end
    end
  end
end
