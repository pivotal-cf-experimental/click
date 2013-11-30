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
        end
      end
    end
  end
end
