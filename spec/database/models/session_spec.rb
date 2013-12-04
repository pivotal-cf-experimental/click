require 'spec_helper'
require 'click/database'

initialize_models

module Click::Database::Models
  describe Session do
    describe '.scopes' do
      describe '.by_name' do
        it 'returns only object counts belonging to the session with that name' do
          with_in_memory_db do
            Session.create(name: 'ignored', started_at: Time.now)

            important_session = Session.create(name: 'important', started_at: Time.now)

            dataset = Session.by_name('important')
            expect(dataset.all).to eq([important_session])
          end
        end
      end

      describe '.snapshots' do
        it 'returns all the snapshots belonging to the set of sessions' do
          with_in_memory_db do
            ignored_session = Session.create(name: 'ignored', started_at: Time.now)
            50.times { ignored_session.add_snapshot(Snapshot.new(timestamp: Time.now))}

            session = Session.create(name: 'important', started_at: Time.now)
            snapshot = session.add_snapshot(Snapshot.new(timestamp: Time.now))

            other_session = Session.create(name: 'important', started_at: Time.now)
            other_snapshot = other_session.add_snapshot(Snapshot.new(timestamp: Time.now))

            expect(Session.by_name('important').snapshots.map(:id)).to match_array([snapshot.id, other_snapshot.id])
          end
        end
      end
    end
  end
end
