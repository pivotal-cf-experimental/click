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
        end
      end
    end
  end
end
