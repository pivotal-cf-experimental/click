require 'click/indeterminable'

module Click
  class Clicker
    attr_reader :session_name

    def initialize(session_name)
      @session_name = session_name
    end

    def click!
      observers.each { |o| o.before_click(self) }

      ObjectSpace.garbage_collect

      @state = Hash.new(0)
      ObjectSpace.each_object do |object|
        begin
          klass = object.class
          klass = Click::Indeterminable unless klass.is_a?(Class)
        rescue NoMethodError
          klass = Click::Indeterminable
        end

        @state[klass] += 1
      end

      @state[Symbol] = Symbol.all_symbols.count

      observers.each { |o| o.after_click(self) }
    end

    def object_counts
      @state.dup
    end

    def instance_count(klass)
      @state.fetch(klass, 0)
    end

    def add_observer(observer)
      observers << observer
      observer.on_add(self)
    end

    private
    def observers
      @observers ||= []
    end
  end

  class << self
    def clicker_with_database(session_name, connection_string)
      require 'click/database'
      Click::Database.with_database(connection_string) do |db|
        require 'click/database/writer'
        writer = Click::Database::Writer.new(db)
        clicker = Click::Clicker.new(session_name)
        clicker.add_observer(writer)
        yield clicker
      end
    end
  end
end
