require 'sequel'

module Click
  module Database
    module Models
      class ObjectCount < Sequel::Model
        many_to_one :snapshot
      end
    end
  end
end
