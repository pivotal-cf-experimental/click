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

      describe '.sessions' do
        it 'returns sessions owning the current snapshots' do
          with_in_memory_db do
            Session.create(name: 'ignored', started_at: Time.now)

            important_session = Session.create(name: 'important', started_at: Time.now)
            Snapshot.create(timestamp: Time.now, session_id: important_session.id)

            expect(Snapshot.dataset.sessions.all).to eq([important_session])
          end
        end
      end

      describe '.object_counts' do
        it 'returns object counts owned by the current snapshots' do
          with_in_memory_db do
            Session.create(name: 'ignored', started_at: Time.now).
              add_snapshot(Snapshot.new(timestamp: Time.now)).
              add_object_count(ObjectCount.new(class_name: 'Bar', count: 1))

            session = Session.create(name: 'important', started_at: Time.now)
            snapshot = Snapshot.create(timestamp: Time.now, session_id: session.id)
            object_count = snapshot.add_object_count(ObjectCount.new(class_name: 'Foo', count: 5))

            expect(Snapshot.where(session_id: session.id).object_counts.all).to eq([object_count])
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

    describe '#difference' do
      it "returns a hash representing the differences between the snapshot's object counts" do
        session = Session.create(name: "a session", started_at: Time.now - 100)

        first_snapshot = Snapshot.create(timestamp: Time.now - 50, session_id: session.id)
        first_snapshot.add_object_count(ObjectCount.new(class_name: "first_only", count: 10))
        first_snapshot.add_object_count(ObjectCount.new(class_name: "both", count: 1))

        second_snapshot = Snapshot.create(timestamp: Time.now, session_id: session.id)
        second_snapshot.add_object_count(ObjectCount.new(class_name: "both", count: 5))
        second_snapshot.add_object_count(ObjectCount.new(class_name: "second_only", count: 9))

        expect(second_snapshot.difference(first_snapshot)).to eq(
          "both" => 4,
          "second_only" => 9,
          "first_only" => -10,
        )
      end
    end
  end
end
