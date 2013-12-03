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
    end
  end
end
