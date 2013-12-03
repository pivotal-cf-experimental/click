require 'spec_helper'
require 'click/database'

initialize_models

module Click::Database::Models
  describe Snapshot do
    let(:session_id) { Click::Database::Models::Session.create(name: "test", started_at: Time.now).id }

    describe 'scopes' do
      describe '.after' do
        it 'excludes records prior to the given time' do
          with_in_memory_db do
            described_class.create(timestamp: Date.new(2000), session_id: session_id)
            later = described_class.create(timestamp: Date.new(2006), session_id: session_id)

            expect(described_class.after(Date.new(2003)).all).to eq([later])
          end
        end
      end

      describe '.before' do
        it 'excludes records after the given time' do
          with_in_memory_db do
            earlier = described_class.create(timestamp: Date.new(2000), session_id: session_id)
            described_class.create(timestamp: Date.new(2006), session_id: session_id)

            expect(described_class.before(Date.new(2003)).all).to eq([earlier])
          end
        end
      end

      describe '.by_session_name' do
        it 'returns only snapshots belonging to the session with that name' do
          with_in_memory_db do
            ignored_session = Session.create(name: 'ignored', started_at: Time.now)
            50.times { Snapshot.create(timestamp: Time.now, session_id: ignored_session.id) }

            important_session = Session.create(name: 'important', started_at: Time.now)
            important_snapshot = Snapshot.create(timestamp: Time.now, session_id: important_session.id)

            dataset = Snapshot.by_session_name('important')
            expect(dataset.count).to eq(1)
            expect(dataset.map([:id, :timestamp, :session_id])).to eq([[important_snapshot.id, important_snapshot.timestamp, important_session.id]])
          end
        end
      end

      it 'can combine scopes' do
        with_in_memory_db do
          described_class.create(timestamp: Date.new(2000), session_id: session_id)
          middle = described_class.create(timestamp: Date.new(2003), session_id: session_id)
          described_class.create(timestamp: Date.new(2006), session_id: session_id)

          expect(described_class.after(Date.new(2001)).before(Date.new(2005)).all).to eq([middle])
        end
      end
    end
  end
end
