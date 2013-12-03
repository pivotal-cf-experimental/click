require 'sequel'

module Click
  module Database
    module Models
      class Session < Sequel::Model
        one_to_many :snapshot
      end
    end
  end
end
