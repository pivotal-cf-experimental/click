require 'spec_helper'
require 'click/database'

initialize_models

module Click::Database::Models
  describe ObjectCount do
    Given(:parent_session) { Session.create(name: SecureRandom.uuid, started_at: Time.now) }
    Given(:parent_snapshot) { parent_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }
    Given(:object_count) { parent_snapshot.add_object_count(ObjectCount.new(class_name: SecureRandom.uuid, count: 1)) }

    describe 'the .by_session_name scope' do
      Given(:dataset) { ObjectCount.by_session_name(parent_session.name) }

      Then { [object_count] == dataset.all }
    end

    describe '.snapshots' do
      Given(:other_snapshot) { parent_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }
      Given(:other_object_count) { other_snapshot.add_object_count(ObjectCount.new(class_name: SecureRandom.uuid, count: 1)) }

      Given(:dataset) { ObjectCount.where(id: [object_count.id, other_object_count.id]).snapshots }

      Then { expect(dataset.all).to match_array([parent_snapshot, other_snapshot])}
    end
  end
end
