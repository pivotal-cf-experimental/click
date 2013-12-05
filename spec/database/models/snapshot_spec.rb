require 'spec_helper'
require 'click/database'

initialize_models

module Click::Database::Models
  describe Snapshot do
    Given!(:parent_session) { Session.create(name: SecureRandom.uuid, started_at: Time.now) }
    describe 'the .before, .after scopes' do
      Given!(:earlier) { Snapshot.create(timestamp: Date.new(2000), session_id: parent_session.id) }
      Given!(:later) { Snapshot.create(timestamp: Date.new(2006), session_id: parent_session.id) }
      Given(:dataset) { parent_session.snapshots_dataset }

      Then { dataset.before(Date.new(2003)).all == [earlier] }
      And { dataset.after(Date.new(2003)).all == [later] }
    end

    describe 'the .by_session_name dataset' do
      Given!(:snapshot) { Snapshot.create(timestamp: Time.now, session_id: parent_session.id) }
      Given(:dataset) { Snapshot.by_session_name(parent_session.name) }

      Then { dataset.all == [snapshot] }
    end

    describe 'the .sessions dataset' do
      Given(:other_parent_session) { Session.create(name: SecureRandom.uuid, started_at: Time.now) }
      Given(:other_snapshot) { other_parent_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }

      Given(:snapshot) { parent_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }
      Given(:dataset) { Snapshot.where(id: [snapshot.id, other_snapshot.id]) }

      Then { expect(dataset.sessions.all).to match_array([parent_session, other_parent_session]) }
    end

    describe '.object_counts' do
      Given(:snapshot) { parent_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }
      Given(:class_name) { SecureRandom.uuid }
      Given(:object_count) { snapshot.add_object_count(ObjectCount.new(class_name: class_name, count: 5)) }
      Given(:dataset) { Snapshot.where(id: snapshot.id) }

      Then { [object_count] == dataset.object_counts.all }
    end

    describe '#difference' do
      Given(:first_snapshot) { Snapshot.create(timestamp: Time.now, session_id: parent_session.id) }
      Given { first_snapshot.add_object_count(ObjectCount.new(class_name: "first_only", count: 10)) }
      Given { first_snapshot.add_object_count(ObjectCount.new(class_name: "both", count: 1)) }
      Given { first_snapshot.add_object_count(ObjectCount.new(class_name: "both_same", count: 2)) }

      Given(:second_snapshot) { Snapshot.create(timestamp: Time.now, session_id: parent_session.id) }
      Given { second_snapshot.add_object_count(ObjectCount.new(class_name: "both", count: 5)) }
      Given { second_snapshot.add_object_count(ObjectCount.new(class_name: "both_same", count: 2)) }
      Given { second_snapshot.add_object_count(ObjectCount.new(class_name: "second_only", count: 9)) }

      Given(:expected_hash) do
        {
          "both" => 4,
          "both_same" => 0,
          "second_only" => 9,
          "first_only" => -10,
        }
      end

      Then { second_snapshot.difference(first_snapshot) == expected_hash }
    end
  end
end
