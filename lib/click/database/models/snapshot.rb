module Click
  module Database
    module Models
      class Snapshot < Sequel::Model
        one_to_many :object_counts
      end
    end
  end
end
