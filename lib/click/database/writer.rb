require 'click/observer'
require 'click/database/models'

module Click
  module Database
    class Writer
      include Click::Observer

      def on_add(clicker)
        @session = Models::Session.create(name: clicker.session_name, started_at: Time.now)
      end

      def after_click(clicker)
        snapshot = Models::Snapshot.create(timestamp: Time.now, session_id: session.id)
        object_count_hashes = clicker.object_counts.map do |klass, count|
          {snapshot_id: snapshot.id, class_name: klass.to_s, count: count}
        end

        Models::ObjectCount.dataset.multi_insert(object_count_hashes)
      end

      private
      attr_reader :session
    end
  end
end
