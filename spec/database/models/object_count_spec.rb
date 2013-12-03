require 'spec_helper'
require 'click/database'

initialize_models

module Click::Database::Models
  describe ObjectCount do
    describe '.scopes' do
      describe '.by_session_name' do
        it 'returns only object counts belonging to the session with that name' do
          ignored_session = Session.create(name: 'ignored', started_at: Time.now)
          ignored_snapshot = Snapshot.create(timestamp: Time.now, session_id: ignored_session.id)
          50.times { ObjectCount.create(class_name: "Foo", count: 1, snapshot_id: ignored_snapshot.id) }

          important_session = Session.create(name: 'important', started_at: Time.now)
          important_snapshot = Snapshot.create(timestamp: Time.now, session_id: important_session.id)
          important_object_count = ObjectCount.create(class_name: "Bar", count: 2, snapshot_id: important_snapshot.id)

          dataset = ObjectCount.by_session_name('important')
          expect(dataset.count).to eq(1)
          expect(dataset.map([:id, :class_name, :count])).to eq([[important_object_count.id, "Bar", 2]])
        end
      end
    end
  end
end
