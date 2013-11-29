module Click
  module Database
    module Models
      class ObjectCount < Sequel::Model
        many_to_one :snapshots
      end
    end
  end
end
