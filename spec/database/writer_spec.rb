require 'spec_helper'
require 'click/database'
require 'securerandom'

initialize_models

require 'click/database/writer'

module Click::Database
  describe Writer do
    Given(:writer) { Writer.new }
    Given(:session_name) { SecureRandom.uuid }
    Given(:clicker) { Click::Clicker.new(session_name) }

    describe 'when added to the clicker' do
      When { clicker.add_observer(writer) }

      Then { Models::Session.where(name: session_name).count == 1 }

      describe 'the session' do
        Given(:session) { Models::Session[name: session_name] }

        Then { session.snapshots_dataset.count == 0 }

        context 'when a click happens' do
          Given!(:before_click_time) { Time.now }
          When { clicker.click! }

          Then { session.snapshots_dataset.count == 1 }

          describe 'the created snapshot' do
            Given(:snapshot) { session.snapshots.first }

            Then { snapshot.object_counts_dataset.count > 0 }
            And { snapshot.timestamp >= before_click_time }
            And { snapshot.timestamp <= Time.now }
          end

          context 'and another click happens' do
            When { clicker.click! }

            Then { session.snapshots_dataset.count == 2 }

            describe 'the created snapshot' do
              Given(:snapshot) { session.snapshots.last }

              Then { snapshot.object_counts_dataset.count > 0 }
              And { snapshot.timestamp >= before_click_time }
              And { snapshot.timestamp <= Time.now }
            end
          end
        end
      end
    end
  end
end
