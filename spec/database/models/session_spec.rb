require 'spec_helper'
require 'click/database'

initialize_models

module Click::Database::Models
  describe Session do
    Given(:session_name) { SecureRandom.uuid }

    describe 'the .by_name dataset' do
      Given(:session) { Session.create(name: session_name, started_at: Time.now) }

      Then { [session] == Session.by_name(session_name).all }
    end

    describe 'the .snapshots dataset' do
      Given!(:first_session) { Session.create(name: session_name, started_at: Time.now) }
      Given!(:first_snapshot) { first_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }

      Given!(:other_session) { Session.create(name: session_name, started_at: Time.now) }
      Given!(:other_snapshot) { other_session.add_snapshot(Snapshot.new(timestamp: Time.now)) }

      Then { expect(Session.by_name(session_name).snapshots.all).to match_array([first_snapshot, other_snapshot]) }
    end
  end
end
